# Changelog

### 1.0.1
- Update native Android module to use the Voximplant Android SDK 2.5.1

### 1.0.0
- New APIs with advanced functionality: 
    - Promises support
    - Ability to indicate video directions on call creation or answering
    - Easy way to subscribe to Voximplant React Native SDK events with on/off APIs 
      instead of DeviceEventEmitter 
    - Extended control for audio devices and camera with ability to handle events 
      about new audio device, audio device changes, camera errors
    - Video resize modes for android
    - Endpoints, Video streams and Video views
    
  See official guides for mode details.

### 0.2.2
- Fix for login fail with access token, if previously login was performed via one time key
- Fix for [#40](https://github.com/voximplant/react-native-voximplant/issues/40)

### 0.2.1
- Fix RN 0.54 compatibility

### 0.2.0
- Add push notifications support
- Change iOS integration to Podfile approach
- Update native iOS and Andorid SDKs to the latest versions
- Bugfixes and stability improvements
