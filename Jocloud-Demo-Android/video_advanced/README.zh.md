## 视频开播进阶用法
[中文](README.zh.md) | [English](README.md)

## 1.概览
该Demo演示了如何使用聚联云音视频SDK实现以下视频开播的高级功能：
- 横竖屏开播
- 显示窗口渲染模式切换，拉伸铺满窗口、适应窗口等
- 镜像显示
- 开关摄像头
- 清晰度档位切换
- 前后摄像头切换
![avatar](advanced.png)

## 2.API调用流程

### 2.1 开播

```objc
    //setRoomConfig
    thunderEngine.setMediaMode(mediaMode);
    thunderEngine.setRoomMode(roomMode);
    //joinRoom
    thunderEngine.joinRoom(token, roomId, uid);
    thunderEngine.setLocalVideoCanvas(mPreviewView);
    thunderEngine.setLocalCanvasScaleMode(ThunderVideoRenderMode);
    //push
    thunderEngine.startVideoPreview();
    thunderEngine.stopLocalAudioStream(false);
    thunderEngine.stopLocalVideoStream(false);
```

### 2.2 下播

```objc
    thunderEngine.stopLocalVideoStream(true);
    thunderEngine.stopLocalAudioStream(true);
    thunderEngine.stopVideoPreview();
    thunderEngine.setLocalVideoCanvas(null);
    thunderEngine.setRemoteVideoCanvas(null);
    thunderEngine.leaveRoom();
```

### 2.3 横竖屏开播切换

```objc
    thunderEngine.setVideoCaptureOrientation(orientation);
```

### 2.4 镜像设置

```objc
    thunderEngine.setLocalVideoMirrorMode(mirrorMode);
```

### 2.5 档位切换

```objc
    thunderEngine.setVideoEncoderConfig(ThunderVideoEncoderConfiguration);
```


### 2.6 切换摄像头

```objc
    thunderEngine.switchFrontCamera(bFront);
```

### 2.7 开关摄像头

```objc
    thunderEngine.enableLocalVideoCapture(false);
    thunderEngine.stopLocalVideoStream(isStop);
```

### 2.8 开关音频采集与推流

```objc
    thunderEngine.stopLocalAudioStream(isStop);
```

### 2.9 渲染模式设置

```objc
    thunderEngine.setLocalCanvasScaleMode(ThunderVideoRenderMode);
    thunderEngine.setRemoteCanvasScaleMode(UID,ThunderVideoRenderMode);
```