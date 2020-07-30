//
//  HummerManager.h
//  AFNetworking
//
//  Created by 刘欢 on 2020/6/14.
//

#import <Foundation/Foundation.h>
#import <Hmr/Hmr.h>
#import <HMRRts/HMRRts.h>

NS_ASSUME_NONNULL_BEGIN

@interface HummerManager : NSObject

+ (instancetype)sharedManager;

/// 获取版本号
+ (NSString *)sdkVersion;

- (NSString *)region;

/// 初始化SDK
- (void)startWithAppId:(uint64_t)appId appVersion:(NSString *)appVer eventObserver:(id<HMREventObserver>)observer;

- (void)setLoggerFilePath:(NSString *)path;

- (void)loginWithUid:(uint64_t)uid region:(NSString *)region token:(NSString *)token completion:(HMRRequestCompletion)completion;

- (void)logout;

//- (void)sendMessage:(HMRMessage *)message
//withOptions:(HMRMessagingOptions *_Nullable)options
//     toUser:(HMRUserId *)user
// completion:(nullable HMRRequestCompletion)completion;

/*
- (void)addobserver;
- (void)removeObserver;
didPeerMessageReceived;
*/
@end

NS_ASSUME_NONNULL_END
