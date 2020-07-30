//
//  VideoLiveBroadcastViewController.h
//  app
//
//  Created by 宁丽环 on 2020/7/7.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoLiveBroadcastViewController : BaseViewController

@property (nonatomic, assign) BOOL isAnchor;//是否是主播

@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSString *ownerUid;

@end

NS_ASSUME_NONNULL_END
