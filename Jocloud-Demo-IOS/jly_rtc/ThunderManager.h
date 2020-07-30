//
//  ThunderManager.h
//  app
//
//  Created by GasparChu on 2020/6/3.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThunderEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThunderManager : NSObject

+ (instancetype)sharedManager;

/// 获取版本号
+ (NSString *)getVersion;

/// create engine
- (void)createEngine:(NSString *)appId
             sceneId:(NSInteger)sceneId
            delegate:(id<ThunderEventDelegate>)delegate;

/// destroy engine
- (void)destroyEngine;

/// 设置SDK输出log文件的目录。必须指定一个有写入权限的目录。
- (void)setLogFilePath:(NSString * _Nonnull)filePath;

/// 设置房间属性
- (void)setRoomConfig:(ThunderRtcConfig)mediaMode
           roomConfig:(ThunderRtcRoomConfig)roomMode;

/// 开始推流
- (void)startPush:(UIView *)mPreviewContainer
              uid:(NSString *)uid
         liveMode:(ThunderPublishVideoMode)liveMode;

/// 停止推流
- (void)stopPush;

/// 准备远端视图
- (void)prepareRemoteView:(UIView * _Nullable)mPlayerViewContainer
                remoteUid:(NSString *)remoteUid;

/// 设置日志回调
- (void)setLogCallback:(id<ThunderRtcLogDelegate>)callback;

/// 切换摄像头
- (int)switchFrontCamera:(BOOL)bFront;

///设置开播档位
- (void)switchPublishMode:(ThunderPublishVideoMode)publishMode;

/// 进入房间
- (void)joinRoom:(NSString *)token
        roomName:(NSString *)roomName
             uid:(NSString *)uid;

/// 离开房间
- (void)leaveRoom;

/// 关闭/打开本地音频(包括音频的采集编码与上行)
- (void)stopLocalAudioStream:(BOOL)stopped;

/// 打开/关闭本地视频发送
- (void)stopLocalVideoStream:(BOOL)stopped;

///打开/关闭摄像头
- (void)stopLocalCapture:(BOOL)stopped;

/// 停止/接收指定音频数据
- (void)stopRemoteAudioStream:(NSString*_Nonnull)uid stopped:(BOOL)stopped;

/// 停止/接收指定的远端视频
- (void)stopRemoteVideoStream:(NSString* _Nonnull)uid stopped:(BOOL)stopped;

/// 停止/接收所有音频数据，默认是false
- (void)stopAllRemoteAudioStreams:(BOOL)stopped;

/// 停止／接收所有远端视频
- (void)stopAllRemoteVideoStreams:(BOOL)stopped;

///设置视频采集的方向
- (int)setVideoCaptureOrientation:(ThunderVideoCaptureOrientation)orientation;

///设置镜像
- (int)setLocalVideoMirrorMode:(ThunderVideoMirrorMode)mode;

///设置本地视图显示模式
- (int)setLocalCanvasScaleMode:(ThunderVideoRenderMode)mode;

///设置远端视图显示模式
- (int)setRemoteCanvasScaleMode:(NSString* _Nonnull)uid mode:(ThunderVideoRenderMode)mode;

///设置媒体模式
- (int)setMediaMode:(ThunderRtcConfig)mode;

///设置房间模式
- (int)setRoomMode:(ThunderRtcRoomConfig)mode;

///设置耳返
- (void)setEnableInEarMonitor:(BOOL)enabled;

///设置音频属性
- (void)setAudioConfig:(ThunderRtcAudioConfig)config
  commutMode:(ThunderRtcCommutMode)commutMode
scenarioMode:(ThunderRtcScenarioMode)scenarioMode;

///变声
- (void)setVoiceChanger:(ThunderRtcVoiceChangerMode)mode;

///设置音量回调
- (void)setAudioVolumeIndication:(NSInteger)interval;

///设置是否开启扬声器 默认扬声器音量为250
- (void)enableLoudspeaker:(BOOL)enableSpeaker;

/// 订阅指定的流【跨房间订阅】
- (void)addSubscribe:(NSString* _Nonnull)roomId uid:(NSString* _Nonnull)uid;

/// 取消流的订阅
- (void)removeSubscribe:(NSString* _Nonnull)roomId uid:(NSString* _Nonnull)uid;

/// 添加本地视频水印
- (void)setVideoWatermark:(ThunderImage *_Nonnull)watermark;

/// 添加/更新转码任务 【同一房间最大支持5个转码任务】
/// Add/update transcoding tasks [Maximum 5 transcoding tasks in the same room]
- (int)setLiveTranscodingTask:(NSString* _Nonnull)taskId transcoding:(LiveTranscoding* _Nonnull)transcoding;

/// 添加旁路推流
/// Add bypass push flow
- (int)addPublishTranscodingStreamUrl:(NSString* _Nonnull)taskId url:(NSString* _Nonnull)url;

/// 添加源路推流
/// Add source push flow
- (int)addPublishOriginStreamUrl:(NSString* _Nonnull)url;

/// 删除旁路推流
/// Remove bypass push flow
- (int)removePublishTranscodingStreamUrl:(NSString* _Nonnull)taskId url:(NSString* _Nonnull)url;

/// 删除源路推流
/// Remove bypass push flow
- (int)removePublishOriginStreamUrl:(NSString* _Nonnull)url;

/// 删除转码任务
/// Remove transcoding tasks
- (int)removeLiveTranscodingTask:(NSString* _Nonnull)taskId;


@end

NS_ASSUME_NONNULL_END
