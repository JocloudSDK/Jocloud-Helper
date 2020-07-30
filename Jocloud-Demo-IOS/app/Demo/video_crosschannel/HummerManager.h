//
//  HummerManager.h
//  AFNetworking
//
//  Created by Huan on 2020/6/14.
//

#import <Foundation/Foundation.h>
#import <Hmr/Hmr.h>
#import <HMRRts/HMRRts.h>

NS_ASSUME_NONNULL_BEGIN

@interface HummerManager : NSObject

+ (instancetype)sharedManager;

/// 获取版本号
/// Get version
+ (NSString *)sdkVersion;

/// 获取region
/// Get region
- (NSString *)region;

/// 初始化SDK
/// Init SDK
- (void)startWithAppId:(uint64_t)appId appVersion:(NSString *)appVer eventObserver:(id<HMREventObserver>)observer;

/// 设置日志存储路径
/// Set log file path
- (void)setLoggerFilePath:(NSString *)path;

/// 登录
/// Login
- (void)loginWithUid:(uint64_t)uid region:(NSString *)region token:(NSString *)token completion:(HMRRequestCompletion)completion;

///退出
/// Logout
- (void)logout;

///加入房间
///Join Room
- (void)joinRoom:(NSString *)roomId completion:(nullable HMRRequestCompletion)completion;

///离开房间
///Leave Room
- (void)leaveRoom:(NSString *)roomId completion:(nullable HMRRequestCompletion)completion;

/// 发送点对点消息
/// Send peer message
- (void)sendPeerMessageToUser:(NSString *)uid
                      content:(NSString *)content
                         type:(NSString *)type
                       extras:(NSDictionary *)extras
                 completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

///发送广播
/// Send Broadcast Message
- (void)sendMessage:(NSString *)content
             inRoom:(NSString *)roomId
  completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

///获取房间成员列表
///Get UserList
- (void)queryMembers:(NSString *)roomId
        completion:(nullable void(^)(HMRRequestId requestId, NSArray<HMRUserId *> *members, NSError *error))completion;
///
- (void)queryRoomAttributes:(NSString *)roomId
completion:(nullable void (^)(HMRRequestId requestId,
        NSDictionary<NSString *, NSString *> *attributes,
                              NSError *error))completion;
/// 添加监听
/// Add observer
- (void)addObserver:(id<HMRPeerServiceObserver>)observer;
@end

NS_ASSUME_NONNULL_END
