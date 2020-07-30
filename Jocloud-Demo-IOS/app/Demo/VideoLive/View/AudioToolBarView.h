//
//  ToolBarView.h
//  baseui
//
//  Created by GasparChu on 2020/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AudioToolBarViewDelegate <NSObject>

/// 点击扬声器
/// Click switch camera button
- (void)speakerSwitchClicked;

/// 点击耳返
/// Click camrea button
- (void)earSwitchClicked;

/// 点击变声
- (void)whineClicked;

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

@interface AudioToolBarView : UIView

@property (nonatomic, weak) id<AudioToolBarViewDelegate> delegate;

/// 设置扬声器状态
/// Set speaker status
- (void)setSpeakerBtnStatusStopped:(BOOL)stopped;

/// 设置耳返状态
/// Set ear status
- (void)setEarBtnStatusStopped:(BOOL)stopped;

/// 设置耳返状态
/// Set whine status
- (void)setWhineBtnStatusStopped:(BOOL)stopped;

- (void)leftButtonsEnableAction:(BOOL)enbale;

@end

NS_ASSUME_NONNULL_END
