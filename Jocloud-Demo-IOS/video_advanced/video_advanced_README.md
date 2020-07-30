## Video Publishing
*[简体中文](video_advanced_README.zh.md) | [English](video_advanced_README.md)*

## 1.Overview
This demo shows the functions as below:
- Portrail/Landscape Orientation
- Render Mode
- Mirror
- Camera On/Off
- Video Quality
- Front/Rear Camera

> Integrate SDK to APP, please refer to: [SDK Integration Method](http://test-docs.jocloud.com/cloud/en/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_ios.html)

> API development manual, refer to: [iOS API](http://test-docs.jocloud.com/cloud/en/product_category/rtc_service/rt_video_interaction/api/iOS/v2.9.12/category.html)

###  2.API Call process
![avatar](advanced.png)
### 2.1 Start Publishing

```objc
   [self.thunderEngine setRoomConfig:THUNDER_CONFIG_NORMAL roomConfig:THUNDER_ROOM_CONFIG_LIVE];
   [self.thunderEngine setMediaMode:mediaMode];
   [self.thunderEngine setRoomMode:roomMode];
   [self.thunderEngine joinRoom:@"" roomName:self.roomId uid:self.ownerUid];
   [self.thunderEngine setLocalVideoCanvas:canvas];
   [self.thunderEngine setLocalCanvasScaleMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
   [self.thunderEngine startVideoPreview]
   [self.thunderEngine stopLocalAudioStream:stopped];
   [self.thunderEngine stopLocalVideoStream:stopped];
```

### 2.2 Stop Publishing

```objc
   [self.thunderEngine stopLocalAudioStream:NO];
   [self.thunderEngine stopLocalVideoStream:NO];
   [self.thunderEngine leaveRoom];
```

### 2.3 Portrail/Landscape Orientation

```objc
   [self.thunderEngine setVideoCaptureOrientation:orientation];
```

### 2.4 Mirror

```objc
   [self.thunderEngine setLocalVideoMirrorMode:mode];
```

### 2.5 Video Quality

```objc
   ///每次进房间都需要再次设置，否则会使用默认配置
   [self.thunderEngine setVideoEncoderConfig:videoEncoderConfiguration];
```

### 2.6 Front/Rear Camera

```objc
  [self.thunderEngine switchFrontCamera:bFront];
```

### 2.7 Camera On/Off

```objc
   [self.thunderEngine stopLocalCapture:isSelected];
   [self.thunderEngine stopLocalVideoStream:isSelected];
```

### 2.8 Turn on/off microphone

```objc
   [self.thunderEngine stopLocalAudioStream:sender.selected];
```

### 2.9 Render Mode
```objc
    if (self.isAnchor) {
        [self.thunderEngine setLocalCanvasScaleMode:mode];
        JLYLogInfo(@"UID=%@ setLocalCanvasScaleMode: %ld",self.localUid,mode);
    }else {
        [self.thunderEngine setRemoteCanvasScaleMode:self.ownerUid mode:mode];
        JLYLogInfo(@"UID=%@ setRemoteCanvasScaleMode: %ld",self.localUid,mode);
    }
```