# Use ThunderBolt SDK to implement anchor PK Line Up

[中文](README.zh.md) | [English](README.md)

## 1.O verview
This Demo demonstrates how to implement anchor PK Linemay using Thunderbolt SDK.The Thunderbolt SDK implements media capabilities, including broadcast, push streaming, and subscription.
![avatar](cross_channel.png)

## 2.API Calling Flow

### 2.1 Start Publishing

```objc
//Thunderbolt
    //SetRoomConfig
    m_pThunderEngine->setMediaMode(mediaMode); //Set media mode
    m_pThunderEngine->setRoomMode(roomMode); //Set room mode
    //JoinRoom
    VideoCanvas canvas = { 0 };
    m_pThunderEngine->joinRoom(token, tokenLen, roomId, uid);//Join room 
    m_pThunderEngine->setLocalVideoCanvas(canvas);//Set local view
    m_pThunderEngine->setLocalCanvasScaleMode(ThunderVideoRenderMode); //Set local canvas scale mode
    
     //Start preview
    m_pThunderEngine->startVideoPreview();
    //Start video live
    m_pThunderEngine->stopLocalVideoStream(false);
    //Start audio live
    m_pThunderEngine->stopLocalAudioStream(false);
```

### 2.2 Stop Publishing

```objc
//Thunderbolt
    m_pThunderEngine->stopLocalVideoStream(true); //Stop push video stream
    m_pThunderEngine->stopLocalAudioStream(true); //Stop push audio stream
    m_pThunderEngine->stopVideoPreview(); //Close camera and preview
    m_pThunderEngine->leaveRoom(); //Leave room
```

### 2.3 Start Co-Hosting

> **Note：**
> - You must start broadcasting before you invite, otherwise you cannot click the invite button.
> - Because it is connected across the room, the remote roomID and local roomID need to be different

```objc
    VideoCanvas canvas = { 0 };
    //Set remote video canvas
    m_pThunderEngine->setRemoteVideoCanvas(canvas);
    //Set remote canvas scale mode
    m_pThunderEngine->setRemoteCanvasScaleMode(remoteUid,ThunderVideoRenderMode);
    //Subscribe remote
    m_pThunderEngine->addSubscribe(remoteRoomId,remoteUid);
```

### 2.4 Stop Co-Hosting
```objc
    //Stop subscribe remote
    m_pThunderEngine->removeSubscribe(remoteRoomId, remoteUid);
```

### 2.5 Start Pushing Streams

> **Note：**
>
> - You should start publishing first before pushing streams. 
> - The streams of anchors will be pushed to the specified CDN address. Before updating the URL, you should call removePublishOriginStreamUrl to remove the  current address.
> - Only one address can be added each time the API is called, and you can call the API multiple times to add multiple addresses. No more than 5 addresses are allowed. 
> - The source streams will be pushed to the URL after publishing.
> - This API can only be called after joining a room (joinRoom) and be reset after exiting a room.

```objc
    //Set live transcoding task
    m_pThunderEngine->setLiveTranscodingTask(taskId, transcoding);
    //Add publish transcoding stream Url
   m_pThunderEngine->addPublishTranscodingStreamUrl(taskId, url);
    //The following method is called back after a successful push stream
    virtual void onPublishStreamToCDNStatus(const char* url, ThunderPublishCDNErrorCode errorCode);
```

### 2.6 Stop Pushing Streams

```objc
    //Remove publish transcoding stream Url
    m_pThunderEngine->removePublishTranscodingStreamUrl(taskId, url)
```

### 2.7 Switch Camera

```objc
    //Switch front camera
    m_pThunderEngine->stopLocalVideoStream(isStop);
```

### 2.8 Switch Camera

```objc
    //Enable/Dsiable Microphone
    thunderEngine.stopLocalAudioStream(isStop);
```

### 2.9 Note
> - Thunderbolt does not support simultaneous login of the same UID on multiple devices. If this phenomenon occurs, developers should avoid it.

## 3 Exception Handling
| Exception                                                    | SDK Solution                                                 |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| The  remote user's network is disconnected during co-hosting | The SDK triggers the callbacks `onRemoteVideoStopped` and `onRemoteAudioStopped` to get  the remote video and audio data. If no data is returned, the remote user left the room and the SDK will cancel the subscription. |
| The remote user is killing the process during co-hosting     | The SDK triggers the callbacks `onRemoteVideoStopped` and `onRemoteAudioStopped` to get the remote video and audio data. If no data is returned, the remote user left the room and the SDK will cancel the subscription. |