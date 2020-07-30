//
//  UIImage+JLYBundle.h
//  app
//
//  Created by GasparChu on 2020/6/3.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (JLYBundle)

/// 加载 bundle 图片
/// Load bundle image
+ (instancetype)jly_imageWithName:(NSString *)name
                           bundle:(NSString *)bundleName
                      targetClass:(Class)cls;


@end

NS_ASSUME_NONNULL_END
