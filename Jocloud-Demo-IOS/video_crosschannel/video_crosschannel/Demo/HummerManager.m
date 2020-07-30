//
//  HummerManager.m
//  AFNetworking
//
//  Created by 刘欢 on 2020/6/14.
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
    _region = @"cn/private/share";
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

- (void)addObserver:(id<HMRPeerServiceObserver>)observer
{
    [[HMRPeerService instance] addObserver:observer];
}

@end
