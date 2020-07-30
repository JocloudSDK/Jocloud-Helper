## 音频开播
*[简体中文](audio_README.zh.md) | [English](audio_README.md)*

该Demo演示了如何快速集成聚联云SDK，实现音频开播。包含了以下功能：
- 加入/离开房间
- 开播音质设置
- 扬声器和听筒切换
- 开/关麦克风
- 切换前置/后置摄像头
- 开/关耳返
- 变声

> 集成SDK到APP，请参考：[SDK集成方法](http://test-docs.jocloud.com/cloud/cn/product_category/rtc_service/rt_audio_interaction/integration_and_start/integration_and_start_ios.html)

> API开发手册，请访问： [iOS API](http://test-docs.jocloud.com/cloud/cn/product_category/rtc_service/rt_audio_interaction/api/iOS/v2.9.12/category.html)

### API调用流程图
![avatar](audio_audio.png)

### API说明

（1）初始化ThunderSDK

```objc
     self.thunderEngine = [ThunderEngine createEngine:appId sceneId:sceneId delegate:delegate];
```

（2）启用说话者音量提示，打开采集音量回调

```objc
    [self.thunderEngine setAudioVolumeIndication:interval moreThanThd:0 lessThanThd:0 smooth:0]
    [self.thunderEngine enableCaptureVolumeIndication:interval moreThanThd:0 lessThanThd:0 smooth:0];
```

（3）设置sdk媒体模式，设置房间场景模式，设置音频配置

```objc
   [self.thunderEngine setRoomConfig:THUNDER_CONFIG_ONLY_AUDIO roomConfig:THUNDER_ROOM_CONFIG_MULTIAUDIOROOM];
   [self.thunderEngine setMediaMode:mediaMode];
   [self.thunderEngine setRoomMode:roomMode];
   [self.thunderEngine setAudioConfig:config commutMode:commutMode scenarioMode:scenarioMode]
```

（4）加入房间

```objc
   [self.thunderEngine joinRoom:@"" roomName:self.modulesManager.crossLocalRoomId uid:self.modulesManager.crossLocalUid];
   [self.thunderEngine stopLocalAudioStream:NO];
```

（5）离开房间

```objc
   [self.thunderEngine stopLocalAudioStream:YES];
   [self.thunderEngine leaveRoom];
```

（6）设置开播音质设置

```objc
   [self.thunderEngine setAudioConfig:self.audioConfig commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];
```

（7）扬声器和听筒切换

```objc
   [self.thunderEngine enableLoudspeaker:enableSpeaker];
```

（8）开/关麦克风

```objc
    [self.thunderEngine stopLocalAudioStream:stopped];
```

（9）开/关耳返

```objc
   [self.thunderEngine setEnableInEarMonitor:enabled];
```

（10）变声

```objc
   [self.thunderEngine setVoiceChanger:(int)mode];
```