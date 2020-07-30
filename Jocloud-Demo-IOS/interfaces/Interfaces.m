//
//  Interfaces.m
//  app
//
//  Created by GasparChu on 2020/6/3.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "Interfaces.h"
#import "SameChannelController.h"
#import "LogHeader.h"

@implementation Interfaces

+ (void)goToSameChannel
{
    JLYLogClear
    SameChannelController *con = [SameChannelController new];
    [[self currentViewController].navigationController pushViewController:con animated:YES];
}

+ (void)goToCrossChannel
{
    
}

+ (UIViewController *)currentViewController
{
    UIWindow* window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive || windowScene.activationState == UISceneActivationStateForegroundInactive) {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
        window = [UIApplication sharedApplication].keyWindow;
    }
    UIViewController *currentViewController = window.rootViewController;
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    }
    return currentViewController;
}

@end
