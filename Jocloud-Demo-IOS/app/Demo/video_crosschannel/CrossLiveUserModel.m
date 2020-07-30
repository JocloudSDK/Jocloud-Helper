//
//  CrossLiveUserModel.m
//  AFNetworking
//
//  Created by Huan on 2020/6/13.
//

#import "CrossLiveUserModel.h"

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
