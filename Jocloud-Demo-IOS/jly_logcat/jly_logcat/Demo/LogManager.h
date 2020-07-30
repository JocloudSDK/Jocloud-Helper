//
//  LogManager.h
//  jly_logcat
//
//  Created by GasparChu on 2020/5/27.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LogTableController.h"
#import "CocoaLumberjack.h"

typedef NS_ENUM(NSInteger, LogFlag) {
    LogFlagInfo = 0,
    LogFlagWarn,
    LogFlagSuccess,
    LogFlagError
};

NS_ASSUME_NONNULL_BEGIN

@interface LogManager : NSObject

+ (instancetype)sharedInstance;

/// log 日志控制器
@property (nonatomic, strong, readonly) LogTableController *logController;

/// 获取新 log 日志控制器
- (LogTableController *)getNewLogController;

- (void)log:(LogFlag)flag
   function:(const char *)function
       file:(const char *)file
       line:(NSUInteger)line
     format:(NSString *)format, ... NS_FORMAT_FUNCTION(5,6);

- (void)clearAllData;

@end

NS_ASSUME_NONNULL_END
