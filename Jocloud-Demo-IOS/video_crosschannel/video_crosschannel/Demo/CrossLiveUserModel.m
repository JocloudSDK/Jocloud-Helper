//
//  CrossLiveUserModel.m
//  AFNetworking
//
//  Created by Huan on 2020/6/13.
//

#import "CrossLiveUserModel.h"
/*
 @property (nonatomic, assign) BOOL audioStoped;             //关闭音频
 @property (nonatomic, assign) BOOL isLive;                  //是否开播
 @property (nonatomic, assign) CanvasType canvasType;        //预览类型
 @property (nonatomic, assign) int txBitrate;                //上行码率
 @property (nonatomic, assign) int txAudioBitrate;           //上行音频
 @property (nonatomic, assign) int txVideoBitrate;           //上行视频
 @property (nonatomic, assign) int rxBitrate;                //下行码率
 @property (nonatomic, assign) int rxAudioBitrate;           //下行音频
 @property (nonatomic, assign) int rxVideoBitrate;           //下行视频
 @property (nonatomic, assign) int quality;                  //网络质量
 @property (nonatomic, copy) NSString *uid;                  //用户uid
 @property (nonatomic, copy) NSString *roomId;               //roomId
 */

@implementation CrossLiveUserModel

- (void)resetModelData
{
    _audioStoped = NO;
    _isLive = NO;
    _canvasType = CanvasTypeNone;
    _txBitrate = 0;
    _txAudioBitrate = 0;
    _txVideoBitrate = 0;
    _rxBitrate = 0;
    _rxVideoBitrate = 0;
    _rxAudioBitrate = 0;
    _quality = 0;
    _uid = @"";
    _roomId = @"";
}

@end
