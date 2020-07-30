//
//  SameCanvasCell.h
//  video_samechannel
//
//  Created by GasparChu on 2020/6/3.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SameCanvasCellDelegate <NSObject>

/// 点击相机
/// Click camera
- (void)cameraBtnClicked:(LiveUserModel *)model stoped:(BOOL)stoped;

/// 点击麦克风
/// Click microphone
- (void)audioBtnClicked:(LiveUserModel *)model stoped:(BOOL)stoped;

@end

@interface SameCanvasCell : UICollectionViewCell

@property (nonatomic, weak) id<SameCanvasCellDelegate> delegate;

/// 设置直播用户视图
/// Set live user view
- (void)setLiveView:(LiveView * _Nullable)view;

/// 删除渲染视图的子视图
/// Delete a subview of a rendered view
- (void)removeCanvasSubviews;

@end

NS_ASSUME_NONNULL_END
