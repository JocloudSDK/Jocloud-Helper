//
//  LivePublicTalkView.h
//  app
//
//  Created by 宁丽环 on 2020/7/16.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface LivePublicTalkModel: NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *type;

+ (instancetype)livePublicTalkModelWithJsonString:(NSString *)jsonString;

@end

@interface LivePublicTalkView : UIView

- (void)reloadWithDataString:(NSString *)dataString;
- (void)clean;

@end

NS_ASSUME_NONNULL_END
