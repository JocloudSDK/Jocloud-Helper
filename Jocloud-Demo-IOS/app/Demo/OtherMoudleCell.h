//
//  OtherMoudleCell.h
//  app
//
//  Created by GasparChu on 2020/6/2.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OtherMoudleCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@end

NS_ASSUME_NONNULL_END
