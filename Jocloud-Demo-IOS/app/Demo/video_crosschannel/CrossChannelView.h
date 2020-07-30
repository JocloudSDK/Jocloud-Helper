//
//  CrossChannelView.h
//  AFNetworking
//
//  Created by Huan on 2020/6/14.
//

#import <UIKit/UIKit.h>
#import "CrossLiveItemView.h"
#import "ToolBarView.h"

typedef NS_ENUM(NSInteger, InputViewType) {
    InputViewTypeLocal = 0,
    InputViewTypeRemote,
    InputViewTypeStream
};
typedef NS_ENUM(NSInteger, ButtonType) {
    ButtonTypeLocal = 0,
    ButtonTypeRemote,
    ButtonTypeStream
};

NS_ASSUME_NONNULL_BEGIN

@protocol CrossChannelViewDelegate <NSObject>

/// 开播、停播
/// Start broadcast, stop broadcast
- (void)optionLiveWithIsLive:(BOOL)isLive;

/// 连麦、断麦
/// Start live video call、End live video call
- (void)optionVideoCallWithIsConnection:(BOOL)isConnection;

/// 推流、停流
/// Start push streams、Stop push streams
- (void)optionPushStreamWithIsPush:(BOOL)isPush;

/// 点击摄像头切换
/// Switch camera
- (void)cameraSwitchClicked;

/// 点击麦克风
/// Option microphone
- (void)audioClicked;

/// 点击反馈
/// Feedback
- (void)feedbackClicked;

/// 点击文档
/// Document
- (void)documentClicked;

/// 点击 api
/// API
- (void)apiClicked;

/// 点击 log
/// Log
- (void)logClicked;


@end

@interface CrossChannelView : UIView

@property (nonatomic, assign) id<CrossChannelViewDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *localUid;
@property (nonatomic, copy, readonly) NSString *localRoomId;
@property (nonatomic, copy, readonly) NSString *remoteUid;
@property (nonatomic, copy, readonly) NSString *remoteRoomId;
@property (nonatomic, copy, readonly) NSString *pushStreamUrl;
@property (nonatomic, strong, readonly) UIButton *localPlayBtn;
@property (nonatomic, strong, readonly) UIButton *remoteConBtn;
@property (nonatomic, strong, readonly) UIButton *pushStreamBtn;
@property (nonatomic, strong, readonly) CrossLiveItemView *localLiveItemView;
@property (nonatomic, strong, readonly) CrossLiveItemView *remoteLiveItemView;
@property (nonatomic, strong, readonly) ToolBarView *toolBarView;

- (void)setRemoteUid:(NSString *)uid roomId:(NSString *)roomId;
- (void)refreshButtonEnabled;
- (void)setInputViewEnabled:(BOOL)enabled type:(InputViewType)type;
- (void)setPushBtnSelected:(BOOL)selected type:(ButtonType)type;
@end

NS_ASSUME_NONNULL_END
