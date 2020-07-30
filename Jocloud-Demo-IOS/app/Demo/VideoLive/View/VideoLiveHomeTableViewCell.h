//
//  VideoLiveHomeTableViewCell.h
//  app
//
//  Created by 宁丽环 on 2020/7/11.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol VideoLiveHomeTableViewCellDelegate <NSObject>
/// 创建频道
/// Create Channel Live
- (void)clickCreateChannel;

/// 进入频道
/// Join Channel Live
- (void)clickJoinChannel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface VideoLiveHomeTableViewCell : UITableViewCell

@property (nonatomic, assign) id <VideoLiveHomeTableViewCellDelegate,UITextFieldDelegate> delegate;
@property (nonatomic, assign) BOOL joinButtonEnable;
@end

NS_ASSUME_NONNULL_END
