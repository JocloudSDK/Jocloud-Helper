//
//  VideoModel.m
//  video_samechannel
//
//  Created by GasparChu on 2020/6/4.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LiveUserModel.h"

@implementation LiveUserModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _videoStoped = YES;
        _audioStoped = YES;
    }
    return self;
}

- (void)updateStatusOnRemoteStopped:(BOOL)stopped type:(RemoteStreamType)type
{
    if (RemoteStreamTypeVideo == type) {
        self.videoStoped = stopped;
    } else if (RemoteStreamTypeAudio == type) {
        self.audioStoped = stopped;
    }
}

@end
