/*
 * Copyright (c) 2011-2018, Zingaya, Inc. All rights reserved.
 */

'use strict';

import React, { Component, PropTypes } from 'react';
import {
  Platform,
  NativeModules
} from 'react-native';

class VoximplantLegacy {

  constructor() {}

  /**
   * Initialization Voximplant SDK
   * @param {VoxImplantClientConfig} options
   * @deprecated Use {@link Voximplant#getInstance} instead
   */
  init(options) {
    if (!options) options = {};
    if (Platform.OS === 'android') {
      if (options.enableVideo === undefined) options.enableVideo = true;
      if (options.enableHWAcceleration === undefined) options.enableHWAcceleration = true;
      if (options.provideLocalFramesInByteBuffer === undefined) 
        options.provideLocalFramesInByteBuffer = false;
      if (options.enableDebugLogging === undefined) options.enableDebugLogging = false;
      VoxImplantModule.init(options.enableVideo,
        options.enableHWAcceleration,
        options.provideLocalFramesInByteBuffer,
        options.enableDebugLogging);
    }
    if (Platform.OS === 'ios') {
      if (options.logLevel === undefined) options.logLevel = 'info';
      VoxImplantModule.init(options.logLevel);
    }
  }
  /**
   * Connect to the Voximplant cloud
   * @param {VoxImplantConnectOptions} options
   * @deprecated Use {@link Voximplant.Client#connect} instead
   */
  connect(options) {
    if (!options) options = {};
    if (options.connectivityCheck === undefined) options.connectivityCheck = true;
    if (Platform.OS === 'android') {
      if (options.servers === undefined) options.servers = [];
      VoxImplantModule.connect(options.connectivityCheck, options.servers);
    }
    if (Platform.OS === 'ios') {
      VoxImplantModule.connect(options.connectivityCheck);
    }
  };

  /**
   * Create new call
   * @param {string} to - SIP URI, username or phone number to make call to. Actual routing is then performed by VoxEngine scenario
   * @param {boolean} video - Enable video support in call
   * @param {string} customData - Optional custom data passed with call. Will be available in VoxEngine scenario
   * @param {object} callback - Callback object
   * @deprecated Use {@link Voximplant.Client#call} instead
   */
  createCall(to, video, customData, callback) {
    if (typeof(video) === 'function') {
      return VoxImplantModule.createCall(to,
             false,
             "",
             video);  
    }
    else
    if (typeof(customData) === 'function') {
      return VoxImplantModule.createCall(to,
             video,
             "",
             customData);  
    }
    else {
      return VoxImplantModule.createCall(to,
             video === undefined ? false : video,
             customData === undefined ? "" : customData,
             callback === undefined ? function(id) {} : callback);
    }
  };

  /**
   * Login to specified Voximplant application
   * @param {string} user - Full user name, including app and account name, like <i>someuser@someapp.youraccount.voximplant.com</i>
   * @param {string} password - User password
   * @deprecated Use {@link Voximplant.Client#login} instead
   */
  login(user, password) {
    VoxImplantModule.login(user, password);
  };

  /**
   * Perform login using one time key that was generated before
   * @param {string} user - Full user name, including app and account name, like <i>someuser@someapp.youraccount.voximplant.com</i>
   * @param {string} hash - Hash that was generated using following formula: MD5(oneTimeKey+"|"+MD5(user+":voximplant.com:"+password)). <b>Please note that here user is just a user name, without app name, account name or anything else after "@"</b>. So if you pass <i>myuser@myapp.myacc.voximplant.com</i> as a<b>username</b>, you should only use <i>myuser</i>  while computing this hash
   * @deprecated Use {@link Voximplant.Client#loginWithOneTimeKey} instead
   */
  loginUsingOneTimeKey(user, hash) {
    VoxImplantModule.loginUsingOneTimeKey(user, hash);
  }

  /**
   * Perform login using specified username and access token that was obtained in LoginSuccessful callback before
   * @param {string} user - Full user name, including app and account name, like <i>someuser@someapp.youraccount.voximplant.com</i>
   * @param {string} accessToken - Access token that was obtained in LoginSuccessful callback
   * @deprecated Use {@link Voximplant.Client#loginWithToken} instead
   */
  loginUsingAccessToken(user, accessToken) {
    VoxImplantModule.loginUsingAccessToken(user, accessToken);
  }

  /**
   * Perform refresh of login tokens required for login using access token
   * @param {string} user - Full user name, including app and account name, like <i>someuser@someapp.youraccount.voximplant.com</i>
   * @param {string} refreshToken - Refresh token that was obtained in LoginSuccessful callback
   * @depreacted Use {@link Voximplant.Client#tokenRefresh} instead
   */
  refreshToken(user, refreshToken) {
    VoxImplantModule.refreshToken(user, refreshToken);
  }

  /**
   * Generates one time login key to be used for automated login process
   * @param {string} user - Full user name, including app and account name, like <i>someuser@someapp.youraccount.voximplant.com</i>
   * @deprecated Use {@link Voximplant.Client#requestOneTimeLoginKey} instead
   */
  requestOneTimeKey(user) {
    VoxImplantModule.requestOneTimeKey(user);
  }

  /**
   * Closes connection with media server
   * @deprecated Use {@link Voximplant.Client#disconnect} instead
   */
  closeConnection() {
    VoxImplantModule.closeConnection();
  };

  /**
   * Send start call request If call with specified id is not found - returns false
   * @param {string} callId - Id of previously created call
   * @param {object} headers - Optional set of headers to be sent with message. Names must begin with "X-" to be processed by SDK
   * @deprecated Use {@link Voximplant.Client#call} instead
   */
  startCall(callId, headers) {
    VoxImplantModule.startCall(callId, headers === undefined ? {} :  headers);
  };

  /**
   * Sends DTMF digit in specified call
   * @param {string} callId - Id of previously created call
   * @param {number} digit - Digit can be 0-9 for 0-9, 10 for * and 11 for #
   * @deprecated Use {@link Voximplant.Call#sendTone} instead
   */
  sendDTMF(callId, digit) {
    VoxImplantModule.sendDTMF(callId, digit);
  };

  /**
   * Terminate specified call. Call must be either established, or outgoing progressing
   * @param {string} callId - Id of previously created call
   * @param {object} headers - Optional set of headers to be sent with message. Names must begin with "X-" to be processed by Voximplant
   * @deprecated Use {@link Voximplant.Call#hangup} instead.
   */
  disconnectCall(callId, headers) {
    VoxImplantModule.disconnectCall(callId, headers === undefined ? {} :  headers);
  };

  /**
   * Reject incoming alerting call
   * @param {string} callId - Id of previously created call
   * @param {object} headers - Optional set of headers to be sent with message. Names must begin with "X-" to be processed by SDK
   * @deprecated Use {@link Voximplant.Call#decline} or {@link Voximplant.Call#reject} instead
   */
  declineCall(callId, headers) {
    VoxImplantModule.declineCall(callId, headers === undefined ? {} :  headers);
  };

  /**
   * Answer incoming call
   * @param {string} callId - Id of previously created call
   * @param {object} headers - Optional set of headers to be sent with message. Names must begin with "X-" to be processed by SDK
   * @depreacted Use {@link Voximplant.Call#answer} instead
   */
  answerCall(callId, customData, headers) {
    VoxImplantModule.answerCall(callId, 
                                customData === undefined ? null : customData,
                                headers === undefined ? {} :  headers);
  };

  /**
   * Sends instant message within established call
   * @param {string} callId - Id of previously created call
   * @param {string} text - Message text
   * @deprecated Use {@link Voximplant.Call#sendMessage} instead
   */
  sendMessage(callId, text) {
    VoxImplantModule.sendMessage(callId, text);
  };

  /**
   * Sends info within established call
   * @param {string} callId - Id of previously created call
   * @param {string} mimeType - MIME type of info
   * @param {string} content - Custom string data
   * @param {object} headers - Optional set of headers to be sent with message. Names must begin with "X-" to be processed by SDK
   * @depreacted Use {@link Voximplant.Call#sendInfo} instead
   */
  sendInfo(callId, mimeType, content, headers) {
    VoxImplantModule.sendInfo(callId, mimeType, content, headers === undefined ? {} : headers);
  };

  /**
   * Mute or unmute microphone. This is reset after audio interruption
   * @param {boolean} doMute - Enable/disable flag
   * @deprecated Use {@link Voximplant.Call#sendAudio} instead.
   */
  setMute(doMute) {
    VoxImplantModule.setMute(doMute);
  };

  /**
   * Enable/disable loudspeaker
   * @param {boolean} enable - Enable/disable loudspeaker
   * @deprecated Use {@link Voximplant.Harware.AudioDeviceManager#selectAudioDevice} instead
   */
  setUseLoudspeaker(enable) {
    VoxImplantModule.setUseLoudspeaker(enable);
  };

  /**
   * Set video display mode. Applies to both incoming and outgoing stream. IOS ONLY
   * @param {VideoResizeMode} mode - Resize mode
   * @deprecated
   */
  setVideoResizeMode(mode) {
    VoxImplantModule.setVideoResizeMode(mode);
  };

  /**
   * Start/stop sending video from local camera
   * @param {boolean} doSend - Specify if video should be sent
   * @deprecated Use {@link Voximplant.Call#sendVideo} instead
   */
  sendVideo(doSend) {
    VoxImplantModule.sendVideo(doSend);
  };

  /**
   * Set local camera resolution
   * @param {number} width - Camera resolution width
   * @param {number} height - Camera resolution height
   * @deprecated Use {@link Voximplant.Hardware.CameraManager#setCameraResolution} instead
   */
  setCameraResolution(width, height) {
    VoxImplantModule.setCameraResolution(width, height);
  };

  /**
   * Switch camera
   * @param {CameraType} cameraName - Must be "front" or "back"
   * @depreacted Use {@link Voximplant.Hardware.CameraManager#switchCamera} instead
   */
  switchToCamera(cameraName) {
    VoxImplantModule.switchToCamera(cameraName);
  };

  /**
   * Register for push notifications. Application will receive push notifications from the Voximplant Server after first log in
   * @param {string} pushRegistrationToken - Push registration token
   * @depreacted Use {@link Voximplant.Client#registerPushNotificationsToken} instead
   */
  registerForPushNotifications(pushRegistrationToken) {
    VoxImplantModule.registerForPushNotifications(pushRegistrationToken);
  }

  /**
   * Unregister from push notifications. Application will no longer receive push notifications from the Voximplant server
   * @param {string} pushRegistrationToken - Push registration token that was used to register for push notifications
   * @depreacted Use {@link Voximplant.Client#unregisterPushNotificationsToken} instead
   */
  unregisterFromPushNotifications(pushRegistrationToken) {
    VoxImplantModule.unregisterFromPushNotifications(pushRegistrationToken);
  }

  /**
   * Handle incoming push notification
   * @param {object} notification - Incoming push notification
   * @depreacted Use {@link Voximplant.Client#handlePushNotification} instead
   */
  handlePushNotification(notification) {
    VoxImplantModule.handlePushNotification(notification);
  }

  /**
   * List of events
   * @type {{LoginSuccessful: string, LoginFailed: string, OneTimeKeyGenerated: string, ConnectionSuccessful: string, ConnectionClosed: string, ConnectionFailed: string, CallConnected: string, CallDisconnected: string, CallRinging: string, CallFailed: string, CallAudioStarted: string, IncomingCall: string, SIPInfoReceivedInCall: string, MessageReceivedInCall: string, NetStatsReceived: string, RefreshTokenSuccess: string, RefreshTokenFailed: string}}
   * @namespace Events
   */
  Events = {
    /**
     * Invoked when login process finished successfully.
     * @property {string} displayName - Display name of logged in user
     * @property {LoginTokens} loginTokens - Login tokens that can be used to login using access token
     * @deprecated Use {@link Voximplant.ClientEvents.AuthResult} instead
     */
    LoginSuccessful: "LoginSuccessful",
    /**
     * Invoked when login process failed
     * @property {number} errorCode - Login error code, possible values are: <table><thead><tr><th> code </th><th> description </th></tr></thead><tbody><tr><td> 401  </td><td> invalid password or token </td></tr><tr><td> 403  </td><td> account frozen </td></tr><tr><td> 404  </td><td> invalid username </td></tr><tr><td> 500  </td><td> internal error </td></tr><tr><td> 701  </td><td> token expired </td></tr></tbody></table>
     * @deprecated Use {@link Voximplant.ClientEvents.AuthResult} instead
     */
    LoginFailed: "LoginFailed",
    /**
     * Returns one time key generated by the login server as a result of requestOneTimeLoginKey
     * @property {string} key - One time key
     * @deprecated Use {@link Voximplant.ClientEvents.AuthResult} instead
     */
    OneTimeKeyGenerated: "OneTimeKeyGenerated",
    /**
     * Connection with cloud established
     * @deprecated Use {@link Voximplant.ClientEvents.ConnectionEstablished} instead
     */
    ConnectionSuccessful: "ConnectionSuccessful",
    /**
     * Connection with cloud closed
     * @deprecated Use {@link Voximplant.ClientEvents.ConnectionClosed} instead
     */
    ConnectionClosed: "ConnectionClosed",
    /**
     * Connection with cloud failed
     * @property {string} reason - Error message
     * @deprecated Use {@link Voximplant.ClientEvents.ConnectionFailed} instead
     */
    ConnectionFailed: "ConnectionFailed",
    /**
     * Call established
     * @property {string} callId - Id of call
     * @property {object} headers - Optional headers passed with event
     * @deprecated Use {@link Voximplant.CallEvents.Connected}
     */
    CallConnected: "CallConnected",
    /**
     * Call terminated
     * @property {string} callId - Id of call
     * @property {object} headers - Optional headers passed with event
     * @property {boolean} answeredElsewhere - Indicate if the call was answered on other peer
     * @deprecated Use {@link Voximplant.CallEvents.Disconnected}
     */
    CallDisconnected: "CallDisconnected",
    /**
     * Call ringing. You should start playing call progress tone now
     * @property {string} callId - Id of call
     * @property {object} headers - Optional headers passed with event
     * @deprecated Use {@link Voximplant.CallEvents.ProgressToneStart}
     */
    CallRinging: "CallRinging",
    /**
     * Outgoing call failed
     * @property {string} callId - Id of call
     * @property {number} code - Status code
     * @property {string} reason - Status message
     * @property {object} headers - Optional headers passed with event
     * @deprecated Use {@link Voximplant.CallEvents.Failed} instead
     */
    CallFailed: "CallFailed",
    /**
     * Call audio started. You should stop playing progress tone when event is received
     * @property {string} callId - Id of call
     * @deprecated Use {@link Voximplant.CallEvents.ProgressToneStop} instead
     */
    CallAudioStarted: "CallAudioStarted",
    /**
     * New incoming call received by SDK
     * @property {string} callId - Id of call
     * @property {string} from - SIP URI of caller
     * @property {string} displayName - Displayed name of caller
     * @property {boolean} videoCall - Video call flag
     * @property {object} headers - Optional headers passed with event
     * @deprecated Use {@link Voximplant.ClientEvents.IncomingCall} instead
     */
    IncomingCall: "IncomingCall",
    /**
     * SIP INFO received during a call
     * @property {string} callId - Id of call
     * @property {string} type - MIME type of info
     * @property {string} content - Body of info message
     * @property {object} headers - Optional headers passed with event
     * @deprecated Use {@link Voximplant.CallEvents.InfoReceived} instead
     */
    SIPInfoReceivedInCall: "SIPInfoReceivedInCall",
    /**
     * Instant message received during a call
     * @property {string} callId - Id of call
     * @property {string} text - Message text
     * @deprecated Use {@link Voximplant.CallEvents.MessageReceived} instead
     */
    MessageReceivedInCall: "MessageReceivedInCall",
    /**
     * Event dispatched when packet loss data received from Voximplant servers
     * @property {string} callId - Id of call
     * @property {object} stats - NetworkInfo
     * @depreacted
     */
    NetStatsReceived:"NetStatsReceived",
    /**
     * Invoked when refresh of login tokens finished successfully
     * @property {LoginTokens} loginTokens - Login tokens that can be used to login using access token
     * @deprecated Use {@link Voximplant.ClientEvents.RefreshTokenResult} instead
     */
    RefreshTokenSuccess:"RefreshTokenSuccess",
    /**
     * Invoked when refresh of login tokens failed
     * @property {number} reason - Failure reason
     * @deprecated Use {@link Voximplant.ClientEvents.RefreshTokenResult} instead.
     */
    RefreshTokenFailed: "RefreshTokenFailed"
  };

  /**
   * Enum of supported video resize modes
   * @enum {string}
   * @deprecated Use {@link Voximplant.RenderScaleType} instead
   */
  VideoResizeMode = {
    /**
     * Video frame is scaled to be fit the size of the view by maintaining the aspect ratio (black borders may be displayed)
     */
    VideoResizeModeFit: "fit",
    /**
     * Video frame is scaled to fill the size of the view by maintaining the aspect ratio. Some portion of the video frame may be clipped
     */
    VideoResizeModeClip: "clip"
  };

  /**
   * Enum of supported camera type modes
   * @enum {string}
   * @deprecated Use {@link Voximplant.Hardware.CameraType} instead.
   */
  CameraType = {
      /**
       * The facing of the camera is the same as that of the screen
       */
      CameraTypeFront: "front",
      /**
       * The facing of the camera is opposite to that of the screen
       */
      CameraTypeBack: "back"
  };

  /**
   * Enum of log levels. IOS ONLY
   * @enum {string}
   * @deprecated Use {@link Voximplant.LogLevel} instead.
   */
  LogLevel = {
    /**
     * Log verbosity level, to include only error messages
     */
    LogLevelError: "error",
    /**
     * Default log verbosity level, to include informational messages
     */
    LogLevelInfo: "info",
    /**
     * Log verbosity level to include debug messages
     */
    LogLevelDebug: "debug",
    /**
     * Log verbosity level to include trace messages
     */
    LogLevelTrace: "trace"
  };

  /**
   * @property {number} accessExpire - Seconds to access token expire
   * @property {string} accessToken - Access token that can be used to login before accessExpire
   * @property {number} refreshExpire - Seconds to refresh token expire
   * @property {string} refreshToken - Refresh token that can be used one time before refresh token expired
   * @deprecated Use {@link Voximplant.LoginTokens} instead
   */
  LoginTokens = {

  };

  /**
   * @property {boolean} enableVideo - Enable video functionality. Set to true by default. ANDROID ONLY
   * @property {boolean} enableHWAcceleration - Enable hardware video acceleration. Set to true by default. Should be set to false, if provideLocalFramesInByteBuffers is set to true. ANDROID ONLY
   * @property {boolean} provideLocalFramesInByteBuffers - Request video frames from camera in I420 format with byte buffers. Set to false by default. If set to false, video frames from camera will be provided in I420 format with textures. ANDROID ONLY
   * @property {boolean} enableDebugLogging - Enable debug logging. Set to false by default. ANDROID ONLY
   * @property {LogLevel} logLevel - Log levels. IOS ONLY
   * @deprecated Use {@link Voximplant.ClientConfig}
   */
  VoxImplantClientConfig = {

  };
  /**
   * @property {boolean} connectivityCheck - Checks whether UDP traffic will flow correctly between device and the Voximplant cloud. This check reduces connection speed
   * @property {array} servers - Server name of particular media gateway for connection
   * @deprecated Use {@link Voximplant.ConnectOptions} instead.
   */
  VoxImplantConnectOptions = {

  };
}

var VoxImplantModule = NativeModules.VoxImplantModule;

export default VoximplantLegacy = new VoximplantLegacy();


