//
//  LiveUserModel.h
//  video_samechannel
//
//  Created by GasparChu on 2020/6/4.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RemoteStreamType) {
    RemoteStreamTypeVideo = 0,
    RemoteStreamTypeAudio
};

@interface LiveUserModel : NSObject

// uid
@property (nonatomic, copy) NSString *uid;
// 是否是本地视频
// Whether it is a local video
@property (nonatomic, assign) BOOL localVideo;
// 视频流是否关闭
// Whether the video stream is closed
@property (nonatomic, assign) BOOL videoStoped;
// 音频流是否关闭
// Whether the audio stream is closed
@property (nonatomic, assign) BOOL audioStoped;
//扬声器关闭
// Whether the speaker is closed
@property (nonatomic, assign) BOOL speakerStoped;
//耳返关闭
// Whether the Ear return is closed
@property (nonatomic, assign) BOOL earClosed;
// 视频流是否取消订阅
// Whether the video stream is unsubscribed
@property (nonatomic, assign) BOOL videoUnSubscribe;
// 音频流是否取消订阅
// Whether the audio stream is unsubscribed
@property (nonatomic, assign) BOOL audioUnSubscribe;
// 是否是全屏状态
// Whether it is full screen
@property (nonatomic, assign) BOOL fullScreen;

- (void)updateStatusOnRemoteStopped:(BOOL)stopped type:(RemoteStreamType)type;

@end

NS_ASSUME_NONNULL_END
