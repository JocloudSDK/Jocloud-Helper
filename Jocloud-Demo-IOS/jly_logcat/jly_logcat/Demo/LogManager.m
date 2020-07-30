//
//  LogManager.m
//  jly_logcat
//
//  Created by GasparChu on 2020/5/27.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LogManager.h"
#import "LogModel.h"
#import "LogFileFormat.h"
#import "AppConfigInfo.h"

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface LogManager ()<DDLogFormatter>

// 本地存储的日志格式
// Locally stored log format
@property (nonatomic, strong) LogFileFormat *fileFormat;
@property (nonatomic, strong, readwrite) LogTableController *logController;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableArray *logMArr;

@end

@implementation LogManager

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance setup];
        [sharedInstance configCocoaLumberjack];
    });
    return sharedInstance;
}

- (void)clearAllData
{
    [self.logMArr removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.logController setData:self.logMArr.copy];
    });
}

- (LogTableController *)getNewLogController
{
    LogTableController *con = [LogTableController new];
    [con setData:self.logMArr.copy];
    return con;
}

- (void)setup
{
    self.logController = [LogTableController new];
    self.fileFormat = [LogFileFormat new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)configCocoaLumberjack
{
    // 设置存储路径
    // Set log file path
    NSString *logPath = kLogFilePath;
    DDLogFileManagerDefault *documentsFileManager = [[DDLogFileManagerDefault alloc]
                                                     initWithLogsDirectory:[logPath stringByAppendingPathComponent:@"jly_logcat"]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc]
                                initWithLogFileManager:documentsFileManager];
    fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    fileLogger.maximumFileSize = 1024 * 1024;
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFormatter = self.fileFormat;
    [DDLog addLogger:fileLogger];

    // 添加DDASLLogger，你的日志语句将被发送到Xcode控制台
    // Add DDASLLogger and your log statement will be sent to the Xcode console
    [DDLog addLogger:[DDOSLogger sharedInstance]];
    
    // 设置打印格式
    // Set print format
    [DDOSLogger sharedInstance].logFormatter = self;
}

- (void)log:(LogFlag)flag function:(const char *)function file:(const char *)file line:(NSUInteger)line format:(NSString *)format, ...
{
    [self.lock lock];
    if (format) {
        va_list args;
        va_start(args, format);
        NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        [self log:flag function:function file:file line:line string:logString];
    }
    [self.lock unlock];
}

- (void)log:(LogFlag)flag function:(const char *)function file:(const char *)file line:(NSUInteger)line string:(NSString *)string
{
    NSString *logString = @"";
    LogModel *model = [LogModel new];
    DDLogFlag ddFlag = DDLogFlagInfo;
    switch (flag) {
        case LogFlagInfo:
            logString = [NSString stringWithFormat:@"[%@] %@", [self getCurrentTimeString], string];
            model.textColor = [UIColor colorWithRed:133/255.0 green:133/255.0 blue:133/255.0 alpha:1.0];
            ddFlag = DDLogFlagInfo;
            break;
        case LogFlagWarn:
            logString = [NSString stringWithFormat:@"[%@] %@", [self getCurrentTimeString], string];
            model.textColor = [UIColor yellowColor];
            ddFlag = DDLogFlagWarning;
            break;
        case LogFlagSuccess:
            logString = [NSString stringWithFormat:@"[%@] %@", [self getCurrentTimeString], string];
            model.textColor = [UIColor greenColor];
            ddFlag = DDLogFlagDebug;
            break;
        case LogFlagError:
            logString = [NSString stringWithFormat:@"[%@] %@", [self getCurrentTimeString], string];
            model.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];;
            ddFlag = DDLogFlagError;
            break;
        default:
            break;
    }
    model.text = logString;
    [self.logMArr addObject:model];
    
    [DDLog log:LOG_ASYNC_ENABLED level:LOG_LEVEL_DEF flag:ddFlag context:0 file:file function:function line:line tag:nil format:@"%@", string];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.logController.view.superview) {
            [self.logController setData:self.logMArr.copy];
        }
    });
}

- (NSString *)getCurrentTimeString
{
    NSDate *date = [NSDate date];
    NSString *str = [self.formatter stringFromDate:date];
    return str;
}

- (void)receiveMemoryWarning
{
    [self.logMArr removeAllObjects];
    [self log:LogFlagWarn
     function:__FUNCTION__
         file:__FILE_NAME__
         line:__LINE__
       format:@"memory warning! remove all logs"];
}

#pragma mark - DDLogFormatter
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *functionString = logMessage.function;
    NSUInteger line = logMessage.line;
    NSString *string = logMessage.message;
    NSString *logString = @"";
    switch (logMessage.flag) {
        case DDLogFlagInfo:
            logString = [NSString stringWithFormat:@"%@ line:%lu[info]# %@", functionString, (unsigned long)line, string];
            break;
        case DDLogFlagWarning:
            logString = [NSString stringWithFormat:@"%@ line:%lu[warn]# %@", functionString, (unsigned long)line, string];
            break;
        case DDLogFlagDebug:
            logString = [NSString stringWithFormat:@"%@ line:%lu[success]# %@", functionString, (unsigned long)line, string];
            break;
        case DDLogFlagError:
            logString = [NSString stringWithFormat:@"%@ line:%lu[error]# %@", functionString, (unsigned long)line, string];
            break;
        default:
            break;
    }
    
    return logString;
}

#pragma mark - Getter & Setter
- (NSDateFormatter *)formatter
{
    if (!_formatter) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MM-dd HH:mm:ss"];
        _formatter = formatter;
    }
    return _formatter;
}

- (NSLock *)lock
{
    if (!_lock) {
        NSLock *lock = [NSLock new];
        _lock = lock;
    }
    return _lock;
}

- (NSMutableArray *)logMArr
{
    if (!_logMArr) {
        NSMutableArray *mArr = [NSMutableArray array];
        _logMArr = mArr;
    }
    return _logMArr;
}

@end
