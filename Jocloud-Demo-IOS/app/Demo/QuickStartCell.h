//
//  QuickStartCell.h
//  app
//
//  Created by GasparChu on 2020/6/1.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QuickStartCellDelegate <NSObject>

/// 跨房间连麦
/// Cross Channel Live
- (void)clickCrossChannel;

/// 同频道连麦
/// Same Channel Live
- (void)clickSameChannel;

@end

@interface QuickStartCell : UICollectionViewCell

@property (nonatomic, weak) id<QuickStartCellDelegate> delegate;

- (void)refreshView;

@end

NS_ASSUME_NONNULL_END
