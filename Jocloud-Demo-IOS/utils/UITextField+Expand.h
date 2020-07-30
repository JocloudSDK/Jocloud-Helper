//
//  UITextField+Expand.h
//  app
//
//  Created by 宁丽环 on 2020/7/28.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LimitBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (Expand)

@property (nonatomic, copy)LimitBlock jyl_limitBlock;

- (void)jyl_lengthLimit:(void (^)(void))limit;

@end

NS_ASSUME_NONNULL_END
