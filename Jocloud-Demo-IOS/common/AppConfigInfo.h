//
//  AppConfigInfo.h
//  AFNetworking
//
//  Created by GasparChu on 2020/6/9.
//

#ifndef AppConfigInfo_h
#define AppConfigInfo_h

/// 日志地址
/// log path
#define kLogFilePath [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/JLYLogs"]
#define kInvitationTimeOutLength 16
#define kTranscodingVideoWidth 640
#define kTranscodingVideoHeight 480

/// appId
extern NSString * const kAppId;

extern NSString * const kFeedbackAppId;
extern NSString * const kFeedbackUrl;

extern NSString * const kGithubUrl;
extern NSString * const kApiUrl;

/// RTS
extern NSString * const kMessageInvite;
extern NSString * const kMessageBusy;
extern NSString * const kMessageAccept;
extern NSString * const kMessageReject;
extern NSString * const kMessageCancel;
extern NSString * const kMessageMsg;
extern NSString *const  kNoticeMsg;

#endif /* AppConfigInfo_h */
