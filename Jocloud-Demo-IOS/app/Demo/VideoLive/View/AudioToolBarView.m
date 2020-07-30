//
//  ToolBarView.m
//  baseui
//
//  Created by GasparChu on 2020/6/3.
//

#import "AudioToolBarView.h"
#import "UIImage+JLYBundle.h"
//ear
@interface AudioToolBarView ()

@property (nonatomic, strong) UIStackView *leftView;
@property (nonatomic, strong) UIStackView *rightView;
@property (nonatomic, strong) UIButton *speakerBtn;
@property (nonatomic, strong) UIButton *earBtn;
@property (nonatomic, strong) UIButton *whineBtn;
@property (nonatomic, strong) UIButton *feedbackBtn;
@property (nonatomic, strong) UIButton *documentBtn;
@property (nonatomic, strong) UIButton *apiBtn;
@property (nonatomic, strong) UIButton *logBtn;

@end

@implementation AudioToolBarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setSpeakerBtnStatusStopped:(BOOL)stopped
{
    self.speakerBtn.selected = stopped;
}

- (void)setEarBtnStatusStopped:(BOOL)stopped
{
    self.earBtn.selected = stopped;
}

- (void)setWhineBtnStatusStopped:(BOOL)stopped
{
    self.whineBtn.selected = stopped;
}


- (void)leftButtonsEnableAction:(BOOL)enbale
{
    self.earBtn.userInteractionEnabled = enbale;
    self.whineBtn.userInteractionEnabled = enbale;
    self.speakerBtn.userInteractionEnabled = enbale;
    if (enbale) {
        self.earBtn.alpha = 1;
        self.whineBtn.alpha = 1;
        self.speakerBtn.alpha = 1;
    } else {
        self.earBtn.alpha = 0.5;
        self.whineBtn.alpha = 0.5;
        self.speakerBtn.alpha = 0.5;
    }
}

- (void)setupUI
{
    [self addSubview:self.leftView];
    [self addSubview:self.rightView];
    [self.leftView addArrangedSubview:self.speakerBtn];
    [self.leftView addArrangedSubview:self.earBtn];
    [self.leftView addArrangedSubview:self.whineBtn];
    [self.rightView addArrangedSubview:self.feedbackBtn];
//    [self.rightView addArrangedSubview:self.documentBtn];
    [self.rightView addArrangedSubview:self.apiBtn];
    [self.rightView addArrangedSubview:self.logBtn];
    [self setupLayout];
}

- (void)setupLayout
{
    self.leftView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.leftView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.leftView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.leftView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:36.f];
    [self addConstraints:@[leftConstraint, topConstraint, heightConstraint]];
    
    NSLayoutConstraint *rightConstraint1 = [NSLayoutConstraint constraintWithItem:self.rightView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *topConstraint1 = [NSLayoutConstraint constraintWithItem:self.rightView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *heightConstraint1 = [NSLayoutConstraint constraintWithItem:self.leftView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:36.f];
    [self addConstraints:@[rightConstraint1, topConstraint1, heightConstraint1]];
}

#pragma mark - Event
- (void)clickspeakerBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(speakerSwitchClicked)]) {
        [self.delegate speakerSwitchClicked];
    }
}

- (void)clickearBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(earSwitchClicked)]) {
        [self.delegate earSwitchClicked];
    }
}

- (void)clickwhineBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(whineClicked)]) {
        [self.delegate whineClicked];
    }
}

- (void)clickFeedbackBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(feedbackClicked)]) {
        [self.delegate feedbackClicked];
    }
}

- (void)clickDocumentBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(documentClicked)]) {
        [self.delegate documentClicked];
    }
}

- (void)clickApiBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(apiClicked)]) {
        [self.delegate apiClicked];
    }
}

- (void)clickLogBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(logClicked)]) {
        [self.delegate logClicked];
    }
}

#pragma mark - Getter/Setter
- (UIStackView *)leftView
{
    if (!_leftView) {
        UIStackView *view = [UIStackView new];
        view.axis = UILayoutConstraintAxisHorizontal;
        view.alignment = UIStackViewAlignmentCenter;
        view.distribution = UIStackViewDistributionEqualSpacing;
        view.spacing = 12.f;
        _leftView = view;
    }
    return _leftView;
}

- (UIStackView *)rightView
{
    if (!_rightView) {
        UIStackView *view = [UIStackView new];
        view.axis = UILayoutConstraintAxisHorizontal;
        view.alignment = UIStackViewAlignmentCenter;
        view.distribution = UIStackViewDistributionEqualSpacing;
        view.spacing = 12.f;
        _rightView = view;
    }
    return _rightView;
}
/**
 arrayWithArray:@[@[[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_api" functionType:LiveFunctionTypeApi],[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_log" functionType:LiveFunctionTypeLog],[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_feedback" functionType:LiveFunctionTypefeedback]]]];
 */
/**
 _leftFunctionView.dataArray =  [NSMutableArray arrayWithArray:@[@[[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_speaker" functionType:LiveFunctionTypeSpeaker],[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_ear" functionType:LiveFunctionTypeEarReturn],[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_whine" functionType:LiveFunctionTypeEarVariety]]]];
 */
- (UIButton *)speakerBtn
{
    if (!_speakerBtn) {
        UIButton *btn = [UIButton new];
        UIImage *image = [UIImage jly_imageWithName:@"baseui_toolbar_speaker" bundle:@"baseui" targetClass:[self class]];
        UIImage *selectedImage = [UIImage jly_imageWithName:@"baseui_toolbar_speaker_s" bundle:@"baseui" targetClass:[self class]];
        [btn setImage:selectedImage forState:UIControlStateSelected];
        [btn setImage:image forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickspeakerBtn:) forControlEvents:UIControlEventTouchUpInside];
        _speakerBtn = btn;
    }
    return _speakerBtn;
}

- (UIButton *)earBtn
{
    if (!_earBtn) {
        UIButton *btn = [UIButton new];
        UIImage *selectedImage = [UIImage jly_imageWithName:@"baseui_toolbar_ear" bundle:@"baseui" targetClass:[self class]];
        UIImage *image = [UIImage jly_imageWithName:@"baseui_toolbar_ear_s" bundle:@"baseui" targetClass:[self class]];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:selectedImage forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(clickearBtn:) forControlEvents:UIControlEventTouchUpInside];
        _earBtn = btn;
    }
    return _earBtn;
}

- (UIButton *)whineBtn
{
    if (!_whineBtn) {
        UIButton *btn = [UIButton new];
        UIImage *image = [UIImage jly_imageWithName:@"baseui_toolbar_whine" bundle:@"baseui" targetClass:[self class]];
        UIImage *selectedImage = [UIImage jly_imageWithName:@"baseui_toolbar_whine_s" bundle:@"baseui" targetClass:[self class]];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:selectedImage forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(clickwhineBtn:) forControlEvents:UIControlEventTouchUpInside];
        _whineBtn = btn;
    }
    return _whineBtn;
}

- (UIButton *)feedbackBtn
{
    if (!_feedbackBtn) {
        UIButton *btn = [UIButton new];
        UIImage *image = [UIImage jly_imageWithName:@"baseui_toolbar_feedback" bundle:@"baseui" targetClass:[self class]];
        [btn setImage:image forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickFeedbackBtn:) forControlEvents:UIControlEventTouchUpInside];
        _feedbackBtn = btn;
    }
    return _feedbackBtn;
}

- (UIButton *)documentBtn
{
    if (!_documentBtn) {
        UIButton *btn = [UIButton new];
        UIImage *image = [UIImage jly_imageWithName:@"baseui_toolbar_document" bundle:@"baseui" targetClass:[self class]];
        [btn setImage:image forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickDocumentBtn:) forControlEvents:UIControlEventTouchUpInside];
        _documentBtn = btn;
    }
    return _documentBtn;
}

- (UIButton *)apiBtn
{
    if (!_apiBtn) {
        UIButton *btn = [UIButton new];
        UIImage *image = [UIImage jly_imageWithName:@"baseui_toolbar_api" bundle:@"baseui" targetClass:[self class]];
        [btn setImage:image forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickApiBtn:) forControlEvents:UIControlEventTouchUpInside];
        _apiBtn = btn;
    }
    return _apiBtn;
}

- (UIButton *)logBtn
{
    if (!_logBtn) {
        UIButton *btn = [UIButton new];
        UIImage *image = [UIImage jly_imageWithName:@"baseui_toolbar_log" bundle:@"baseui" targetClass:[self class]];
        [btn setImage:image forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickLogBtn:) forControlEvents:UIControlEventTouchUpInside];
        _logBtn = btn;
    }
    return _logBtn;
}

@end
