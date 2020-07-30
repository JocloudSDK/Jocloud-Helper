//
//  LogHeader.h
//  jly_logcat
//
//  Created by GasparChu on 2020/5/27.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#ifndef LogHeader_h
#define LogHeader_h
#import "LogManager.h"

#define JLYLogInfo(frmt, ...)       LOG_MAYBE_MACRO(LogFlagInfo, frmt, ##__VA_ARGS__)
#define JLYLogWarn(frmt, ...)       LOG_MAYBE_MACRO(LogFlagWarn, frmt, ##__VA_ARGS__)
#define JLYLogSuccess(frmt, ...)    LOG_MAYBE_MACRO(LogFlagSuccess, frmt, ##__VA_ARGS__)
#define JLYLogError(frmt, ...)      LOG_MAYBE_MACRO(LogFlagError, frmt, ##__VA_ARGS__)
#define JLYLogClear                 LOG_CLEAR_DATA

#define LOG_MAYBE_MACRO(flag, frmt, ...)        \
[[LogManager sharedInstance] log:flag           \
function:__PRETTY_FUNCTION__                    \
file:__FILE__                                   \
line:__LINE__                                   \
format:(frmt), ## __VA_ARGS__];

#define LOG_CLEAR_DATA [[LogManager sharedInstance] clearAllData];

#endif /* LogHeader_h */
