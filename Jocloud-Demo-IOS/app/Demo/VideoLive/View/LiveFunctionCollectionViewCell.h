//
//  LiveFunctionCollectionViewCell.h
//  app
//
//  Created by 宁丽环 on 2020/7/8.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveFunctionModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface LiveFunctionCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) LiveFunctionModel *model;
@property (nonatomic, copy) NSString *normalImageName;
@property (nonatomic, copy) NSString *selectedImageName;
@property (nonatomic, copy) NSString *normalTitle;
@property (nonatomic, copy) NSString *selectedTitle;
@property (nonatomic, strong) UIColor *titleColor;

@end

NS_ASSUME_NONNULL_END
