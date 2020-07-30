//
//  UINavigationController+Base.m
//  app
//
//  Created by GasparChu on 2020/6/2.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "UINavigationController+Base.h"
#import "SwizzleMethod.h"
#import "UIImage+JLYBundle.h"

@implementation UINavigationController (Base)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SwizzleMethod swizzleInstanceMethod:self originSelector:@selector(pushViewController:animated:) swizzleSelector:@selector(jly_pushViewController:animated:)];
        [SwizzleMethod swizzleInstanceMethod:self originSelector:@selector(awakeFromNib) swizzleSelector:@selector(jly_awakeFromNib)];
    });
}

- (void)jly_awakeFromNib
{
    [self jly_awakeFromNib];
    [self.navigationBar setShadowImage:[UIImage new]];
    self.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationBar.translucent = NO;
}

- (void)jly_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSInteger originalCount = self.viewControllers.count;
    BOOL notRootVc = originalCount > 0;
    [self jly_pushViewController:viewController animated:animated];
    if (notRootVc) {
        [self setNavigationBarLeft:viewController];
    }
}

- (void)setNavigationBarLeft:(UIViewController *)controller
{
    UIImage *image = [UIImage imageNamed:@"baseui_return"];
    if (!image) {
        image = [UIImage jly_imageWithName:@"baseui_return" bundle:@"baseui" targetClass:[controller class]];
    }
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:image forState:UIControlStateNormal];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backBtn.frame = (CGRect){0, 0, 44, 44};
    backBtn.imageEdgeInsets = (UIEdgeInsets){0, -6, 0, 6};
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL selector = @selector(back);
#pragma clang diagnostic pop
    if ([controller respondsToSelector:selector]) {
        [backBtn addTarget:controller action:selector forControlEvents:UIControlEventTouchUpInside];
    } else {
        [backBtn addTarget:self action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    controller.navigationItem.leftBarButtonItems = @[itemSpace, item];
}

- (void)navBack
{
    [self popViewControllerAnimated:YES];
}

@end
