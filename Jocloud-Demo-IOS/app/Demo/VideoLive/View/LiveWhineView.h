//
//  LiveWhineView.h
//  app
//
//  Created by 宁丽环 on 2020/7/15.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThunderManager.h"


@protocol LiveWhineViewDelegate <NSObject>

- (void)whineViewSetVoiceChanger:(ThunderRtcVoiceChangerMode)mode;
- (void)offWhine;
- (void)onWhineWithMode:(ThunderRtcVoiceChangerMode)mode;

@end
NS_ASSUME_NONNULL_BEGIN

@interface LiveWhineView : UIView

@property (nonatomic, assign) id <LiveWhineViewDelegate> delegate;

+ (instancetype)shareWhineView;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
