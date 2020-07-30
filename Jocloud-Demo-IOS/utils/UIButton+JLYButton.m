//
//  UIButton+JLYButton.m
//  AFNetworking
//
//  Created by Huan on 2020/6/15.
//

#import "UIButton+JLYButton.h"
#import <objc/runtime.h>

const void *jly_touchDownBgColorKey = &jly_touchDownBgColorKey;
const void *jly_enableBgColorKey = &jly_enableBgColorKey;
const void *jly_disEnableBgColorKey = &jly_disEnableBgColorKey;

@implementation UIButton (JLYButton)

- (void)setJly_touchDownBgColor:(UIColor *)jly_touchDownBgColor
{
    objc_setAssociatedObject(self, jly_touchDownBgColorKey, jly_touchDownBgColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(setTouchDownBg) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(setTouchUpBg) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setJly_enableBgColor:(UIColor *)jly_enableBgColor
{
    objc_setAssociatedObject(self, jly_enableBgColorKey, jly_enableBgColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setJly_disEnableBgColor:(UIColor *)jly_disEnableBgColor
{
    objc_setAssociatedObject(self, jly_disEnableBgColorKey, jly_disEnableBgColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)jly_touchDownBgColor
{
    return objc_getAssociatedObject(self, jly_touchDownBgColorKey);
}

- (UIColor *)jly_enableBgColor
{
    return objc_getAssociatedObject(self, jly_enableBgColorKey);
}

- (UIColor *)jly_disEnableBgColor
{
    return objc_getAssociatedObject(self, jly_disEnableBgColorKey);
}

- (void)setTouchDownBg
{
    self.backgroundColor = self.jly_touchDownBgColor;
}
- (void)setTouchUpBg
{
    self.backgroundColor = self.jly_enableBgColor;
}
- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (enabled) {
        self.backgroundColor = self.jly_enableBgColor;
    } else {
        self.backgroundColor = self.jly_disEnableBgColor;
    }
}



@end
