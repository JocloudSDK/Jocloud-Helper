//
//  UIImage+JLYBundle.m
//  app
//
//  Created by GasparChu on 2020/6/3.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "UIImage+JLYBundle.h"

@implementation UIImage (JLYBundle)

+ (instancetype)jly_imageWithName:(NSString *)name bundle:(NSString *)bundleName targetClass:(Class)cls
{
    NSInteger scale = [[UIScreen mainScreen] scale];
    NSBundle *curB = [NSBundle bundleForClass:cls];
    NSString *imgName = [NSString stringWithFormat:@"%@@%zdx.png", name,scale];
    NSString *dir = [NSString stringWithFormat:@"%@.bundle",bundleName];
    NSString *path = [curB pathForResource:imgName ofType:nil inDirectory:dir];
    return path?[UIImage imageWithContentsOfFile:path]:nil;
}

@end
