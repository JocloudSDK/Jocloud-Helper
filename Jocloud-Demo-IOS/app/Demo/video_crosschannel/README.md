# Anchor Face-Offs Across Rooms via Thunderbolt SDK and Hummer SDK

* [简体中文](README.zh.md) | [English](README.md)*

## 1.Overview
This demo describes how to implement anchor face-offs via Thunderbolt and Hummer SDK. Thunderbolt SDK offers media functions, including broadcasting, stream pushing, and subscription; Hummer SDK offers signaling interaction functions, including inviting/ accepting/rejecting/cancelling co-hosting.
![cross_channel](cross_channel.png)

## 2.API Calling Flow

### 2.1 Start Publishing

```objc
    //Thunderbolt
    //joinRoom
    [self.thunderEngine joinRoom:token roomName:roomName uid:uid];
    
    //push
    [self setVideoEncoderConfig:liveMode];
    // Set local view
    [self setLocalCanvas:mPreviewContainer uid:uid];
    // Start preview
    [self.thunderEngine startVideoPreview];
    // Start audio live
    [self.thunderEngine stopLocalAudioStream:NO];
    // Start video live
    [self.thunderEngine stopLocalVideoStream:NO];

    // Login Hummer
    [Hummer loginWithUid:uid region:region token:token completion:completion];

```

### 2.2 Stop Publishing

```objc
    // Thunderbolt
    [self.thunderEngine leaveRoom];

    // Logout Hummer
    [Hummer logout];
```

### 2.3 Invite to Co-Hosting

> **Note：**
>
> - You must start broadcasting before you invite, otherwise you cannot click the invite button.
> - Because it is connected across the room, the remote roomID and local roomID need to be different
> - Because Hummer signaling uses point-to-point messages, there is no concept of a room; there is a case where different rooms have the same UID, and Hummer can receive it after sending the message. It needs to be processed by the service. When the received message room number and its own At the same time, no treatment is needed.

```objc
    // Send invitation message
    [[HMRPeerService instance] sendMessage:message withOptions:nil toUser:user completion:^(HMRRequestId reqId, NSError *error) {
        
    }];

    // Listen to the received message callbacks
    [[HMRPeerService instance] addObserver:observer];
```

### 2.4 Start Co-Hosting

```objc
    // Subscribe to remote user audio and video streams
    [self.thunderEngine addSubscribe:roomId uid:uid];
    // Show remote canvas
    ThunderVideoCanvas *canvas = [[ThunderVideoCanvas alloc] init];
    canvas.view = mPlayerViewContainer;
    [canvas setRenderMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
    [canvas setUid:remoteUid];
    [self.thunderEngine setRemoteVideoCanvas:canvas];
    [self.thunderEngine setRemoteCanvasScaleMode:remoteUid mode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
```

### 2.5 Stop Co-Hosting

```objc
    // Cancel subscription
    [self.thunderEngine removeSubscribe:roomId uid:uid];
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
    // Add a transcoding task
    [self.thunderEngine setLiveTranscodingTask:taskId transcoding:transcoding];
    // Add an address for pushing transcoding streams
    [self.thunderEngine addPublishTranscodingStreamUrl:taskId url:url];
```

### 2.7 Stop Pushing Streams

```objc
    // Delete the address of the transcoded stream
    [self.thunderEngine removePublishTranscodingStreamUrl:taskId url:url];
    // Delete the transcoding task
    [self.thunderEngine removeLiveTranscodingTask:taskId];
```

### 2.8 Switch Camera

```objc
    // Cut to the front/rear camera
    [self.thunderEngine switchFrontCamera:bFront];
```

### 2.9 Enable/Dsiable Camera

```objc
    [self.thunderEngine stopLocalVideoStream:stopped];
```

### 2.10 Enable/Dsiable Microphone

```objc
    [self.thunderEngine stopLocalAudioStream:stopped];
```

### 2.11 Note
> - Thunderbolt does not support simultaneous login of the same account on multiple devices. If this phenomenon occurs, developers should avoid it. 

## 3 Exception Handling
| Exception                                                    | SDK Solution                                                 |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| The  remote user's network is disconnected during co-hosting | The SDK triggers the callbacks `onRemoteVideoStopped` and `onRemoteAudioStopped` to get  the remote video and audio data. If no data is returned, the remote user left the room and the SDK will cancel the subscription and send a message to inform the remote user of the unsubscription. When the remote user's network is restored,  he/she will receive this message and cancel the subscription. |
| The remote user is killing the process during co-hosting     | The SDK triggers the callbacks `onRemoteVideoStopped` and `onRemoteAudioStopped` to get the remote video and audio data. If no data is returned, the remote user left the room and the SDK will cancel the subscription and send a message to inform the remote user of the unsubscription. |

