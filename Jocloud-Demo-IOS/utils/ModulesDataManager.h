//
//  MoudlesDataManager.h
//  AFNetworking
//
//  Created by Huan on 2020/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModulesDataManager : NSObject

+ (instancetype)sharedManager;


// 跨房间
// Cross channel
@property (nonatomic, copy) NSString *crossLocalRoomId;
@property (nonatomic, copy) NSString *crossLocalUid;
@property (nonatomic, copy) NSString *crossRemoteRoomId;
@property (nonatomic, copy) NSString *crossRemoteUid;
@property (nonatomic, copy) NSString *crossPushUrl;

@property (nonatomic, assign) BOOL firstCreateData;

@end

NS_ASSUME_NONNULL_END
