//
//  Interfaces.h
//  app
//
//  Created by GasparChu on 2020/6/3.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Interfaces : NSObject

/// 进入同频道连麦
/// Enter the same channel
+ (void)goToSameChannel;
/// 进入跨频道连麦
/// Enter the cross channel
+ (void)goToCrossChannel;

@end

NS_ASSUME_NONNULL_END
