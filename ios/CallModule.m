/*
 * Copyright (c) 2011-2018, Zingaya, Inc. All rights reserved.
 */

#import "CallModule.h"
#import "RCTBridgeModule.h"
#import "Constants.h"
#import "CallManager.h"
#import "VICall.h"
#import "Utils.h"

@interface CallModule()

@end

@implementation CallModule
RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
    return @[kEventCallConnected,
             kEventCallDisconnected,
             kEventCallEndpointAdded,
             kEventCallFailed,
             kEventCallICETimeout,
             kEventCallICECompleted,
             kEventCallLocalVideoStreamAdded,
             kEventCallLocalVideoStreamRemoved,
             kEventCallInfoReceived,
             kEventCallMessageReceived,
             kEventCallProgressToneStart,
             kEventCallProgressToneStop,
             kEventEndpointInfoUpdate,
             kEventEndpointRemoved,
             kEventEndpointRemoteStreamAdded,
             kEventEndpointRemoteStreanRemoved];
}

RCT_EXPORT_METHOD(internalSetup:(NSString *)callId) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        [call addDelegate:self];
    }
}

RCT_REMAP_METHOD(answer,
                 answerCall:(NSString *)callId
                 withVideoSettings:(NSDictionary *)videoFlags
                 withH264codec:(BOOL)H264first
                 customData:(NSString *)customData
                 headers:(NSDictionary *)headers) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        if (H264first) {
            call.preferredVideoCodec = @"H264";
        }
        [call answerWithSendVideo:[[videoFlags valueForKey:@"sendVideo"] boolValue]
                     receiveVideo:[[videoFlags valueForKey:@"receiveVideo"] boolValue]
                       customData:customData
                          headers:headers];
    }
}

RCT_EXPORT_METHOD(decline:(NSString *)callId headers:(NSDictionary *)headers) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        [call rejectWithMode:VIRejectModeDecline headers:headers];
    }
}

RCT_EXPORT_METHOD(reject:(NSString *)callId headers:(NSDictionary *)headers) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        [call rejectWithMode:VIRejectModeBusy headers:headers];
    }
}

RCT_EXPORT_METHOD(sendAudio:(NSString *)callId enable:(BOOL)enable) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        call.sendAudio = enable;
    }
}

RCT_EXPORT_METHOD(sendDTMF:(NSString *)callId tone:(NSString *)tone) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        [call sendDTMF:tone];
    }
}

RCT_EXPORT_METHOD(hangup:(NSString *)callId headers:(NSDictionary *)headers) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        [call hangupWithHeaders:headers];
    }
}

RCT_EXPORT_METHOD(sendMessage:(NSString *)callId message:(NSString *)message) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        [call sendMessage:message];
    }
}

RCT_EXPORT_METHOD(sendInfo:(NSString *)callId mimeType:(NSString *)mimeType body:(NSString *)body headers:(NSDictionary *)headers) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        [call sendInfo:body mimeType:mimeType headers:headers];
    }
}

RCT_REMAP_METHOD(sendVideo, sendVideo:(NSString *)callId enable:(BOOL)enable resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        [call setSendVideo:enable completion:^(NSError * _Nullable error) {
            if (error) {
                reject([Utils convertIntToCallError:error.code], [error.userInfo objectForKey:@"reason"], error);
            } else {
                resolve([NSNull null]);
            }
        }];
    }
}

RCT_REMAP_METHOD(hold, hold:(NSString *)callId enable:(BOOL)enable resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        [call setHold:enable completion:^(NSError * _Nullable error) {
            if (error) {
                reject([Utils convertIntToCallError:error.code], [error.userInfo objectForKey:@"reason"], error);
            } else {
                resolve([NSNull null]);
            }
        }];
    }
}

RCT_REMAP_METHOD(receiveVideo, receiveVideo:(NSString *)callId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    VICall *call = [CallManager getCallById:callId];
    if (call) {
        [call startReceiveVideoWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                reject([Utils convertIntToCallError:error.code], [error.userInfo objectForKey:@"reason"], error);
            } else {
                resolve([NSNull null]);
            }
        }];
    }
}

- (void)call:(VICall *)call didConnectWithHeaders:(NSDictionary *)headers {
    [self sendEventWithName:kEventCallConnected body:@{
                                                       kEventParamName    : kEventNameCallConnected,
                                                       kEventParamCallId  : call.callId,
                                                       kEventParamHeaders : headers
                                                       }];
}

- (void)call:(VICall *)call didDisconnectWithHeaders:(NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere {
    [call removeDelegate:self];
    [CallManager removeCallById:call.callId];
    [self sendEventWithName:kEventCallDisconnected body:@{
                                                          kEventParamName              : kEventNameCallDisconnected,
                                                          kEventParamCallId            : call.callId,
                                                          kEventParamHeaders           : headers,
                                                          kEventParamAnsweredElsewhere : answeredElsewhere
                                                          }];
}

- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(NSDictionary *)headers {
    [self sendEventWithName:kEventCallFailed body:@{
                                                    kEventParamName    : kEventNameCallFailed,
                                                    kEventParamCallId  : call.callId,
                                                    kEventParamCode    : @(error.code),
                                                    kEventParamReason  : error.localizedDescription,
                                                    kEventParamHeaders : headers
                                                    }];
}

- (void)iceTimeoutForCall:(VICall *)call {
    [self sendEventWithName:kEventCallICETimeout body:@{
                                                        kEventParamName   : kEventNameCallICETimeout,
                                                        kEventParamCallId : call.callId
                                                        }];
}

- (void)iceCompleteForCall:(VICall *)call {
    [self sendEventWithName:kEventCallICECompleted body:@{
                                                          kEventParamName   : kEventNameCallICECompleted,
                                                          kEventParamCallId : call.callId
                                                          }];
}

- (void)call:(VICall *)call didReceiveInfo:(NSString *)body type:(NSString *)type headers:(NSDictionary *)headers {
    [self sendEventWithName:kEventCallInfoReceived body:@{
                                                          kEventParamName     : kEventNameCallInfoReceived,
                                                          kEventParamCallId   : call.callId,
                                                          kEventParamBody     : body,
                                                          kEventParamMimeType : type,
                                                          kEventParamHeaders  : headers
                                                          }];
}

- (void)call:(VICall *)call didReceiveMessage:(NSString *)message headers:(NSDictionary *)headers {
    [self sendEventWithName:kEventCallMessageReceived body:@{
                                                             kEventParamName   : kEventNameCallMessageReceived,
                                                             kEventParamCallId : call.callId,
                                                             kEventParamText   : message
                                                             }];
}

- (void)call:(VICall *)call startRingingWithHeaders:(NSDictionary *)headers {
    [self sendEventWithName:kEventCallProgressToneStart body:@{
                                                               kEventParamName    : kEventNameCallProgressToneStart,
                                                               kEventParamCallId  : call.callId,
                                                               kEventParamHeaders : headers
                                                               }];
}

- (void)callDidStartAudio:(VICall *)call {
    [self sendEventWithName:kEventCallProgressToneStop body:@{
                                                              kEventParamName   : kEventNameCallProgressToneStop,
                                                              kEventParamCallId : call.callId
                                                              }];
}

- (void)call:(VICall *)call didAddLocalVideoStream:(VIVideoStream *)videoStream {
    [CallManager addVideoStream:videoStream];
    [self sendEventWithName:kEventCallLocalVideoStreamAdded body:@{
                                                                   kEventParamName          : kEventNameCallLocalVideoStreamAdded,
                                                                   kEventParamCallId        : call.callId,
                                                                   kEventParamVideoStreamId : videoStream.streamId
                                                                   }];
}

- (void)call:(VICall *)call didRemoveLocalVideoStream:(VIVideoStream *)videoStream {
    [CallManager removeVideoStreamById:videoStream.streamId];
    [self sendEventWithName:kEventCallLocalVideoStreamRemoved body:@{
                                                                     kEventParamName          : kEventNameCallLocalVideoStreamRemoved,
                                                                     kEventParamCallId        : call.callId,
                                                                     kEventParamVideoStreamId : videoStream.streamId
                                                                     }];
}

- (void) call:(VICall *)call didAddEndpoint:(VIEndpoint *)endpoint {
    [CallManager addEndpoint:endpoint forCall:call.callId];
    [endpoint setDelegate:self];
    [self sendEventWithName:kEventCallEndpointAdded body:@{
                                                           kEventParamName           : kEventNameCallEndpointAdded,
                                                           kEventParamCallId         : call.callId,
                                                           kEventParamEndpointId     : endpoint.endpointId,
                                                           kEventParamEndpointName   : endpoint.user ? endpoint.user : [NSNull null],
                                                           kEventParamDisplayName    : endpoint.userDisplayName ? endpoint.userDisplayName : [NSNull null],
                                                           kEventParamEndpointSipUri : endpoint.sipURI ? endpoint.sipURI : [NSNull null]
                                                           }];
}

- (void)endpoint:(VIEndpoint *)endpoint didAddRemoteVideoStream:(VIVideoStream *)videoStream {
    [CallManager addVideoStream:videoStream];
    [self sendEventWithName:kEventEndpointRemoteStreamAdded body:@{
                                                                   kEventParamName          : kEventNameEndpointRemoteStreamAdded,
                                                                   kEventParamCallId        : [CallManager getCallIdByEndppointId:endpoint.endpointId],
                                                                   kEventParamEndpointId    : endpoint.endpointId,
                                                                   kEventParamVideoStreamId : videoStream.streamId
                                                                   }];
}

- (void)endpoint:(VIEndpoint *)endpoint didRemoveRemoteVideoStream:(VIVideoStream *)videoStream {
    [CallManager removeVideoStreamById:videoStream.streamId];
    [self sendEventWithName:kEventEndpointRemoteStreanRemoved body:@{
                                                                   kEventParamName          : kEventNameEndpointRemoteStreanRemoved,
                                                                   kEventParamCallId        : [CallManager getCallIdByEndppointId:endpoint.endpointId],
                                                                   kEventParamEndpointId    : endpoint.endpointId,
                                                                   kEventParamVideoStreamId : videoStream.streamId
                                                                   }];
}

- (void)endpointDidRemove:(VIEndpoint *)endpoint {
    [CallManager removeEndpointById:endpoint.endpointId];
    [self sendEventWithName:kEventEndpointRemoved body:@{
                                                         kEventParamName           : kEventNameEndpointRemoved,
                                                         kEventParamCallId         : [CallManager getCallIdByEndppointId:endpoint.endpointId],
                                                         kEventParamEndpointId     : endpoint.endpointId
                                                         }];
}

- (void)endpointInfoDidUpdate:(VIEndpoint *)endpoint {
    [self sendEventWithName:kEventEndpointInfoUpdate body:@{
                                                         kEventParamName           : kEventNameEndpointInfoUpdate,
                                                         kEventParamCallId         : [CallManager getCallIdByEndppointId:endpoint.endpointId],
                                                         kEventParamEndpointId     : endpoint.endpointId,
                                                         kEventParamEndpointName   : endpoint.user,
                                                         kEventParamDisplayName    : endpoint.userDisplayName ? endpoint.userDisplayName : [NSNull null],
                                                         kEventParamEndpointSipUri : endpoint.sipURI ? endpoint.sipURI : [NSNull null]
                                                         }];
}



@end
