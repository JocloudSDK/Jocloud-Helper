//
//  CrossChannelView.m
//  AFNetworking
//
//  Created by Huan on 2020/6/14.
//

#import "CrossChannelView.h"
#import "NSBundle+Language.h"
#import "InputView.h"
#import "ToolBarView.h"
#import "Masonry.h"
#import "Utils.h"
#import "BaseMacro.h"
#import "LogHeader.h"
#import "UIButton+JLYButton.h"
#import "AFNetworking.h"
#import "MBProgressHUD+JLYHUD.h"
#import "CrossLiveUserModel.h"


@interface CrossChannelView()<ToolBarViewDelegate, InputViewDelegate>

@property (nonatomic, strong) InputView *localUidView;
@property (nonatomic, strong) InputView *localRoomidView;
@property (nonatomic, strong) UIButton *playBtn;



@property (nonatomic, strong) InputView *remoteUidView;
@property (nonatomic, strong) InputView *remoteRoomidView;
@property (nonatomic, strong) UIButton *connectionBtn;

@property (nonatomic, strong) InputView *pushStreamView;
@property (nonatomic, strong) UIButton *pushBtn;

@property (nonatomic, strong) ToolBarView *toolView;
@property (nonatomic, strong) UIView *logView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIView *liveView;

@property (nonatomic, strong) CrossLiveItemView *localLiveView;
@property (nonatomic, strong) CrossLiveItemView *remoteLiveView;

@end

@implementation CrossChannelView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setRemoteUid:(NSString *)uid roomId:(NSString *)roomId
{
    [self.remoteUidView setInputText:uid];
    [self.remoteRoomidView setInputText:roomId];
    self.connectionBtn.enabled = YES;
    self.connectionBtn.selected = YES;
}

- (void)refreshButtonEnabled
{
    [self inputTextChanged];
}

- (void)setInputViewEnabled:(BOOL)enabled type:(InputViewType)type
{
    switch (type) {
        case InputViewTypeLocal: {
            [self.localUidView setEditStatus:enabled];
            [self.localRoomidView setEditStatus:enabled];
        }
            break;
        case InputViewTypeRemote: {
            [self.remoteUidView setEditStatus:enabled];
            [self.remoteRoomidView setEditStatus:enabled];
        }
            break;
        case InputViewTypeStream: {
            [self.pushStreamView setEditStatus:enabled];
        }
            break;
        default:
            break;
    }
}

#pragma mark - buttonClick
- (void)clickPlayBtn
{
    if (self.localUidView.inputText.length == 0 || self.localRoomidView.inputText.length == 0) {
        return;
    }
    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (AFNetworkReachabilityStatusUnknown == netStatus || AFNetworkReachabilityStatusNotReachable == netStatus) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"网络异常"]];
        return;
    }
    if ([_delegate respondsToSelector:@selector(optionLiveWithIsLive:)]) {
        BOOL isLive = self.playBtn.isSelected ? NO : YES;
        [_delegate optionLiveWithIsLive:isLive];
    }
}

- (void)clickConnectionBtn
{
    if (self.remoteUidView.inputText.length == 0 || self.remoteRoomidView.inputText.length == 0) {
        return;
    }
    if ([self.remoteRoomidView.inputText isEqualToString:self.localRoomidView.inputText]) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"请输入不同Room ID"]];
        return;
    }
    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (AFNetworkReachabilityStatusUnknown == netStatus || AFNetworkReachabilityStatusNotReachable == netStatus) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"网络异常"]];
        return;
    }
    if ([_delegate respondsToSelector:@selector(optionVideoCallWithIsConnection:)]) {
        BOOL isCon = self.connectionBtn.isSelected ? NO : YES;
        [_delegate optionVideoCallWithIsConnection:isCon];
    }
}

- (void)clickPushBtn
{
    if (self.pushStreamView.inputText.length == 0) {
        return;
    }
    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (AFNetworkReachabilityStatusUnknown == netStatus || AFNetworkReachabilityStatusNotReachable == netStatus) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"网络异常"]];
        return;
    }
    if ([_delegate respondsToSelector:@selector(optionPushStreamWithIsPush:)]) {
        BOOL isPush = self.pushStreamBtn.isSelected ? NO : YES;
        [_delegate optionPushStreamWithIsPush:isPush];
        self.pushStreamBtn.selected = isPush;
    }
}

#pragma mark - InputViewDelegate
- (void)inputTextChanged
{
    if (self.localUidView.inputText.length == 0 || self.localRoomidView.inputText.length == 0) {
        self.playBtn.enabled = NO;
    } else {
        self.playBtn.enabled = YES;
    }
    if (self.remoteUidView.inputText.length == 0 || self.remoteRoomidView.inputText.length == 0 || !self.localLiveItemView.userModel.isLive) {
        self.connectionBtn.enabled = NO;
    } else {
        self.connectionBtn.enabled = YES;
    }
    if (self.pushStreamView.inputText.length == 0 || !self.localLiveItemView.userModel.isLive) {
        self.pushBtn.enabled = NO;
    } else {
        self.pushBtn.enabled = YES;
    }
}

#pragma mark - ToolBarViewDelegate
- (void)cameraSwitchClicked
{
    if ([_delegate respondsToSelector:@selector(cameraSwitchClicked)]) {
        [_delegate cameraSwitchClicked];
    }
}

- (void)audioClicked
{
    if ([_delegate respondsToSelector:@selector(audioClicked)]) {
        [_delegate audioClicked];
    }
}

- (void)feedbackClicked
{
    if ([_delegate respondsToSelector:@selector(feedbackClicked)]) {
        [_delegate feedbackClicked];
    }
}

- (void)apiClicked
{
    if ([_delegate respondsToSelector:@selector(apiClicked)]) {
        [_delegate apiClicked];
    }
}

- (void)logClicked
{
    if ([_delegate respondsToSelector:@selector(logClicked)]) {
        [_delegate logClicked];
    }
}

- (void)setupUI
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.liveView];
    [self.liveView addSubview:self.remoteLiveView];
    [self.liveView addSubview:self.localLiveView];
    
    [self addSubview:self.localUidView];
    [self addSubview:self.localRoomidView];
    [self addSubview:self.playBtn];
    [self.playBtn addTarget:self action:@selector(clickPlayBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.remoteUidView];
    [self addSubview:self.remoteRoomidView];
    [self addSubview:self.connectionBtn];
    [self.connectionBtn addTarget:self action:@selector(clickConnectionBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.pushStreamView];
    [self addSubview:self.pushBtn];
    [self.pushBtn addTarget:self action:@selector(clickPushBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.toolView];
    [self addSubview:self.logView];
    
    
    [self.logView addSubview:[LogManager sharedInstance].logController.view];
    [LogManager sharedInstance].logController.view.backgroundColor = [UIColor clearColor];
    [self.logView.layer addSublayer:self.gradientLayer];

    [self setupLayout];
}

- (void)setupLayout
{
    
    [self.liveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-15);
        make.height.equalTo(@215);
    }];
    [self.localLiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.height.equalTo(self.liveView);
        make.right.equalTo(self.remoteLiveView.mas_left).offset(-1);
        make.width.equalTo(self.remoteLiveView.mas_width);
    }];
    [self.remoteLiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.height.equalTo(self.liveView);
        make.left.equalTo(self.localLiveView.mas_right).offset(1);
    }];
    
    
    [self.localUidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.liveView);
        make.top.equalTo(self.liveView.mas_bottom).mas_offset(15.f);
        make.height.equalTo(@53.f);
        make.width.equalTo(@120.f);
    }];
    [self.localRoomidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.width.equalTo(self.localUidView);
        make.left.equalTo(self.localUidView.mas_right).offset(15.f);
    }];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.localRoomidView.mas_right).mas_offset(15.f);
        make.right.mas_equalTo(self.liveView);
        make.bottom.mas_equalTo(self.localRoomidView);
        make.height.mas_offset(32.f);
    }];
    
    
    [self.remoteUidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.height.mas_equalTo(self.localUidView);
        make.top.mas_equalTo(self.localUidView.mas_bottom).mas_offset(12.f);
    }];
    [self.remoteRoomidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.width.mas_equalTo(self.remoteUidView);
        make.left.mas_equalTo(self.remoteUidView.mas_right).mas_offset(15.f);
    }];
    [self.connectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.remoteRoomidView.mas_right).mas_offset(15.f);
        make.right.mas_equalTo(self.liveView);
        make.bottom.mas_equalTo(self.remoteRoomidView);
        make.height.mas_offset(32.f);
    }];
    
    [self.pushStreamView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.equalTo(self.remoteUidView);
        make.right.equalTo(self.remoteRoomidView);
        make.top.equalTo(self.remoteRoomidView.mas_bottom).offset(12.f);
    }];
    [self.pushBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.pushStreamView.mas_right).mas_offset(15.f);
        make.right.mas_equalTo(self.liveView);
        make.bottom.mas_equalTo(self.pushStreamView);
        make.height.mas_offset(32.f);
    }];

    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.liveView);
        make.bottom.mas_offset(-(kSafeBottomHeight + 12));
        make.height.mas_offset(36.f);
    }];
    
    [self.logView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.liveView);
        make.top.mas_equalTo(self.pushStreamView.mas_bottom).mas_offset(15.f);
        make.bottom.mas_equalTo(self.toolView.mas_top).mas_offset(-9.f);
    }];
    [[LogManager sharedInstance].logController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0.f);
    }];
    self.gradientLayer.frame = (CGRect){0, 0, self.logView.frame.size.width, self.logView.frame.size.height};
     
}

- (InputView *)createInputViewWithTitle:(NSString *)title placeholder:(NSString *)placeholder maxLength:(int)maxLength digitCount:(int)digitCount
{
    InputView *view = [InputView new];
    [view setTitle:title];
    [view setMaxLength:maxLength];
    view.delegate = self;
    [view setPlaceholder:[NSBundle jly_localizedStringWithKey:placeholder]];
    digitCount > 0 ? [view setInputText:[Utils generateRandomNumberWithDigitCount:digitCount]] : @"";
    return view;
}

- (UIButton *)createButtonWithNormalTitle:(NSString *)normalTitle selectTitle:(NSString *)selectTitle touchDownBg:(UIColor *)touchDownBg enableBg:(UIColor *)enableBg disEnableBg:(UIColor *)disEnableBg
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:[NSBundle jly_localizedStringWithKey:normalTitle] forState:UIControlStateNormal];
    [btn setTitle:[NSBundle jly_localizedStringWithKey:selectTitle] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    btn.layer.cornerRadius = 2;
    btn.touchDownBgColor = touchDownBg;
    btn.enableBgColor = enableBg;
    btn.disEnableBgColor = disEnableBg;
    return btn;
}

- (InputView *)localUidView
{
    if (!_localUidView) {
        _localUidView = [self createInputViewWithTitle:[NSBundle jly_localizedStringWithKey:@"本地UID"] placeholder:[NSBundle jly_localizedStringWithKey:@"最多6位数字"] maxLength:6 digitCount:6];
    }
    return _localUidView;
}

- (InputView *)localRoomidView
{
    if (!_localRoomidView) {
        _localRoomidView = [self createInputViewWithTitle:[NSBundle jly_localizedStringWithKey:@"本地Room ID"] placeholder:[NSBundle jly_localizedStringWithKey:@"最多8位数字"] maxLength:8 digitCount:4];
    }
    return _localRoomidView;
}

- (InputView *)remoteUidView
{
    if (!_remoteUidView) {
        _remoteUidView = [self createInputViewWithTitle:[NSBundle jly_localizedStringWithKey:@"远端UID"] placeholder:[NSBundle jly_localizedStringWithKey:@"最多6位数字"] maxLength:6 digitCount:0];
    }
    return _remoteUidView;
}

- (InputView *)remoteRoomidView
{
    if (!_remoteRoomidView) {
        _remoteRoomidView = [self createInputViewWithTitle:[NSBundle jly_localizedStringWithKey:@"远端Room ID"] placeholder:[NSBundle jly_localizedStringWithKey:@"最多8位数字"] maxLength:8 digitCount:0];
    }
    return _remoteRoomidView;
}

- (InputView *)pushStreamView
{
    if (!_pushStreamView) {
        _pushStreamView = [self createInputViewWithTitle:[NSBundle jly_localizedStringWithKey:@"推流地址"] placeholder:@"rtmp://" maxLength:1000 digitCount:0];
        [_pushStreamView setTextFieldBoardType:UIKeyboardTypeDefault];
    }
    return _pushStreamView;
}

- (UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [self createButtonWithNormalTitle:[NSBundle jly_localizedStringWithKey:@"开播"] selectTitle:[NSBundle jly_localizedStringWithKey:@"关播"] touchDownBg:[UIColor colorWithRed:3/255.0 green:52/255.0 blue:195/255.0 alpha:1.0] enableBg:[UIColor colorWithRed:0/255.0 green:65/255.0 blue:255/255.0 alpha:1.0] disEnableBg:[UIColor colorWithRed:211/255.0 green:213/255.0 blue:218/255.0 alpha:1.0]];
        _playBtn.enabled = YES;
    }
    return _playBtn;
}

- (UIButton *)connectionBtn
{
    if (!_connectionBtn) {
        _connectionBtn = [self createButtonWithNormalTitle:[NSBundle jly_localizedStringWithKey:@"连麦"] selectTitle:[NSBundle jly_localizedStringWithKey:@"取消连麦"] touchDownBg:[UIColor colorWithRed:3/255.0 green:52/255.0 blue:195/255.0 alpha:1.0] enableBg:[UIColor colorWithRed:0/255.0 green:65/255.0 blue:255/255.0 alpha:1.0] disEnableBg:[UIColor colorWithRed:211/255.0 green:213/255.0 blue:218/255.0 alpha:1.0]];
        _connectionBtn.enabled = NO;
    }
    return _connectionBtn;
}

- (UIButton *)pushBtn
{
    if (!_pushBtn) {
        _pushBtn = [self createButtonWithNormalTitle:[NSBundle jly_localizedStringWithKey:@"推流"] selectTitle:[NSBundle jly_localizedStringWithKey:@"停止"] touchDownBg:[UIColor colorWithRed:3/255.0 green:52/255.0 blue:195/255.0 alpha:1.0] enableBg:[UIColor colorWithRed:0/255.0 green:65/255.0 blue:255/255.0 alpha:1.0] disEnableBg:[UIColor colorWithRed:211/255.0 green:213/255.0 blue:218/255.0 alpha:1.0]];
        _pushBtn.enabled = NO;
    }
    return _pushBtn;
}
- (ToolBarView *)toolView
{
    if (!_toolView) {
        ToolBarView *view = [ToolBarView new];
        view.delegate = self;
        [view hideCameraBtn:YES];
        _toolView = view;
    }
    return _toolView;
}

- (UIView *)logView
{
    if (!_logView) {
        UIView *view = [UIView new];
        _logView = view;
    }
    return _logView;
}

- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        CAGradientLayer *layer = [CAGradientLayer new];
        layer.startPoint = CGPointMake(0, 0);
        layer.endPoint = CGPointMake(0, 1);
        layer.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0].CGColor];
        layer.locations = @[@(0), @(0.1f), @(1.0f)];
        _gradientLayer = layer;
    }
    return _gradientLayer;
}
- (UIView *)liveView
{
    if (!_liveView) {
        _liveView = [[UIView alloc] init];
        _liveView.backgroundColor = [UIColor whiteColor];
        _liveView.layer.masksToBounds = YES;
        _liveView.layer.cornerRadius = 5;
    }
    return _liveView;
}

- (CrossLiveItemView *)localLiveView
{
    if (!_localLiveView) {
        _localLiveView = [[CrossLiveItemView alloc] init];
        [_localLiveView setPreviewLabelText:[NSBundle jly_localizedStringWithKey:@"本地预览"]];
    }
    return _localLiveView;
}

- (CrossLiveItemView *)remoteLiveView
{
    if (!_remoteLiveView) {
        _remoteLiveView = [[CrossLiveItemView alloc] init];
        [_remoteLiveView setPreviewLabelText:[NSBundle jly_localizedStringWithKey:@"远端订阅"]];
    }
    return _remoteLiveView;
}

- (NSString *)localUid
{
    return self.localUidView.inputText;
}
- (NSString *)localRoomId
{
    return self.localRoomidView.inputText;
}
- (NSString *)remoteUid
{
    return self.remoteUidView.inputText;
}
- (NSString *)remoteRoomId
{
    return self.remoteRoomidView.inputText;
}
- (NSString *)pushStreamUrl
{
    return self.pushStreamView.inputText;
}
- (UIButton *)localPlayBtn
{
    return _playBtn;
}
- (UIButton *)remoteConBtn
{
    return _connectionBtn;
}
- (UIButton *)pushStreamBtn
{
    return _pushBtn;
}
- (CrossLiveItemView *)localLiveItemView
{
    return _localLiveView;
}
- (CrossLiveItemView *)remoteLiveItemView
{
    return _remoteLiveView;
}
- (ToolBarView *)toolBarView
{
    return _toolView;
}
@end
