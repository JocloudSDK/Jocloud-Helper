//
//  InputView.m
//  baseui
//
//  Created by GasparChu on 2020/6/3.
//

#import "InputView.h"
#import "UITextField+JLYAdditions.h"
#import "UIImage+JLYBundle.h"

@interface InputView ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textFiled;
@property (nonatomic, strong) UIView *leftNormalView;
@property (nonatomic, strong) UIView *rightNormalView;
@property (nonatomic, strong) UIButton *deleteAllBtn;       
@property (nonatomic, assign) NSInteger maxLength;

@end

@implementation InputView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.titleLabel];
    [self addSubview:self.textFiled];
    [self.rightNormalView addSubview:self.deleteAllBtn];
    self.textFiled.leftView = self.leftNormalView;
    self.textFiled.rightView = self.rightNormalView;
    self.textFiled.leftViewMode = UITextFieldViewModeAlways;
    self.textFiled.rightViewMode = UITextFieldViewModeAlways;
    
    [self setupLayout];
}

- (void)setupLayout
{
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.textFiled.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:16.f];
    [self addConstraints:@[leftConstraint, rightConstraint, topConstraint, heightConstraint]];
    
    NSLayoutConstraint *leftConstraint1 = [NSLayoutConstraint constraintWithItem:self.textFiled attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint1 = [NSLayoutConstraint constraintWithItem:self.textFiled attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *topConstraint1 = [NSLayoutConstraint constraintWithItem:self.textFiled attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.textFiled attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraints:@[leftConstraint1, rightConstraint1, topConstraint1, bottomConstraint]];
}

- (void)setTextFieldBoardType:(UIKeyboardType)boardType
{
    self.textFiled.keyboardType = boardType;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setMaxLength:(NSInteger)maxLength
{
    self.textFiled.jly_maxLength = maxLength;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    self.textFiled.placeholder = placeholder;
}

- (void)setInputText:(NSString *)text
{
    self.textFiled.text = text;
}

- (void)setEditStatus:(BOOL)canEdit
{
    self.textFiled.enabled = canEdit;
    if (canEdit) {
        self.textFiled.textColor = [UIColor blackColor];
    } else {
        self.textFiled.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    }
}

- (NSString *)inputText
{
    return self.textFiled.text;
}

#pragma mark - Event
- (void)deleteAllBtnClicked:(UIButton *)sender
{
    self.textFiled.text = @"";
    self.rightNormalView.hidden = YES;
    if ([_delegate respondsToSelector:@selector(inputTextChanged)]) {
        [_delegate inputTextChanged];
    }
}

- (void)filedChanged
{
    self.rightNormalView.hidden = !self.textFiled.text.length;
    if ([_delegate respondsToSelector:@selector(inputTextChanged)]) {
        [_delegate inputTextChanged];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.rightNormalView.hidden = YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.rightNormalView.hidden = !self.textFiled.text.length;
}

#pragma mark - Getter/Setter
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        UILabel *label = [UILabel new];
        label.textColor = [UIColor colorWithRed:133/255.0 green:133/255.0 blue:133/255.0 alpha:1.0];
        label.font = [UIFont systemFontOfSize:11.f];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UITextField *)textFiled
{
    if (!_textFiled) {
        UITextField *field = [UITextField new];
        field.jly_maxLength = 8;
        field.keyboardType = UIKeyboardTypeNumberPad;
        field.delegate = self;
        field.font = [UIFont systemFontOfSize:12.f];
        field.layer.borderColor = [UIColor colorWithRed:211/255.0 green:213/255.0 blue:218/255.0 alpha:1.0].CGColor;
        field.layer.borderWidth = 0.5;
        field.layer.cornerRadius = 2;
        [field addTarget:self action:@selector(filedChanged) forControlEvents:UIControlEventEditingChanged];
        _textFiled = field;
    }
    return _textFiled;
}

- (UIView *)leftNormalView
{
    if (!_leftNormalView) {
        UIView *view = [UIView new];
        view.frame = (CGRect){0,0,5,0};
        _leftNormalView = view;
    }
    return _leftNormalView;
}

- (UIView *)rightNormalView
{
    if (!_rightNormalView) {
        UIView *view = [UIView new];
        view.frame = (CGRect){0,0,32,32};
        view.hidden = YES;
        _rightNormalView = view;
    }
    return _rightNormalView;
}

- (UIButton *)deleteAllBtn
{
    if (!_deleteAllBtn) {
        UIButton *btn = [UIButton new];
        btn.frame = (CGRect){0,0,32,32};
        UIImage *image = [UIImage imageNamed:@"baseui_delete"];
        if (!image) {
            image = [UIImage jly_imageWithName:@"baseui_delete" bundle:@"baseui" targetClass:[self class]];
        }
        [btn setImage:image forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deleteAllBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _deleteAllBtn = btn;
    }
    return _deleteAllBtn;
}

@end
