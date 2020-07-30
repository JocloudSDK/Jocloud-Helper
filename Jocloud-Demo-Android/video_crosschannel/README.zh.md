# 使用 Thunderbolt 和 Hummer SDK 实现主播PK连麦

[中文](README.zh.md) | [English](README.md)

## 1.概览
该Demo演示了如何结合使用Thunderbolt SDK和RTS SDK实现主播PK连麦。Thunderbolt SDK实现媒体功能，包括开播，推流和订阅；RTS SDK实现两个用户的信令交互，包括邀请连麦、同意连麦、拒绝连麦、取消连麦。
![avatar](cross_channel.png)

## 2.API调用流程

### 2.1 开播

```objc
//Thunderbolt
    //setRoomConfig
    thunderEngine.setMediaMode(mediaMode);//设置媒体模式
    thunderEngine.setRoomMode(roomMode);//设置房间模式
    //joinRoom
    thunderEngine.joinRoom(token, roomId, uid);//加入房间
    thunderEngine.setLocalVideoCanvas(mPreviewView);//设置预览
    thunderEngine.setLocalCanvasScaleMode(ThunderVideoRenderMode);//设置本地视图拉伸模式
    //push
    thunderEngine.startVideoPreview();//开启本机摄像头视频预览
    thunderEngine.stopLocalAudioStream(false);//音频开播
    thunderEngine.stopLocalVideoStream(false);//音频开播

//RTS
    HMR.login(uid, region, token, Completion);//RTS 登录

```

### 2.2 下播

```objc
//Thunderbolt
    thunderEngine.stopLocalVideoStream(true);//停止/开启本地视频(含编码)发送
    thunderEngine.stopLocalAudioStream(true);//音频关播
    thunderEngine.stopVideoPreview();//停止本机摄像头视频预览
    thunderEngine.leaveRoom();//离开房间

//RTS
    HMR.logout();//RTS 退出登录
```

### 2.3 邀请连麦

> **注意：**
>
> - 连麦前必须先开播。
> - 远端roomID和本地roomID不能相同。
> - 由于 Hummer 的端对端信令消息，在用户登录SDK后即可使用，不需要用户进入房间，所以存在一个异常情况，即用户给不同房间，与自己相同UID发送端到端的信令消息时，自己也能收到消息的通知回调。这时需要业务做处理，当收到的消息里房间号和UID信息自己的一样时，不做连麦处理。

```objc
    // 发送连麦邀请消息
    HMR.getService(PeerService.class).sendMessage(remoteUID, message,messagingOptions, completion);

    //监听收到的消息回调
    onPeerMessageReceived(fromUserId, message);
```

### 2.4 连麦

```objc
    //设置远端视图
    thunderEngine.setRemoteVideoCanvas(mPlayView);
    //设置远端拉伸模式
    thunderEngine.setRemoteCanvasScaleMode(remoteUid,ThunderVideoRenderMode);
    //订阅远端
    thunderEngine.addSubscribe(remoteRoomId,remoteUid);
```

### 2.5 取消连麦

```objc
    //取消订阅
    thunderEngine.removeSubscribe(remoteRoomId, remoteUid);
```

### 2.6 推流

> **注意：**
>
> - 推流前必须先开播。
> - 该接口需在进房间后调用，退出房间会清空该配置。
> - 调用该接口后，会将主播当前音视频流推送到指定的CDN地址。若要更新URL需要先调用 removePublishOriginStreamUrl 删除原地址后再添加。
> - 该方法每次只能增加一路推流地址。若需推送多路流，则需多次调用该方法。最多支持添加5个推流地址。
> - 开播后服务器会将源流推到对应的URL上。

```objc
    //添加转码任务
    thunderEngine.setLiveTranscodingTask(taskId, transcoding);
    //添加转码流的推流地址
    thunderEngine.addPublishTranscodingStreamUrl(taskId, url);

    //推流成功后会回调下面方法
    onPublishStreamToCDNStatus(String url, int errorCode)
```

### 2.7 停止推流

```objc
    //删除转码流的推流地址
    thunderEngine.removePublishTranscodingStreamUrl(taskId, url)
```

### 2.8 切换摄像头

```objc
    //切到前/后置摄像头
    thunderEngine.switchFrontCamera(bFront);
```

### 2.9 开关摄像头

```objc
    //停止推视频流
    thunderEngine.stopLocalVideoStream(isStop);
```

### 2.10 开关麦克风

```objc
    //停止推音频流
    thunderEngine.stopLocalAudioStream(isStop);
```

### 2.11 说明
> - thunderbolt SDK 不支持多设备同时登录，业务需要做处理多设备同时登录的问题。

## 3 异常处理
|异常|解决方法|
|:-----|:-----|
|连麦过程中，对方断网|本地判定回调onRemoteVideoStopped 和 onRemoteAudioStopped，音视频下行都没有，认为对方已经离开，主动取消订阅对方，同时发送一条消息告诉对方取消订阅对方；对方恢复网络后，会收到该消息并且取消订阅对方的音视频流|
|连麦过程中，对方杀进程|本地判定回调onRemoteVideoStopped 和 onRemoteAudioStopped，音视频下行都没有，认为对方已经离开，主动取消订阅对方，同时发送一条消息告诉对方取消订阅对方|