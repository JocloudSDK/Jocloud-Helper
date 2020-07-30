//
//  ToolBarView.m
//  baseui
//
//  Created by GasparChu on 2020/6/3.
//

#import "ToolBarView.h"
#import "UIImage+JLYBundle.h"

@interface ToolBarView ()

@property (nonatomic, strong) UIStackView *leftView;
@property (nonatomic, strong) UIStackView *rightView;
@property (nonatomic, strong) UIButton *cameraSwitchBtn;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *audioBtn;
@property (nonatomic, strong) UIButton *feedbackBtn;
@property (nonatomic, strong) UIButton *documentBtn;
@property (nonatomic, strong) UIButton *apiBtn;
@property (nonatomic, strong) UIButton *logBtn;

@end

@implementation ToolBarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setVideoBtnStatusStopped:(BOOL)stopped
{
    self.cameraBtn.selected = stopped;
}

- (void)setAudioBtnStatusStopped:(BOOL)stopped
{
    self.audioBtn.selected = stopped;
}

- (void)hideCameraBtn:(BOOL)hide
{
    [self.leftView removeArrangedSubview:self.cameraBtn];
    self.cameraBtn.hidden = YES;
}

- (void)leftButtonsEnableAction:(BOOL)enbale
{
    self.cameraBtn.userInteractionEnabled = enbale;
    self.audioBtn.userInteractionEnabled = enbale;
    self.cameraSwitchBtn.userInteractionEnabled = enbale;
    if (enbale) {
        self.cameraBtn.alpha = 1;
        self.audioBtn.alpha = 1;
        self.cameraSwitchBtn.alpha = 1;
    } else {
        self.cameraBtn.alpha = 0.5;
        self.audioBtn.alpha = 0.5;
        self.cameraSwitchBtn.alpha = 0.5;
    }
}

- (void)setupUI
{
    [self addSubview:self.leftView];
    [self addSubview:self.rightView];
    [self.leftView addArrangedSubview:self.cameraSwitchBtn];
    [self.leftView addArrangedSubview:self.cameraBtn];
    [self.leftView addArrangedSubview:self.audioBtn];
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
- (void)clickCameraSwitchBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(cameraSwitchClicked)]) {
        [self.delegate cameraSwitchClicked];
    }
}

- (void)clickCameraBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(cameraClicked)]) {
        [self.delegate cameraClicked];
    }
}

- (void)clickAudioBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(audioClicked)]) {
        [self.delegate audioClicked];
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

- (UIButton *)cameraSwitchBtn
{
    if (!_cameraSwitchBtn) {
        UIButton *btn = [UIButton new];
        UIImage *image = [UIImage jly_imageWithName:@"baseui_toolbar_cameraswitch" bundle:@"baseui" targetClass:[self class]];
        [btn setImage:image forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickCameraSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
        _cameraSwitchBtn = btn;
    }
    return _cameraSwitchBtn;
}

- (UIButton *)cameraBtn
{
    if (!_cameraBtn) {
        UIButton *btn = [UIButton new];
        UIImage *image = [UIImage jly_imageWithName:@"baseui_toolbar_camera" bundle:@"baseui" targetClass:[self class]];
        UIImage *selectedImage = [UIImage jly_imageWithName:@"baseui_toolbar_uncamera" bundle:@"baseui" targetClass:[self class]];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:selectedImage forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(clickCameraBtn:) forControlEvents:UIControlEventTouchUpInside];
        _cameraBtn = btn;
    }
    return _cameraBtn;
}

- (UIButton *)audioBtn
{
    if (!_audioBtn) {
        UIButton *btn = [UIButton new];
        UIImage *image = [UIImage jly_imageWithName:@"baseui_toolbar_audio" bundle:@"baseui" targetClass:[self class]];
        UIImage *selectedImage = [UIImage jly_imageWithName:@"baseui_toolbar_unaudio" bundle:@"baseui" targetClass:[self class]];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:selectedImage forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(clickAudioBtn:) forControlEvents:UIControlEventTouchUpInside];
        _audioBtn = btn;
    }
    return _audioBtn;
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
