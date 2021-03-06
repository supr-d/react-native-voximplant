/*
 * Copyright (c) 2011-2018, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RCTBridgeModule.h"
#import "RCTConvert.h"
#import "ClientModule.h"
#import "Constants.h"
#import "Utils.h"
#import "VICall.h"
#import "CallManager.h"

NSString *const LOG_LEVEL_ERROR = @"error";
NSString *const LOG_LEVEL_WARNING = @"warning";
NSString *const LOG_LEVEL_INFO = @"info";
NSString *const LOG_LEVEL_DEBUG = @"debug";
NSString *const LOG_LEVEL_VERBOSE = @"verbose";
NSString *const LOG_LEVEL_MAX = @"max";

NSString *const CLIENT_STATE_DISCONNECTED = @"disconnected";
NSString *const CLIENT_STATE_CONNECTING = @"connecting";
NSString *const CLIENT_STATE_CONNECTED = @"connected";
NSString *const CLIENT_STATE_LOGGING_IN = @"logging_in";
NSString *const CLIENT_STATE_LOGGED_IN = @"logged_in";

@implementation RCTConvert (VILogLevel)
RCT_ENUM_CONVERTER(VILogLevel, (@{
                                  @"error"   : @(VILogLevelError),
                                  @"warning" : @(VILogLevelWarning),
                                  @"info"    : @(VILogLevelInfo),
                                  @"debug"   : @(VILogLevelDebug),
                                  @"verbose" : @(VILogLevelVerbose),
                                  @"max"     : @(VILogLevelMax)
                                  }), VILogLevelInfo, integerValue)
@end

@implementation RCTConvert (VIClientState)
RCT_ENUM_CONVERTER(VIClientState, (@{
                                     @"disconnected" : @(VIClientStateDisconnected),
                                     @"connecting"   : @(VIClientStateConnecting),
                                     @"connected"    : @(VIClientStateConnected),
                                     @"logging_in"   : @(VIClientStateLoggingIn),
                                     @"logged_in"    : @(VIClientStateLoggedIn),
                                     }), VIClientStateDisconnected, integerValue)
@end

@interface ClientModule()
@property(nonatomic, weak) VIClient* client;
@end

@implementation ClientModule
RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
    return @[kEventConnectionEstablished,
             kEventConnectionFailed,
             kEventConnectionClosed,
             kEventAuthResult,
             kEventAuthTokenResult,
             kEventIncomingCall];
}

- (void)dealloc {
    if (_client) {
        [_client disconnect];
        _client = nil;
    }
}

RCT_REMAP_METHOD(initWithOptions, init:(VILogLevel)logLevel saveLogsToFile:(BOOL)enable) {
    if (enable) {
        [VIClient saveLogToFileEnable];
    }
    [VIClient setLogLevel:logLevel];
    _client = [CallManager getClient];
    _client.sessionDelegate = self;
    _client.callManagerDelegate = self;
}

RCT_EXPORT_METHOD(disconnect) {
    if (_client) {
        [_client disconnect];
    }
}

RCT_EXPORT_METHOD(connect:(BOOL)connectivityCheck gateways:(NSArray *)gateways callback:(RCTResponseSenderBlock)callback) {
    if (_client) {
        BOOL isValidState = [_client connectWithConnectivityCheck:connectivityCheck gateways:gateways];
        callback(@[[NSNumber numberWithBool:isValidState]]);
    }
}

RCT_REMAP_METHOD(getClientState,
                 getClientStateWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    if (_client) {
        resolve([self convertClientStateToString:_client.clientState]);
    }
}

RCT_REMAP_METHOD(login, loginWithUsername:(NSString *)user andPassword:(NSString *)password) {
    if (_client) {
        [_client loginWithUser:user
                      password:password
                       success:^(NSString *displayName, NSDictionary *authParams) {
                           [self sendEventWithName:kEventAuthResult body:@{kEventParamName        : kEventNameAuthResult,
                                                                           kEventParamResult      : @(true),
                                                                           kEventParamDisplayName : displayName,
                                                                           kEventParamTokens      : authParams
                                                                          }];
                       }
                       failure:^(NSError *error) {
                           [self sendEventWithName:kEventAuthResult body:@{
                                                                           kEventParamName   : kEventNameAuthResult,
                                                                           kEventParamResult : @(false),
                                                                           kEventParamCode   : @(error.code)
                                                                          }];
                       }];
    }
}

RCT_REMAP_METHOD(loginWithOneTimeKey, loginWithUsername:(NSString *)user andOneTimeKey:(NSString *)hash) {
    if (_client) {
        [_client loginWithUser:user
                    oneTimeKey:hash
                       success:^(NSString *displayName, NSDictionary *authParams) {
                           [self sendEventWithName:kEventAuthResult body:@{
                                                                           kEventParamName        : kEventNameAuthResult,
                                                                           kEventParamResult      : @(true),
                                                                           kEventParamDisplayName : displayName,
                                                                           kEventParamTokens      : authParams
                                                                          }];
                       }
                       failure:^(NSError *error) {
                           [self sendEventWithName:kEventAuthResult body:@{
                                                                           kEventParamName   : kEventNameAuthResult,
                                                                           kEventParamResult : @(false),
                                                                           kEventParamCode   : @(error.code)
                                                                          }];
                       }];
    }
}

RCT_REMAP_METHOD(loginWithToken, loginWithUserName:(NSString *)user andToken:(NSString *)token) {
    if (_client) {
        [_client loginWithUser:user
                         token:token
                       success:^(NSString *displayName, NSDictionary *authParams) {
                           [self sendEventWithName:kEventAuthResult body:@{
                                                                          kEventParamName        : kEventNameAuthResult,
                                                                          kEventParamResult      : @(true),
                                                                          kEventParamDisplayName : displayName,
                                                                          kEventParamTokens      : authParams
                                                                          }];
                       } failure:^(NSError *error) {
                           [self sendEventWithName:kEventAuthResult body:@{
                                                                           kEventParamName   : kEventNameAuthResult,
                                                                           kEventParamResult : @(false),
                                                                           kEventParamCode   : @(error.code)
                                                                          }];
                       }];
    }
}

RCT_EXPORT_METHOD(requestOneTimeLoginKey:(NSString *)user) {
    if (_client) {
        [_client requestOneTimeKeyWithUser:user
                                    result:^(NSString *oneTimeKey) {
                                        [self sendEventWithName:kEventAuthResult body:@{
                                                                                        kEventParamName   : kEventNameAuthResult,
                                                                                        kEventParamResult : @(false),
                                                                                        kEventParamCode   : @(302),
                                                                                        kEventParamKey    : oneTimeKey
                                                                                       }];
                                    }];
    }
}

RCT_REMAP_METHOD(refreshToken, refreshTokenWithUser:(NSString *)user token:(NSString *)token) {
    if (_client) {
        [_client refreshTokenWithUser:user
                                token:token
                               result:^(NSError *error, NSDictionary *authParams) {
                                   if (error) {
                                       [self sendEventWithName:kEventNameAuthTokenResult body:@{
                                                                                                kEventParamName   : kEventNameAuthTokenResult,
                                                                                                kEventParamResult : @(false),
                                                                                                kEventParamCode   : @(error.code)
                                                                                                }];
                                   } else {
                                       [self sendEventWithName:kEventNameAuthTokenResult body:@{
                                                                                                kEventParamName   : kEventNameAuthTokenResult,
                                                                                                kEventParamResult : @(true),
                                                                                                kEventParamTokens : authParams
                                                                                                }];
                                   }
                                
                               }];
    }
}

RCT_EXPORT_METHOD(registerPushNotificationsToken:(NSString *)token) {
    if(_client) {
        [_client registerPushNotificationsToken:[Utils dataFromHexString:token] imToken:nil];
    }
}

RCT_EXPORT_METHOD(unregisterPushNotificationsToken:(NSString *)token) {
    if (_client) {
        [_client unregisterPushNotificationsToken:[Utils dataFromHexString:token] imToken:nil];
    }
}

RCT_EXPORT_METHOD(handlePushNotification:(NSDictionary *)notification) {
    if (_client) {
        [_client handlePushNotification:notification];
    }
}

RCT_REMAP_METHOD(createAndStartCall,
                 callUser:(NSString *)user
                 withVideoSettings:(NSDictionary *)videoFlags
                 withH264Codec:(BOOL)H264first
                 customData:(NSString *)customData
                 headers:(NSDictionary *)headers
                 responseCallback:(RCTResponseSenderBlock)callback) {
    if (_client) {
        VICall* call = [_client callToUser:user
                             withSendVideo:[[videoFlags valueForKey:@"sendVideo"] boolValue]
                              receiveVideo:[[videoFlags valueForKey:@"receiveVideo"] boolValue]
                                customData:customData];
        if (call) {
            if (H264first) {
                call.preferredVideoCodec = @"H264";
            }
            [CallManager addCall:call];
            [call startWithHeaders:headers];
            callback(@[call.callId]);
        } else {
            callback(@[[NSNull null]]);
        }
    } else {
        callback(@[[NSNull null]]);
    }
}

- (NSString *)convertClientStateToString:(VIClientState)state {
    switch (state) {
        case VIClientStateDisconnected:
            return CLIENT_STATE_DISCONNECTED;
        case VIClientStateConnecting:
            return CLIENT_STATE_CONNECTING;
        case VIClientStateConnected:
            return CLIENT_STATE_CONNECTED;
        case VIClientStateLoggingIn:
            return CLIENT_STATE_LOGGING_IN;
        case VIClientStateLoggedIn:
            return CLIENT_STATE_LOGGED_IN;
    }
}

- (void)client:(VIClient *)client sessionDidFailConnectWithError:(NSError *)error {
    [self sendEventWithName:kEventConnectionFailed body:@{
                                                          kEventParamName    : kEventNameConnectionFailed,
                                                          kEventParamMessage : [error localizedDescription]
                                                          }];
}

- (void)clientSessionDidConnect:(VIClient *)client {
    [self sendEventWithName:kEventConnectionEstablished body:@{
                                                               kEventParamName : kEventNameConnectionEstablished
                                                               }];
}

- (void)clientSessionDidDisconnect:(VIClient *)client {
    [self sendEventWithName:kEventConnectionClosed body:@{
                                                          kEventParamName : kEventNameConnectionClosed
                                                          }];
}

- (void)client:(VIClient *)client didReceiveIncomingCall:(VICall *)call withIncomingVideo:(BOOL)video headers:(NSDictionary *)headers {
    [CallManager addCall:call];
    [self sendEventWithName:kEventIncomingCall body:@{
                                                      kEventParamName          : kEventNameIncomingCall,
                                                      kEventParamCallId        : call.callId,
                                                      kEventParamIncomingVideo : @(video),
                                                      kEventParamHeaders       : headers
                                                      }];
}

@end
