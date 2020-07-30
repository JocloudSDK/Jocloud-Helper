## Multi-Person Co-Hosting in a Room
*[简体中文](README.zh.md) | [English](README.md)*

Demo of the scene with multiple people in the same room, you can connect with 4 people in the same room, enter the UID and RoomId to start broadcasting (adding room), start broadcasting (adding room), close broadcasting (exiting room), remote enter/exit room, open /Off wheat, turn on/off camera, select front/rear camera, record log information, zoom in/restore a certain view, etc. Applicable scenarios: conference, multi-player mic, multi-player game voice chat, etc. Attached:[This demo describes how to implement multi-person co-hosting in a room using Jocloud SDK. With this sample, you can:
- Join/exit a room
- Enable/disable the microphone
- Enable/disable the camera
- Switch camera
- Log information
- Zoom in or restore the view

> Integrate SDK to APP, please refer to: [SDK Integration Method](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_ios.html)

> API development manual, refer to: [iOS API](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/iOS/v2.8.0/category.html)

### API Calling Flow
![avatar](same_channel.png)

###  API Details 
 （1）Initialize Thunder SDK
 ```objc
     self.thunderEngine = [ThunderEngine createEngine:appId sceneId:sceneId delegate:delegate];
```
 
（2）Set the encoding configuration of video publishing, set the media mode, and theroom scene mode
```objc
    [self.thunderEngine setMediaMode:mediaMode];
    [self.thunderEngine setRoomMode:roomMode];
    ThunderVideoEncoderConfiguration *videoEncoderConfiguration = [[ThunderVideoEncoderConfiguration alloc] init];
    /// Set the publishing mode to co-hosting
    videoEncoderConfiguration.playType = THUNDERPUBLISH_PLAY_INTERACT;
    // Set video encoding type
    videoEncoderConfiguration.publishMode = pubishMode;
    // Reset it each time you enter the room, otherwise the default configuration will be used
    [self.thunderEngine setVideoEncoderConfig:videoEncoderConfiguration];
```

（3）Join a room
        You should get the get the [Token Access Method](https://docs.aivacom.com/cloud/cn/platform/restful_api/http_auth/http_auth.html) from the business sever.
```objc
    [self.thunderEngine joinRoom:token roomName:roomName uid:uid];
```

（4）Exit the room
```objc
    [self.thunderEngine leaveRoom];
```

（5）Callback of joining/exiting a room succeeded
```objc
    - (void)thunderEngine:(ThunderEngine *)engine onJoinRoomSuccess:(NSString *)room withUid:(NSString *)uid elapsed:(NSInteger)elapsed
    {
    
    }
    
    - (void)thunderEngine:(ThunderEngine *)engine onLeaveRoomWithStats:(ThunderRtcRoomStats *)stats
    {
    
    }
```

（6）Start publishing
```objc
    [self setVideoEncoderConfig:liveMode];
    // Set local view
    ThunderVideoCanvas *canvas = [[ThunderVideoCanvas alloc] init];
    canvas.view = preview;
    [canvas setRenderMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
    [canvas setUid:uid];
    [self.thunderEngine setLocalVideoCanvas:canvas];
    [self.thunderEngine setLocalCanvasScaleMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
    // Enable preview
    [self.thunderEngine startVideoPreview];
    // Start audio publishing
    [self.thunderEngine stopLocalAudioStream:NO];
    // Start video publishing
    [self.thunderEngine stopLocalVideoStream:NO];
```

（7）Stop publishing
```objc
    [self.thunderEngine stopLocalAudioStream:YES];
    [self.thunderEngine stopLocalVideoStream:YES];
```

（8）Callback of Remote Audio/Video Stream <br />
    &emsp;&emsp;&emsp; If the remote video/audio stream is pushed, it means that the remote user joins the room. If the remote audio and video streams are not pushed, it means that the remote user exits the room.

```objc
    - (void)thunderEngine:(ThunderEngine *)engine onRemoteAudioStopped:(BOOL)stopped byUid:(NSString *)uid
    {
        [self handleOnRemoteStreamStopped:stopped uid:uid type:RemoteStreamTypeAudio];
    }

    - (void)thunderEngine:(ThunderEngine *)engine onRemoteVideoStopped:(BOOL)stopped byUid:(NSString *)uid
    {
        [self handleOnRemoteStreamStopped:stopped uid:uid type:RemoteStreamTypeVideo];
    }  
```

（9）Enbale/disable pushing video streams
```objc
    [self.thunderEngine stopLocalVideoStream:stopped];
```

（10）Enbale/disable pushing audio streams
```objc
     [self.thunderEngine stopLocalAudioStream:stopped];
```
（11）Switch camera
```objc
     [self.thunderEngine switchFrontCamera:bFront];
```

（12）Enable/disable receiving remote audio/video streams
```objc
    // Enable/disable receiving remote audio streams
    [self.thunderEngine stopRemoteAudioStream:uid stopped:stopped];

    // Enable/disable receiving remote video streams
    [self.thunderEngine stopRemoteVideoStream:uid stopped:stopped];
```
