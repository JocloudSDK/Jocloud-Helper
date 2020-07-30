//
//  InputView.h
//  baseui
//
//  Created by GasparChu on 2020/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol InputViewDelegate <NSObject>

- (void)inputTextChanged;

@end

@interface InputView : UIView

@property (nonatomic, assign) id<InputViewDelegate> delegate;

/// 设置title
/// Set title
- (void)setTitle:(NSString *)title;

/// 设置最大长度
/// Set max length
- (void)setMaxLength:(NSInteger)maxLength;

/// 设置 placeholder
/// Set placeholder
- (void)setPlaceholder:(NSString *)placeholder;

/// 设置 text
/// Set text
- (void)setInputText:(NSString *)text;

/// 设置编辑状态
/// Set edit status
- (void)setEditStatus:(BOOL)canEdit;

- (void)setTextFieldBoardType:(UIKeyboardType)boardType;

/// 获取输入的 text
/// Get input text
- (NSString *)inputText;

@end

NS_ASSUME_NONNULL_END
