//
//  AlertView.m
//  AFNetworking
//
//  Created by Huan on 2020/6/16.
//

#import "AlertView.h"
#import "Masonry.h"
#import "NSBundle+Language.h"
#import "AppConfigInfo.h"
#import "LogHeader.h"

@interface AlertView()

@property (nonatomic, strong) UIView *alertBottomView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) UILabel *toastLabel;
@property (nonatomic, strong) UIView *toastBottomView;

@end

@implementation AlertView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)stopTimer
{
    if (_timer) {
        dispatch_source_cancel(self.timer);
        _timer = nil;
    }
}

- (void)setAlertType:(AlertViewType)alertType
{
    _alertType = alertType;
    switch (alertType) {
        case AlertViewTypeNormal: {
            _alertBottomView.hidden = NO;
            self.titleLabel.text = [NSBundle jly_localizedStringWithKey:@"退出当前场景吗?"];
            [self.sureBtn setTitle:[NSBundle jly_localizedStringWithKey:@"确定"] forState:UIControlStateNormal];
            [self.cancelBtn setTitle:[NSBundle jly_localizedStringWithKey:@"取消"] forState:UIControlStateNormal];
            break;
        }
        case AlertViewTypeTimer: {
            _alertBottomView.hidden = NO;
            NSString *title = @"";
            NSString *text = [NSBundle jly_localizedStringWithKey:@"想与你连麦"];
            if ([text isEqualToString:@"想与你连麦"]) {
                title = [NSString stringWithFormat:@"%@%@",self.remoteUid,text];
            } else {
                title = [NSString stringWithFormat:@"%@%@",text,self.remoteUid];
            }
            self.titleLabel.text = title;
            [self.sureBtn setTitle:[NSBundle jly_localizedStringWithKey:@"接受"] forState:UIControlStateNormal];
            [self startTimer];
            break;
        }
        case AlertViewTypeToast: {
            self.toastBottomView.hidden = NO;
            [self startTimer];
            break;
        }
        default:
            break;
    }
}

- (void)startTimer
{
    if (_timer == nil) {
        __block int32_t timeOutCount = kInvitationTimeOutLength;
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_timer, ^{
            timeOutCount--;
            if (self.alertType == AlertViewTypeTimer) {
                NSString *refuseStr = [NSBundle jly_localizedStringWithKey:@"拒绝"];
                refuseStr = [refuseStr stringByAppendingFormat:@"%@", [NSString stringWithFormat:@"(%d)",timeOutCount]];
                NSString *title = refuseStr;
                [self.cancelBtn setTitle:title forState:UIControlStateNormal];
            } else {
                NSString *waitingStr = [NSBundle jly_localizedStringWithKey:@"正在等待远端用户操作"];
                waitingStr = [waitingStr stringByAppendingFormat:@"%@", [NSString stringWithFormat:@" %d",timeOutCount]];
                NSString *text = waitingStr;
                self.toastLabel.text = text;
            }
            if (timeOutCount == 0) {
                dispatch_source_cancel(self.timer);
                if ([self.delegate respondsToSelector:@selector(cancelAction:)] && self.alertType == AlertViewTypeTimer) {
                    [self.delegate cancelAction:YES];
                } else if ([self.delegate respondsToSelector:@selector(timeOutAction)] && self.alertType == AlertViewTypeToast) {
                    [self.delegate timeOutAction];
                }
            }
        });

        dispatch_resume(_timer);
    }
}

- (void)cancelBtnClick
{
    if (_timer) {
        [self stopTimer];
    }
    if ([self.delegate respondsToSelector:@selector(cancelAction:)]) {
        [self.delegate cancelAction:NO];
    }
}

- (void)sureBtnClick
{
    if (_timer) {
        [self stopTimer];
    }
    if ([self.delegate respondsToSelector:@selector(sureAction)]) {
        [self.delegate sureAction];
    }
}

- (void)setupUI
{
    //alertView
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.78;
    [self addSubview:bgView];
    
    UIView *alertBottomView = [[UIView alloc] init];
    alertBottomView.backgroundColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
    alertBottomView.layer.masksToBounds = YES;
    alertBottomView.layer.cornerRadius = 5;
    alertBottomView.hidden = YES;
    [self addSubview:alertBottomView];
    self.alertBottomView = alertBottomView;
    
    UIView *labelBottomView = [[UIView alloc] init];
    labelBottomView.backgroundColor = [UIColor whiteColor];
    [alertBottomView addSubview:labelBottomView];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:16];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [labelBottomView addSubview:label];
    self.titleLabel = label;
    
    UIButton *cancelBtn = [self createButtonWithTitle:@"取消" titleColor:[UIColor colorWithRed:170/255.0 green:174/255.0 blue:178/255.0 alpha:1.0]];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn = cancelBtn;
    
    UIButton *sureBtn = [self createButtonWithTitle:@"确定" titleColor:[UIColor colorWithRed:0/255.0 green:65/255.0 blue:255/255.0 alpha:1.0]];
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.sureBtn = sureBtn;
    
    //Toast
    UIView *toastBottomView = [[UIView alloc] init];
    toastBottomView.backgroundColor = [UIColor blackColor];
    toastBottomView.hidden = YES;
    [self addSubview:toastBottomView];
    _toastBottomView = toastBottomView;
    
    UILabel *toastLabel = [[UILabel alloc] init];
    toastLabel.text = @"";
    toastLabel.textColor = [UIColor whiteColor];
    toastLabel.font = [UIFont systemFontOfSize:16];
    toastLabel.numberOfLines = 0;
    toastLabel.textAlignment = NSTextAlignmentCenter;
    [toastBottomView addSubview:toastLabel];
    _toastLabel = toastLabel;
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.equalTo(self);
    }];
    [alertBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@280);
        make.height.equalTo(@135);
    }];
    [labelBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(alertBottomView);
        make.height.equalTo(@91);
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labelBottomView).offset(15);
        make.top.equalTo(labelBottomView);
        make.right.equalTo(labelBottomView).offset(-15);
        make.height.equalTo(labelBottomView);
    }];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(alertBottomView);
        make.top.equalTo(label.mas_bottom).offset(0.5);
        make.width.equalTo(sureBtn);
        make.right.equalTo(sureBtn.mas_left).offset(-0.5);
    }];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(alertBottomView);
        make.top.equalTo(cancelBtn);
        make.left.equalTo(cancelBtn.mas_right).offset(0.5);
        make.width.equalTo(cancelBtn);
    }];
    
    [toastBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.height.equalTo(@44);
    }];
    [toastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(toastBottomView);
    }];
    
}

- (UIButton *)createButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.backgroundColor = [UIColor whiteColor];
    [self.alertBottomView addSubview:button];
    return button;
}
@end
