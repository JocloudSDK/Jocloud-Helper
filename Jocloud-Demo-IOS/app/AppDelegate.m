//
//  AppDelegate.m
//  app
//
//  Created by GasparChu on 2020/5/27.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import "HummerManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self configIQKeyboardManager];
    [[NSUserDefaults standardUserDefaults] setObject:[HummerManager sdkVersion] forKey:@"hummerVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (void)configIQKeyboardManager
{
    // Set the global clickable space to retract the keyboard
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].shouldShowToolbarPlaceholder = NO;
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = @"完成";
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0))
{
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0))
{
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.allowRotation) {
           return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskPortrait;
       } else {
           return (UIInterfaceOrientationMaskPortrait);
       }
 
}



@end
