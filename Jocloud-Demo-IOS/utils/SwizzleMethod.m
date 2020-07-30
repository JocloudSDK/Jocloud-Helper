//
//  SwizzleMethod.m
//  app
//
//  Created by GasparChu on 2020/6/2.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "SwizzleMethod.h"
#import <objc/runtime.h>

@implementation SwizzleMethod

+ (void)swizzleInstanceMethod:(Class)cls originSelector:(SEL)originSelector swizzleSelector:(SEL)swizzleSelector
{
    Method originalMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzleSelector);
    if (class_addMethod(cls, originSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(cls, swizzleSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
