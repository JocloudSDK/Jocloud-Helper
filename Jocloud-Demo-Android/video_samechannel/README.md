## Multi-User Video Call
[中文](README.zh.md) | [English](README.md)

Demo of the scene with multiple people in the same room, you can connect with 4 people in the same room, enter the UID and RoomId to start broadcasting (adding room), start broadcasting (adding room), close broadcasting (exiting room), remote enter/exit room, open /Off wheat, turn on/off camera, select front/rear camera, record log information, zoom in/restore a certain view, etc. Applicable scenarios: conference, multi-player mic, multi-player game voice chat, etc. Attached:[This demo describes how to implement multi-person co-hosting in a room using Jocloud SDK. With this sample, you can:
- Join/exit a room
- Enable/disable the microphone
- Enable/disable the camera
- Switch camera
- Log information
- Zoom in or restore the view

> Integrate SDK to APP, please refer to: [SDK Integration Method](https://docs.jocloud.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_ios.html)

> API development manual, refer to: [iOS API](https://docs.jocloud.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/iOS/v2.8.0/category.html)

### API Calling Flow
![avatar](same_channel.png)

## API Details 

(1) Initialize the ThunderSDK
```
    thunderEngine = ThunderEngine.createEngine(context, appId, sceneId, handler);
```
 
(2) Set configuration of the live, set the media mode, set the room mode
```
    //Set configuration of the live
    ThunderVideoEncoderConfiguration configuration = new ThunderVideoEncoderConfiguration();
    configuration.publishMode = RtcConstant.getPublishMode(context);
    configuration.playType = ThunderRtcConstant.ThunderPublishPlayType.THUNDERPUBLISH_PLAY_INTERACT;
    thunderEngine.setVideoEncoderConfig(configuration);
    //Set the media mode
    thunderEngine.setMediaMode(ThunderRtcConstant.ThunderRtcProfile.THUNDER_PROFILE_DEFAULT);
    
    //Set the room mode
    thunderEngine.setRoomMode(ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_LIVE);
```

(3) Join room. The token needs to be obtained from the business server by referring to the documentation
.[How to get token](https://docs.jocloud.com/cloud/cn/platform/restful_api/http_auth/http_auth.html)
```
    thunderEngine.joinRoom(token, roomId, uid);

    //start preview of local camera
    thunderEngine.startVideoPreview();
    
    //Start pushing local video stream
    result = thunderEngine.stopLocalVideoStream(false);

    //Start pushing local audio stream
    result = thunderEngine.stopLocalAudioStream(false);

    //Set local preview view  
    thunderEngine.setLocalVideoCanvas(canvas);
    thunderEngine.setLocalCanvasScaleMode(mode);
```

(4) Leave room
```	
    //Stop pushing local audio stream
    thunderEngine.stopLocalAudioStream(true);
    //Stop pushing local video stream
    thunderEngine.stopLocalVideoStream(true);
    //Stop preview
    thunderEngine.stopVideoPreview();
    
    thunderEngine.leaveRoom();
```

(5) Start living (join room) successfully callback, stop living (leave room) callback
```
    @Override
    public void onJoinRoomSuccess(String room, String uid, int elapsed) {
        super.onJoinRoomSuccess(room, uid, elapsed);
    }
    
    @Override
    public void onLeaveRoom(ThunderEventHandler.RoomStats status) {
        super.onLeaveRoom(status);
    }  
```

(6) Callback of Remote Audio/Video Stream <br />
        &emsp;&emsp;&emsp; If the remote video/audio stream is pushed, it means that the remote user joins the room. If the remote audio and video streams are not pushed, it means that the remote user exits the room.
```
    @Override
    public void onRemoteAudioStopped(String uid, boolean stop) {
        super.onRemoteAudioStopped(uid, stop);
    }
     
    @Override
    public void onRemoteVideoStopped(String uid, boolean stop) {
        super.onRemoteVideoStopped(uid, stop);
    }   
```

（7）Remote video stream display
```
    thunderEngine.setRemoteVideoCanvas(canvas);
    thunderEngine.setRemoteCanvasScaleMode(uid,mode);
```

(8) Turn on/off camera
```
    //Turn on camera
    thunderEngine.startVideoPreview();
    thunderEngine.stopLocalVideoStream(false);
    
    //Turn off camera
    thunderEngine.stopVideoPreview();
    thunderEngine.stopLocalVideoStream(true);
```

(9) Turn on/off microphone
```
     //Turn on microphone
     thunderEngine.stopLocalAudioStream(false);
     
     //Turn off microphone
     thunderEngine.stopLocalAudioStream(true);
```
(10) Switch front/back camera
```
     thunderEngine.switchFrontCamera(bFront);
```

(11) Receive/stop remote audio and video streaming
```
    //Receive/stop remote audio streaming
    thunderEngine.stopRemoteAudioStream(uid, stop);

    //Receive/stop remote video streaming
    thunderEngine.stopRemoteVideoStream(uid, stop);
```