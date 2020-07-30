# Use ThunderBolt and RTS SDK to implement anchor PK Line Up

*Chinese Version： [中文](README.zh.md)*

## 1.Overview
This demo describes how to implement anchor face-offs via Thunderbolt and Hummer SDK. Thunderbolt SDK offers media functions, including broadcasting, stream pushing, and subscription; Hummer SDK offers signaling interaction functions, including inviting/ accepting/rejecting/cancelling co-hosting.
![avatar](cross_channel.png)

## 2.API Calling Flow

### 2.1 Start Publishing

```objc
//Thunderbolt
    //setRoomConfig
    thunderEngine.setMediaMode(mediaMode);//set media mode
    thunderEngine.setRoomMode(roomMode);//set room mode
    //joinRoom
    thunderEngine.joinRoom(token, roomId, uid);//join room 
    thunderEngine.setLocalVideoCanvas(mPreviewView);//Set local view
    thunderEngine.setLocalCanvasScaleMode(ThunderVideoRenderMode);//set local canvas scale mode
    //push
    thunderEngine.startVideoPreview();//Start preview
    thunderEngine.stopLocalAudioStream(false);//Start audio live
    thunderEngine.stopLocalVideoStream(false);//Start video live

//RTS
    HMR.login(uid, region, token, Completion);//RTS login

```

### 2.2 Stop Publishing

```objc
//Thunderbolt
    thunderEngine.stopLocalVideoStream(true);//stop push video stream
    thunderEngine.stopLocalAudioStream(true);//stop push audio stream
    thunderEngine.stopVideoPreview();//close camera and preview
    thunderEngine.leaveRoom();//leave room

//RTS
    HMR.logout();//RTS logout
```

### 2.3 Invite to Co-Hosting

> **Note：**
>
> - You must start broadcasting before you invite, otherwise you cannot click the invite button.
> - Because it is connected across the room, the remote roomID and local roomID need to be different
> - Because Hummer signaling uses point-to-point messages, there is no concept of a room; there is a case where different rooms have the same UID, and Hummer can receive it after sending the message. It needs to be processed by the service. When the received message room number and its own At the same time, no treatment is needed.

```objc
    // Send a invitation message
    HMR.getService(PeerService.class).sendMessage(remoteUID, message,messagingOptions, completion);

    //Listen for incoming message callbacks
    onPeerMessageReceived(fromUserId, message);
```

### 2.4 Start Co-Hosting

```objc
    //set remote video canvas
    thunderEngine.setRemoteVideoCanvas(mPlayView);
    //set remote canvas scale mode
    thunderEngine.setRemoteCanvasScaleMode(remoteUid,ThunderVideoRenderMode);
    //subscribe remote
    thunderEngine.addSubscribe(remoteRoomId,remoteUid);
```

### 2.5 Stop Co-Hosting

```objc
    //stop subscribe remote
    thunderEngine.removeSubscribe(remoteRoomId, remoteUid);
```

### 2.6 Start Pushing Streams

> **Note：**
>
> - You should start publishing first before pushing streams. 
> - The streams of anchors will be pushed to the specified CDN address. Before updating the URL, you should call removePublishOriginStreamUrl to remove the  current address.
> - Only one address can be added each time the API is called, and you can call the API multiple times to add multiple addresses. No more than 5 addresses are allowed. 
> - The source streams will be pushed to the URL after publishing.
> - This API can only be called after joining a room (joinRoom) and be reset after exiting a room.

```objc
    //set live transcoding task
    thunderEngine.setLiveTranscodingTask(taskId, transcoding);
    //add publish transcoding stream Url
    thunderEngine.addPublishTranscodingStreamUrl(taskId, url);

    //The following method is called back after a successful push stream
    onPublishStreamToCDNStatus(String url, int errorCode)
```

### 2.7 Stop Pushing Streams

```objc
    //remove publish transcoding stream Url
    thunderEngine.removePublishTranscodingStreamUrl(taskId, url)
```

### 2.8 Switch Camera

```objc
    //switch front camera
    thunderEngine.switchFrontCamera(bFront);
```

### 2.9 Enable/Dsiable Camera

```objc
    //stop push video stream
    thunderEngine.stopLocalVideoStream(isStop);
```

### 2.10 Enable/Dsiable Microphone

```objc
    //stop push audio stream
    thunderEngine.stopLocalAudioStream(isStop);
```

### 2.11 Note
> - Thunderbolt does not support simultaneous login of the same account on multiple devices. If this phenomenon occurs, developers should avoid it. 

## 3 Exception Handling
| Exception                                                    | SDK Solution                                                 |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| The  remote user's network is disconnected during co-hosting | The SDK triggers the callbacks `onRemoteVideoStopped` and `onRemoteAudioStopped` to get  the remote video and audio data. If no data is returned, the remote user left the room and the SDK will cancel the subscription and send a message to inform the remote user of the unsubscription. When the remote user's network is restored,  he/she will receive this message and cancel the subscription. |
| The remote user is killing the process during co-hosting     | The SDK triggers the callbacks `onRemoteVideoStopped` and `onRemoteAudioStopped` to get the remote video and audio data. If no data is returned, the remote user left the room and the SDK will cancel the subscription and send a message to inform the remote user of the unsubscription. |