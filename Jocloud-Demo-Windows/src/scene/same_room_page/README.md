## Multi-User Video Call
[中文](README.zh.md) | [English](README.md)

Demo of the scene with multiple people in the same room, you can connect with 4 people in the same room, enter the UID and RoomId to start broadcasting (adding room), start broadcasting (adding room), close broadcasting (exiting room), remote enter/exit room, open /Off wheat, turn on/off camera, select front/rear camera, record log information, zoom in/restore a certain view, etc. Applicable scenarios: conference, multi-player mic, multi-player game voice chat, etc. Attached:[This demo describes how to implement multi-person co-hosting in a room using Jocloud SDK. With this sample, you can:
- Join/exit a room
- Enable/disable the microphone
- Enable/disable the camera

> Integrate SDK to APP, please refer to：[SDK Integration Method](https://docs.jocloud.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_windows.html)
> API development manual, refer to： [Windows API](https://docs.jocloud.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/Windows/v2.9.10/category.html)

### API Calling Flow
![avatar](same_channel.png)

### API Details 

（1）Initialize the ThunderSDK
 ```
   IThunderEngine* m_pThunderEngine = createEngine();
   m_pThunderEngine->initialize(appId, sceneId, pHandler);
```
 (2) Local camera, audio input and output management
 ```
    //Gets the audio input device
	AudioDeviceList audioInPutDeviceList = {0};
	m_pThunderEngine->getAudioDeviceMgr()->enumInputDevices(audioInPutDeviceList)；
	//Gets the audio output device
	AudioDeviceList audioOutPutDeviceList = {0};
	m_pThunderEngine->getAudioDeviceMgr()->enumOutputDevices(audioOutPutDeviceList)
	//Gets the Video output device
	VideoDeviceList videoDevList = {0};
	m_pThunderEngine->getVideoDeviceMgr()->enumVideoDevices(videoDevList);
 ```
（3）Set configuration of the live, set the media mode, set the room mode
```
    //Set configuration of the live
    VideoEncoderConfiguration config;
	config.playType = VIDEO_PUBLISH_PLAYTYPE_SINGLE;
	config.publishMode = VIDEO_PUBLISH_MODE_SMOOTH_DEFINITION;
	m_pThunderEngine->setVideoEncoderConfig(config); 
    //Set the media mode
	m_pThunderEngine->setMediaMode(PROFILE_NORMAL);
	//Set the room mode
	m_pThunderEngine->setRoomMode(ROOM_CONFIG_LIVE);
```

（4）Join room. The token needs to be obtained from the business server by referring to the documentation
.[How to get token](https://docs.jocloud.com/cloud/cn/platform/other/user_auth.html)
```
    //Join channel（Room）
    m_pThunderEngine->joinRoom(token, tokenLen, roomId, uid);
    
    //Open local camera
    m_pThunderEngine->getVideoDeviceMgr()->startVideoDeviceCapture(index);
    //Turn on the local microphone input device
    m_pThunderEngine->getAudioDeviceMgr()->setInputtingDevice(guid);
     //Open the local audio output device
    m_pThunderEngine->getAudioDeviceMgr()->setOutputtingDevice(guid);
    
    //Set the local preview View  
    VideoCanvas canvas = { 0 };
	canvas.renderMode = VIDEO_RENDER_MODE_CLIP_TO_BOUNDS;
	strcpy(canvas.uid, uid);
	canvas.hWnd = pSWindow->GetRealHwnd();
    m_pThunderEngine->setLocalVideoCanvas(canvas);
    m_pThunderEngine->setLocalCanvasScaleMode(mode);
    //Set to set the audio mode
    m_pThunderEngine->setAudioConfig(AUDIO_PROFILE_SPEECH_STANDARD, COMMUT_MODE_LOW, SCENARIO_MODE_STABLE_FIRST)；
    
     //start preview of local camera
    m_pThunderEngine->startVideoPreview();
    //Start pushing local video stream
    m_pThunderEngine->stopLocalVideoStream(false);
    //Start pushing local audio stream
    m_pThunderEngine->stopLocalAudioStream(false);
```

（5）Leave Room
```	
    //Stop pushing local audio stream
    m_pThunderEngine->stopLocalAudioStream(true);
    //Stop pushing local video stream
    m_pThunderEngine->stopLocalVideoStream(true);
    //Stop preview
    m_pThunderEngine->stopVideoPreview();
    //Leave room
    m_pThunderEngine->leaveRoom();
```

（6）Start living (join room) successfully callback, stop living (leave room) callback
```
    virtual void onJoinRoomSuccess(const char* roomName, const char* uid, int elapsed){
        
    }
    virtual void onLeaveRoom(){
        
    }
```

（7）Callback of Remote Audio/Video Stream <br />
        &emsp;&emsp;&emsp; If the remote video/audio stream is pushed, it means that the remote user joins the room. If the remote audio and video streams are not pushed, it means that the remote user exits the room.
```
    virtual void onRemoteAudioStopped(const char* uid, bool stop){
        
    }
    virtual void onRemoteVideoStopped(const char* uid, bool stop){
        
    }
     
```
（8）Remote video stream display
```
    m_pThunderEngine->setRemoteVideoCanvas(canvas);
    m_pThunderEngine->setRemoteCanvasScaleMode(uid,mode);
```

（9）Turn on/off camera
```
    //Turn on camera
    m_pThunderEngine->startVideoPreview();
    m_pThunderEngine->stopLocalVideoStream(false);
    
    //Turn off camera
    m_pThunderEngine->stopVideoPreview();
    m_pThunderEngine->stopLocalVideoStream(true);
```

（10）Turn on/off microphone
```
     //Turn on microphone
      m_pThunderEngine->stopLocalAudioStream(false);
     
     //Turn off microphone
      m_pThunderEngine->stopLocalAudioStream(true);
```

（11）Receive/Stop remote audio and video streaming
```
    //Receive/stop remote audio streaming
     m_pThunderEngine->stopRemoteAudioStream(uid, stop);

    //Receive/stop remote video streaming
     m_pThunderEngine->stopRemoteVideoStream(uid, stop);
```