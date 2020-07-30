//
//  ThunderManager.m
//  app
//
//  Created by GasparChu on 2020/6/3.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "ThunderManager.h"
#import "LogHeader.h"

@interface ThunderManager ()

@property (nonatomic, strong) ThunderEngine *thunderEngine;

@end

@implementation ThunderManager

+ (instancetype)sharedManager
{
    static ThunderManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (NSString *)getVersion
{
    NSString *thunderVersion = [ThunderEngine getVersion];
    NSArray *array = [thunderVersion componentsSeparatedByString:@"|"];
    if (array.count) {
        thunderVersion = array.firstObject;
    }
    NSArray *array1 = [thunderVersion componentsSeparatedByString:@"("];
    if (array1.count) {
        thunderVersion = array1.firstObject;
    }
    return thunderVersion;
}

- (void)createEngine:(NSString *)appId sceneId:(NSInteger)sceneId delegate:(id<ThunderEventDelegate>)delegate
{
    self.thunderEngine = [ThunderEngine createEngine:appId sceneId:sceneId delegate:delegate];
}

- (void)destroyEngine
{
    [ThunderEngine destroyEngine];
}

- (void)setLogFilePath:(NSString *)filePath
{
    [self.thunderEngine setLogFilePath:filePath];
}

- (void)setRoomConfig:(ThunderRtcConfig)mediaMode roomConfig:(ThunderRtcRoomConfig)roomMode
{
    [self.thunderEngine setMediaMode:mediaMode];
    [self.thunderEngine setRoomMode:roomMode];
}

- (void)startPush:(UIView *)mPreviewContainer uid:(NSString *)uid liveMode:(ThunderPublishVideoMode)liveMode
{
    [self setVideoEncoderConfig:liveMode];
    // 设置本地视图
    // Set local view display mode
    [self setLocalCanvas:mPreviewContainer uid:uid];
    // 开启预览
    // enable video preview
    int preResult = [self.thunderEngine startVideoPreview];
    // 开播 音频
    // enabling sending of local audio
    int audioResult = [self.thunderEngine stopLocalAudioStream:NO];
    // 开播 视频
    // enable sending of local video stream
    int videoResult = [self.thunderEngine stopLocalVideoStream:NO];
    if (preResult != 0 || audioResult != 0 || videoResult != 0) {
        JLYLogError(@"UID=%@ failed to publish stream preResult%d audioResult%d videoResult%d",uid,preResult,audioResult,videoResult);
    }
}

- (void)setLocalCanvas:(UIView *)preview uid:(NSString *)uid
{
    ThunderVideoCanvas *canvas = [[ThunderVideoCanvas alloc] init];
    canvas.view = preview;
    [canvas setRenderMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
    [canvas setUid:uid];
    [self.thunderEngine setLocalVideoCanvas:canvas];
    [self.thunderEngine setLocalCanvasScaleMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
}

- (void)setVideoEncoderConfig:(ThunderPublishVideoMode)pubishMode
{
    ThunderVideoEncoderConfiguration *videoEncoderConfiguration = [[ThunderVideoEncoderConfiguration alloc] init];
    /// 设置开播玩法为视频连麦开播
    // Set the start play method to start the video with wheat
    videoEncoderConfiguration.playType = THUNDERPUBLISH_PLAY_INTERACT;
    // 设置视频编码类型
    // Set video encoding type
    videoEncoderConfiguration.publishMode = pubishMode;
    // 每次进房间都需要再次设置，否则会使用默认配置
    // Each time you enter the room, you need to set it again, otherwise the default configuration will be used
    [self.thunderEngine setVideoEncoderConfig:videoEncoderConfiguration];
}

- (int)setVideoCaptureOrientation:(ThunderVideoCaptureOrientation)orientation
{
    return [self.thunderEngine setVideoCaptureOrientation:orientation];
}

- (int)setLocalVideoMirrorMode:(ThunderVideoMirrorMode)mode
{
    return [self.thunderEngine setLocalVideoMirrorMode:mode];
}

- (int)setLocalCanvasScaleMode:(ThunderVideoRenderMode)mode
{
    return [self.thunderEngine setLocalCanvasScaleMode:mode];
}

- (int)setRemoteCanvasScaleMode:(NSString * _Nonnull)uid mode:(ThunderVideoRenderMode)mode
{
    return [self.thunderEngine setRemoteCanvasScaleMode:uid mode:mode];
}

- (int)setRoomMode:(ThunderRtcRoomConfig)mode
{
    return [self.thunderEngine setRoomMode:mode];
}

- (int)setMediaMode:(ThunderRtcConfig)mode
{
    return [self.thunderEngine setMediaMode:mode];
}

- (void)setEnableInEarMonitor:(BOOL)enabled
{
   ThunderRet ret = [self.thunderEngine setEnableInEarMonitor:enabled];
    if (ret != 0) {
       JLYLogError(@"failed to setEnableInEarMonitor");
    }
}

- (void)enableLoudspeaker:(BOOL)enableSpeaker;
{
    ThunderRet ret = [self.thunderEngine enableLoudspeaker:enableSpeaker];
    if (enableSpeaker) {
        [self.thunderEngine setLoudSpeakerVolume:250];
    }
    if (ret != 0) {
        JLYLogError(@"failed to enableLoudspeaker");
    }
}

- (void)setAudioConfig:(ThunderRtcAudioConfig)config
  commutMode:(ThunderRtcCommutMode)commutMode
scenarioMode:(ThunderRtcScenarioMode)scenarioMode
{
  ThunderRet ret = [self.thunderEngine setAudioConfig:config commutMode:commutMode scenarioMode:scenarioMode];
  if (ret != 0) {
        JLYLogError(@"failed to setAudioConfig");
    }
}

- (void)setVoiceChanger:(ThunderRtcVoiceChangerMode)mode
{
   [self.thunderEngine setVoiceChanger:(int)mode];
}

- (void)setAudioVolumeIndication:(NSInteger)interval
{
    ThunderRet ret = [self.thunderEngine setAudioVolumeIndication:interval moreThanThd:0 lessThanThd:0 smooth:0];
    [self.thunderEngine enableCaptureVolumeIndication:interval moreThanThd:0 lessThanThd:0 smooth:0];
    if (ret != 0) {
        JLYLogError(@"failed to setAudioVolumeIndication error:%d",ret);
    }
}

- (void)stopPush
{
    [self.thunderEngine stopLocalAudioStream:YES];
    [self.thunderEngine stopLocalVideoStream:YES];
    [self.thunderEngine stopVideoPreview];
}

- (void)prepareRemoteView:(UIView *)mPlayerViewContainer remoteUid:(NSString *)remoteUid
{
    ThunderVideoCanvas *canvas = [[ThunderVideoCanvas alloc] init];
    canvas.view = mPlayerViewContainer;
    [canvas setRenderMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
    [canvas setUid:remoteUid];
    [self.thunderEngine setRemoteVideoCanvas:canvas];
    [self.thunderEngine setRemoteCanvasScaleMode:remoteUid mode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
}

- (void)setLogCallback:(id<ThunderRtcLogDelegate>)callback
{
    [self.thunderEngine setLogCallback:callback];
}

- (int)switchFrontCamera:(BOOL)bFront
{
    return [self.thunderEngine switchFrontCamera:bFront];
}

- (void)switchPublishMode:(ThunderPublishVideoMode)publishMode
{
    ThunderVideoEncoderConfiguration *videoEncoderConfiguration = [[ThunderVideoEncoderConfiguration alloc] init];
    // 设置开播玩法为视频连麦开播
    videoEncoderConfiguration.playType = THUNDERPUBLISH_PLAY_INTERACT;
    // 设置视频编码类型
    videoEncoderConfiguration.publishMode = publishMode;
    
    // 每次进房间都需要再次设置，否则会使用默认配置
    ThunderRet ret = [self.thunderEngine setVideoEncoderConfig:videoEncoderConfiguration];
    if (ret != 0) {
        JLYLogError(@"failed to switchPublishMode");
    }
}

- (void)joinRoom:(NSString *)token roomName:(NSString *)roomName uid:(NSString *)uid
{
    int result = [self.thunderEngine joinRoom:token roomName:roomName uid:uid];
    if (result != 0) {
        JLYLogError(@"UID=%@ failed to join roomID=%@",uid,roomName);
    }
}

- (void)leaveRoom
{
    [self.thunderEngine leaveRoom];
}


- (void)stopLocalAudioStream:(BOOL)stopped
{
    [self.thunderEngine stopLocalAudioStream:stopped];
}

- (void)stopLocalVideoStream:(BOOL)stopped
{
    [self.thunderEngine stopLocalVideoStream:stopped];
    stopped ? [self.thunderEngine stopVideoPreview] : [self.thunderEngine startVideoPreview];
}

- (void)stopLocalCapture:(BOOL)stopped
{
    [self.thunderEngine enableLocalVideoCapture:stopped];
}

- (void)stopRemoteAudioStream:(NSString *)uid stopped:(BOOL)stopped
{
    [self.thunderEngine stopRemoteAudioStream:uid stopped:stopped];
}

- (void)stopRemoteVideoStream:(NSString *)uid stopped:(BOOL)stopped
{
   ThunderRet ret = [self.thunderEngine stopRemoteVideoStream:uid stopped:stopped];
    if (ret != 0) {
       JLYLogError(@"UID=%@ failed to stopRemoteVideoStream",uid);
    }
}

- (void)stopAllRemoteAudioStreams:(BOOL)stopped
{
    [self.thunderEngine stopAllRemoteAudioStreams:stopped];
}

- (void)stopAllRemoteVideoStreams:(BOOL)stopped
{
    [self.thunderEngine stopAllRemoteVideoStreams:stopped];
}

- (void)addSubscribe:(NSString *)roomId uid:(NSString *)uid
{
    [self.thunderEngine addSubscribe:roomId uid:uid];
}

- (void)removeSubscribe:(NSString *)roomId uid:(NSString *)uid
{
    [self.thunderEngine removeSubscribe:roomId uid:uid];
}

- (void)setVideoWatermark:(ThunderImage *)watermark
{
    [self.thunderEngine setVideoWatermark:watermark];
}

- (int)setLiveTranscodingTask:(NSString *)taskId transcoding:(LiveTranscoding *)transcoding
{
    return [self.thunderEngine setLiveTranscodingTask:taskId transcoding:transcoding];
}

- (int)addPublishTranscodingStreamUrl:(NSString * _Nonnull)taskId url:(NSString * _Nonnull)url
{
    return [self.thunderEngine addPublishTranscodingStreamUrl:taskId url:url];
}

- (int)addPublishOriginStreamUrl:(NSString *)url
{
    return [self.thunderEngine addPublishOriginStreamUrl:url];
}

- (int)removePublishTranscodingStreamUrl:(NSString * _Nonnull)taskId url:(NSString * _Nonnull)url
{
    return [self.thunderEngine removePublishTranscodingStreamUrl:taskId url:url];
}

- (int)removePublishOriginStreamUrl:(NSString *)url
{
    return [self.thunderEngine removePublishOriginStreamUrl:url];
}

- (int)removeLiveTranscodingTask:(NSString * _Nonnull)taskId
{
    return [self.thunderEngine removeLiveTranscodingTask:taskId];
}


@end
