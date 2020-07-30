//
//  WhineCollectionViewCell.h
//  app
//
//  Created by 宁丽环 on 2020/7/15.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveFunctionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WhineCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, strong) LiveFunctionModel *model;
@end

NS_ASSUME_NONNULL_END
