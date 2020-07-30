//
//  MBProgressHUD+JLYHUD.h
//  SYLiteDevToolKit
//
//  Created by iPhuan on 2019/8/26.
//


#import "MBProgressHUD.h"

@interface MBProgressHUD (JLYHUD)

// 显示toast提示
// Show toast prompt
+ (void)jly_showToast:(NSString *)message;

+ (void)jly_showToast:(NSString *)message duration:(NSTimeInterval)duration;

// margin设置边距
// Setting margin
+ (void)jly_showToast:(NSString *)message margin:(CGFloat)margin duration:(NSTimeInterval)duration;

// 显示loading
// Show loading
+ (void)jly_showActivityIndicator;

// 显示带”加载中...“的loading
// Showing loading with "Loading..."
+ (void)jly_showLoadingActivityIndicator;

// 显示指定提示语的loading
// Display the loading of the specified prompt
+ (void)jly_showActivityIndicatorWithMessage:(NSString *)message;

// 显示loading，并设置时间
// Display loading and set the time
+ (void)jly_showLoadingActivityIndicatorWithDruation:(NSTimeInterval)duration;

+ (void)jly_hideActivityIndicator;



@end
