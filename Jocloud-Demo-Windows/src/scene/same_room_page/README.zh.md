## 同房间多人连麦
[中文](README.zh.md) | [English](README.md)

该Demo演示了如何快速集成聚联云SDK，实现同房间多人连麦。包含了以下功能：
- 加入/离开房间
- 开/关麦
- 开/关摄像头


> 集成SDK到APP，请参考：[SDK集成方法](https://docs.jocloud.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_windows.html)
> API开发手册，请访问： [Windows API](https://docs.jocloud.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/Windows/v2.9.10/category.html)

### API调用流程图
![avatar](same_channel.png)

### API说明

（1）初始化ThunderSDK
 ```
   IThunderEngine* m_pThunderEngine = createEngine();
   m_pThunderEngine->initialize(appId, sceneId, pHandler);
```
 (2) 本地摄像头、音频输入输出管理
 ```
    //获取音频输入设备
	AudioDeviceList audioInPutDeviceList = {0};
	m_pThunderEngine->getAudioDeviceMgr()->enumInputDevices(audioInPutDeviceList)；
	//获取音频输出设备
	AudioDeviceList audioOutPutDeviceList = {0};
	m_pThunderEngine->getAudioDeviceMgr()->enumOutputDevices(audioOutPutDeviceList)
	//获取摄像头设备
	VideoDeviceList videoDevList = {0};
	m_pThunderEngine->getVideoDeviceMgr()->enumVideoDevices(videoDevList);
 ```
（3）设置开播视频的编码配置，设置媒体模式，设置房间场景模式
```
    //设置开播视频的编码配置
    VideoEncoderConfiguration config;
	config.playType = VIDEO_PUBLISH_PLAYTYPE_SINGLE;
	config.publishMode = VIDEO_PUBLISH_MODE_SMOOTH_DEFINITION;
	m_pThunderEngine->setVideoEncoderConfig(config); 
    //设置媒体模式
	m_pThunderEngine->setMediaMode(PROFILE_NORMAL);
	//设置房间场景模式
	m_pThunderEngine->setRoomMode(ROOM_CONFIG_LIVE);
```

（4）加入房间 从业务服务器获取[token接入方法](https://docs.jocloud.com/cloud/cn/platform/other/user_auth.html)
```
    //加入频道（房间）
    m_pThunderEngine->joinRoom(token, tokenLen, roomId, uid);
    
    //打开本地摄像头视频，index为enumVideoDevices（）获取的视频设备索引
    m_pThunderEngine->getVideoDeviceMgr()->startVideoDeviceCapture(index);
    //打开本地麦克风输入设备，guid为enumInputDevices（）获取的音频输入设备id
    m_pThunderEngine->getAudioDeviceMgr()->setInputtingDevice(guid);
     //打开本地音频输出设备，guid为enumOutputDevices（）获取的音频输入设备id
    m_pThunderEngine->getAudioDeviceMgr()->setOutputtingDevice(guid);
    
    //设置本地预览view  
    VideoCanvas canvas = { 0 };
	canvas.renderMode = VIDEO_RENDER_MODE_CLIP_TO_BOUNDS;
	strcpy(canvas.uid, uid);
	canvas.hWnd = pSWindow->GetRealHwnd();
    m_pThunderEngine->setLocalVideoCanvas(canvas);
    m_pThunderEngine->setLocalCanvasScaleMode(mode);
    //设置设置音频模式
    m_pThunderEngine->setAudioConfig(AUDIO_PROFILE_SPEECH_STANDARD, COMMUT_MODE_LOW, SCENARIO_MODE_STABLE_FIRST)；
    
     //开启本地摄像头视频预览
    m_pThunderEngine->startVideoPreview();
    //开始推送本地视频流
    m_pThunderEngine->stopLocalVideoStream(false);
    //开始推送本地音频流
    m_pThunderEngine->stopLocalAudioStream(false);
```

（5）离开房间
```	
    //停止推送本地音频流
    m_pThunderEngine->stopLocalAudioStream(true);
    //停止推送本地视频流
    m_pThunderEngine->stopLocalVideoStream(true);
    //关闭本地预览
    m_pThunderEngine->stopVideoPreview();
    //关闭本地摄像头
    m_pThunderEngine->getVideoDeviceMgr()->stopVideoDeviceCapture();
    //离开房间
    m_pThunderEngine->leaveRoom();
```

（6）加入房间成功回调，离开房间回调
```
    virtual void onJoinRoomSuccess(const char* roomName, const char* uid, int elapsed){
        //加入房间成功回调
    }
    virtual void onLeaveRoom(){
        //离开房间回调
    }
```

（7）远端音频、视频流回调通知（当有音频或视频加入房间时表示远端加入房间，如果音频与视频都关闭则为远端关播）
```
    virtual void onRemoteAudioStopped(const char* uid, bool stop){
        
    }
    virtual void onRemoteVideoStopped(const char* uid, bool stop){
        
    }
     
```
（8）远端视频展示
```
    m_pThunderEngine->setRemoteVideoCanvas(canvas);
    m_pThunderEngine->setRemoteCanvasScaleMode(uid,mode);
```

（9）打开/关闭摄像头
```
    //打开摄像头
    m_pThunderEngine->startVideoPreview();
    m_pThunderEngine->stopLocalVideoStream(false);
    
    //关闭摄像头
    m_pThunderEngine->stopVideoPreview();
    m_pThunderEngine->stopLocalVideoStream(true);
```

（10）打开/关闭麦克风
```
     //打开麦克风
      m_pThunderEngine->stopLocalAudioStream(false);
     
     //关闭麦克风
      m_pThunderEngine->stopLocalAudioStream(true);
```

（11）接收/关闭远端音频、视频流
```
    //接收/关闭远端音频流
     m_pThunderEngine->stopRemoteAudioStream(uid, stop);

    //接收/关闭远端视频流
     m_pThunderEngine->stopRemoteVideoStream(uid, stop);
```