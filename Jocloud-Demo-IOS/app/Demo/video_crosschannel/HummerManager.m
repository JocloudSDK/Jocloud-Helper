//
//  HummerManager.m
//  AFNetworking
//
//  Created by Huan on 2020/6/14.
//

#import "HummerManager.h"
#import "Utils.h"

@interface HummerManager()

@property (nonatomic, copy) NSString *region;

@end

@implementation HummerManager

+ (instancetype)sharedManager
{
    static HummerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (NSString *)sdkVersion
{
    return [Hummer sdkVersion];
}

- (NSString *)region
{
    _region = @"cn";
    return _region;
}

- (void)startWithAppId:(uint64_t)appId appVersion:(NSString *)appVer eventObserver:(id<HMREventObserver>)observer
{
    [Hummer startWithAppId:appId appVersion:appVer eventObserver:observer];
}

- (void)setLoggerFilePath:(NSString *)path
{
    [Hummer setLoggerFilePath:path];
}

- (void)loginWithUid:(uint64_t)uid region:(NSString *)region token:(NSString *)token completion:(HMRRequestCompletion)completion
{
    [Hummer loginWithUid:uid region:region token:token completion:completion];
}

- (void)logout
{
    [Hummer logout];
}

- (void)joinRoom:(NSString *)roomId completion:(nullable HMRRequestCompletion)completion
{
    HMRRoomId *roomid = [HMRRoomId roomWithID:roomId];
    [[HMRRoomService instance] joinRoom:roomid withAppExtras:nil options:nil completion:completion];

}

- (void)leaveRoom:(NSString *)roomId completion:(nullable HMRRequestCompletion)completion
{
    HMRRoomId *roomid = [HMRRoomId roomWithID:roomId];
    [[HMRRoomService instance]leaveRoom:roomid completion:completion];
}

- (void)sendPeerMessageToUser:(NSString *)uid content:(nonnull NSString *)content type:(nonnull NSString *)type extras:(nonnull NSDictionary *)extras completionHandler:(void (^_Nullable)(NSError * _Nullable))completionHandler
{
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    HMRMessage *message = [HMRMessage messageWithType:type content:data appExtras:extras];
    HMRUserId *user = [HMRUserId userWithID:uid.longLongValue];
    [[HMRPeerService instance] sendMessage:message withOptions:nil toUser:user completion:^(HMRRequestId reqId, NSError *error) {
        if (error) {
            completionHandler(error);
        } else {
            completionHandler(nil);
        }
    }];
}

- (void)sendMessage:(NSString *)content
           inRoom:(NSString *)roomId
completionHandler:(void (^_Nullable)(NSError * _Nullable error))completionHandler
{
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    HMRMessage *message = [HMRMessage messageWithType:nil content:data appExtras:nil];
    HMRRoomId *roomid = [HMRRoomId roomWithID:roomId];
    [[HMRRoomService instance] sendMessage:message withOptions:nil inRoom:roomid completion:^(HMRRequestId reqId, NSError *error) {
        if (error) {
            completionHandler(error);
        } else {
            completionHandler(nil);
        }
    }];
}

- (void)queryMembers:(NSString *)roomId
completion:(nullable void(^)(HMRRequestId requestId
    , NSArray<HMRUserId *> *members
    , NSError *error))completion
{
    HMRRoomId *roomid = [HMRRoomId roomWithID:roomId];
    [[HMRRoomService instance] queryMembers:roomid completion:completion];
}

- (void)queryRoomAttributes:(NSString *)roomId
completion:(nullable void (^)(HMRRequestId requestId,
        NSDictionary<NSString *, NSString *> *attributes,
        NSError *error))completion
{
    HMRRoomId *roomid = [HMRRoomId roomWithID:roomId];
    [[HMRRoomService instance] queryRoomAttributes:roomid completion:completion];
}


- (void)queryRoomAttributes:(NSString *)roomId
    byKeys:(NSSet <NSString *> *)keys
completion:(nullable void (^)(HMRRequestId requestId,
        NSDictionary<NSString *, NSString *> *attributes,
        NSError *error))completion
{
    HMRRoomId *roomid = [HMRRoomId roomWithID:roomId];
    [[HMRRoomService instance] queryRoomAttributes:roomid byKeys:keys completion:completion];
}

- (void)addObserver:(id<HMRPeerServiceObserver,HMRRoomObserver,HMRRoomMemberObserver>)observer
{
    [[HMRPeerService instance] addObserver:observer];
    [[HMRRoomService instance] addRoomObserver:observer];
    [[HMRRoomService instance] addMemberObserver:observer];

}

@end
