## 视频开播进阶用法
*[简体中文](video_advanced_README.zh.md) | [English](video_advanced_README.md)*

## 1.概览
本Demo演示以下视频开播进阶用法：
- 横竖屏开播
- 渲染模式
- 镜像
- 开关
- 档位
- 前后摄像头切换

> 集成SDK到APP，请参考：[SDK集成方法](http://test-docs.jocloud.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_ios.html)

> API开发手册，请访问： [iOS API](http://test-docs.jocloud.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/iOS/v2.9.12/category.html)

## 2.API调用流程
![avatar](advanced.png)

### 2.1 开播

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

### 2.2 下播

```objc
   [self.thunderEngine stopLocalAudioStream:NO];
   [self.thunderEngine stopLocalVideoStream:NO];
   [self.thunderEngine leaveRoom];
```

### 2.3 横竖屏开播切换

```objc
   [self.thunderEngine setVideoCaptureOrientation:orientation];
```

### 2.4 镜像设置

```objc
   [self.thunderEngine setLocalVideoMirrorMode:mode];
```

### 2.5 档位切换

```objc
   // Each time you enter the room, you need to set it again, otherwise the default configuration will be used
   [self.thunderEngine setVideoEncoderConfig:videoEncoderConfiguration];
```
### 2.6 切换摄像头

```objc
  [self.thunderEngine switchFrontCamera:bFront];
```

### 2.7 开关摄像头

```objc
   [self.thunderEngine stopLocalCapture:isSelected];
   [self.thunderEngine stopLocalVideoStream:isSelected];
```
### 2.8 开关麦克风

```objc
   [self.thunderEngine stopLocalAudioStream:sender.selected];
```

### 2.9 渲染模式设置

```objc
    if (self.isAnchor) {
        [self.thunderEngine setLocalCanvasScaleMode:mode];
        JLYLogInfo(@"UID=%@ setLocalCanvasScaleMode: %ld",self.localUid,mode);
    }else {
        [self.thunderEngine setRemoteCanvasScaleMode:self.ownerUid mode:mode];
        JLYLogInfo(@"UID=%@ setRemoteCanvasScaleMode: %ld",self.localUid,mode);
    }
```

