# 使用 Thunderbolt 实现主播PK连麦

[中文](README.zh.md) | [English](README.md)

## 1.概览
该Demo演示了如何使用Thunderbolt SDK实现主播PK连麦。Thunderbolt SDK实现媒体功能，包括开播，推流和订阅；
![avatar](cross_channel.png)

## 2.API调用流程

### 2.1 开播

```objc
//Thunderbolt
    //setRoomConfig
    m_pThunderEngine->setMediaMode(mediaMode);//设置媒体模式
    m_pThunderEngine->setRoomMode(roomMode);//设置房间模式
    //joinRoom
    VideoCanvas canvas = { 0 };
    m_pThunderEngine->joinRoom(token, tokenLen, roomId, uid);//加入房间
    m_pThunderEngine->setLocalVideoCanvas(canvas);//设置预览
    m_pThunderEngine->setLocalCanvasScaleMode(ThunderVideoRenderMode);//设置本地视图拉伸模式
    
     //开启本地摄像头视频预览
    m_pThunderEngine->startVideoPreview();
    //视频开播
    m_pThunderEngine->stopLocalVideoStream(false);
    //音频开播
    m_pThunderEngine->stopLocalAudioStream(false);
```

### 2.2 下播

```objc
//Thunderbolt
    m_pThunderEngine->stopLocalVideoStream(true);//停止/开启本地视频(含编码)发送
    m_pThunderEngine->stopLocalAudioStream(true);//音频关播
    m_pThunderEngine->stopVideoPreview();//停止本机摄像头视频预览
    m_pThunderEngine->leaveRoom();//离开房间
```

### 2.3 连麦

> **注意：**
> - 连麦前必须先开播。
> - 远端roomID和本地roomID不能相同。

```objc
    VideoCanvas canvas = { 0 };
    //设置远端视图
    m_pThunderEngine->setRemoteVideoCanvas(canvas);
    //设置远端拉伸模式
    m_pThunderEngine->setRemoteCanvasScaleMode(remoteUid,ThunderVideoRenderMode);
    //订阅远端
    m_pThunderEngine->addSubscribe(remoteRoomId,remoteUid);
```

### 2.4 取消连麦
```objc
    //取消订阅
    m_pThunderEngine->removeSubscribe(remoteRoomId, remoteUid);
```

### 2.5 推流

> **注意：**
>
> - 推流前必须先开播。
> - 该接口需在进房间后调用，退出房间会清空该配置。
> - 调用该接口后，会将主播当前音视频流推送到指定的CDN地址。若要更新URL需要先调用 removePublishOriginStreamUrl 删除原地址后再添加。
> - 该方法每次只能增加一路推流地址。若需推送多路流，则需多次调用该方法。最多支持添加5个推流地址。
> - 开播后服务器会将源流推到对应的URL上。

```objc
    //添加转码任务
    m_pThunderEngine->setLiveTranscodingTask(taskId, transcoding);
    //添加转码流的推流地址
   m_pThunderEngine->addPublishTranscodingStreamUrl(taskId, url);
    //推流成功后会回调下面方法
    virtual void onPublishStreamToCDNStatus(const char* url, ThunderPublishCDNErrorCode errorCode);
```

### 2.6 停止推流

```objc
    //删除转码流的推流地址
    m_pThunderEngine->removePublishTranscodingStreamUrl(taskId, url)
```

### 2.7 开关摄像头

```objc
    //停止推视频流
    m_pThunderEngine->stopLocalVideoStream(isStop);
```

### 2.8 开关麦克风

```objc
    //停止推音频流
    thunderEngine.stopLocalAudioStream(isStop);
```

### 2.9 说明
> - Thunderbolt SDK 不支持同一个UID在多设备同时登录，业务需要处理多设备同时登录的问题。

## 3 异常处理
|异常|解决方法|
|:-----|:-----|
|连麦过程中，对方断网|本地判定回调onRemoteVideoStopped 和 onRemoteAudioStopped，音视频下行都没有，认为对方已经离开，主动取消订阅对方|
|连麦过程中，对方杀进程|本地判定回调onRemoteVideoStopped 和 onRemoteAudioStopped，音视频下行都没有，认为对方已经离开，主动取消订阅对方|