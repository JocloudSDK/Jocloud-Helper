//
//  ToolBarView.h
//  baseui
//
//  Created by GasparChu on 2020/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ToolBarViewDelegate <NSObject>

/// 点击摄像头切换
/// Click switch camera button
- (void)cameraSwitchClicked;

/// 点击相机
/// Click camrea button
- (void)cameraClicked;

/// 点击麦克风
- (void)audioClicked;

/// 点击反馈
/// Click feedback button
- (void)feedbackClicked;

/// 点击文档
/// Click document button
- (void)documentClicked;

/// 点击 api
/// Click api button
- (void)apiClicked;

/// 点击 log
/// Click log button
- (void)logClicked;

@end

@interface ToolBarView : UIView

@property (nonatomic, weak) id<ToolBarViewDelegate> delegate;

/// 设置相机状态
/// Set camera status
- (void)setVideoBtnStatusStopped:(BOOL)stopped;

/// 设置麦克风状态
/// Set microphone status
- (void)setAudioBtnStatusStopped:(BOOL)stopped;

- (void)hideCameraBtn:(BOOL)hide;

- (void)leftButtonsEnableAction:(BOOL)enbale;

@end

NS_ASSUME_NONNULL_END
