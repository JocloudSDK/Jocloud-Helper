//
//  LogFileFormat.m
//  jly_logcat
//
//  Created by GasparChu on 2020/5/28.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LogFileFormat.h"

@interface LogFileFormat ()

@property (nonatomic, strong) NSDateFormatter *formatter;   // 时间转换

@end

@implementation LogFileFormat

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *functionString = logMessage.function;
    NSUInteger line = logMessage.line;
    NSString *string = logMessage.message;
    NSString *logString = @"";
    switch (logMessage.flag) {
        case DDLogFlagInfo:
            logString = [NSString stringWithFormat:@"[%@]%@ line:%lu[info]# %@", [self getCurrentTimeString], functionString, (unsigned long)line, string];
            break;
        case DDLogFlagWarning:
            logString = [NSString stringWithFormat:@"[%@]%@ line:%lu[warn]# %@", [self getCurrentTimeString], functionString, (unsigned long)line, string];
            break;
        case DDLogFlagDebug:
            logString = [NSString stringWithFormat:@"[%@]%@ line:%lu[success]# %@", [self getCurrentTimeString], functionString, (unsigned long)line, string];
            break;
        case DDLogFlagError:
            logString = [NSString stringWithFormat:@"[%@]%@ line:%lu[error]# %@", [self getCurrentTimeString], functionString, (unsigned long)line, string];
            break;
        default:
            break;
    }
    return logString;
}

- (NSString *)getCurrentTimeString
{
    NSDate *date = [NSDate date];
    NSString *str = [self.formatter stringFromDate:date];
    return str;
}

#pragma mark - Getter & Setter
- (NSDateFormatter *)formatter
{
    if (!_formatter) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _formatter = formatter;
    }
    return _formatter;
}

@end
