//
//  SwizzleMethod.h
//  app
//
//  Created by GasparChu on 2020/6/2.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwizzleMethod : NSObject

+ (void)swizzleInstanceMethod:(Class)cls
               originSelector:(SEL)originSelector
              swizzleSelector:(SEL)swizzleSelector;

@end

NS_ASSUME_NONNULL_END
