//
//  LiveView.h
//  video_samechannel
//
//  Created by GasparChu on 2020/6/5.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LiveViewDelegate <NSObject>

/// 点击图片放大
/// Click on the picture to enlarge
- (void)fullScreenGestureClicked:(UIView *)view;

@end

@interface LiveView : UIView

@property (nonatomic, strong) LiveUserModel *userModel;
@property (nonatomic, weak) id<LiveViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
