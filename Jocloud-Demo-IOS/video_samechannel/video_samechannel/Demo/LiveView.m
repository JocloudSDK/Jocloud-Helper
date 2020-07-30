//
//  LiveView.m
//  video_samechannel
//
//  Created by GasparChu on 2020/6/5.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LiveView.h"

@implementation LiveView

- (instancetype)init
{
    self = [super init];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTapGesture:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)clickTapGesture:(UITapGestureRecognizer *)sender
{
    if ([self.delegate respondsToSelector:@selector(fullScreenGestureClicked:)]) {
        [self.delegate fullScreenGestureClicked:self];
    }
}

@end
