//
//  FeedbackController.m
//  ClassRoom
//
//  Created by GasparChu on 2020/3/17.
//  Copyright © 2020 SY. All rights reserved.
//

#import "FeedbackController.h"
#import "NSBundle+Language.h"
#import "MBProgressHUD+JLYHUD.h"
#import "AFNetworking.h"
#import "SSZipArchive.h"
#import "Masonry.h"
#import "AppConfigInfo.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "Utils.h"
#import "ThunderManager.h"
#import "BaseMacro.h"

@interface FeedbackController ()<UITextViewDelegate>

@property (nonatomic, strong) UILabel *versionLbl;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *textViewPlaceholderLbl;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *submitBtn;
@property (nonatomic, strong) CAShapeLayer *cornerRadiusLayer;
@property (nonatomic, strong) CAShapeLayer *cornerRadiusLayer1;
@property (nonatomic, strong) UILabel *desLabel;

// feedback service params
// 反馈的 appId
// Feedback appid
@property (nonatomic, copy) NSString *appId;
// 日志路径
// Log path
@property (nonatomic, copy) NSString *logFilePath;
// 上传 url
// Upload url
@property (nonatomic, copy) NSString *feedbackUrl;

@end

@implementation FeedbackController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
    [self setupNotification];
    [self setupFeedback];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setup
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = [NSBundle jly_localizedStringWithKey:@"反馈"];
    self.versionLbl.text = [NSBundle jly_localizedStringWithKey:@"请输入反馈内容"];
    
    [self.view addSubview:self.versionLbl];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.textViewPlaceholderLbl];
    [self.view addSubview:self.phoneLabel];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.submitBtn];
    [self.view addSubview:self.desLabel];
    NSString *hummerVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"hummerVersion"];
    self.desLabel.text = [NSString stringWithFormat:@"Rays V%@ Build %@ TB%@ HMR%@ \n%@ ", [Utils appVersion], [Utils appBuildVersion], [ThunderManager getVersion],hummerVersion,[NSBundle jly_localizedStringWithKey:@"本APP用于展示聚联云实时音视频的各类功能"]];
    
    [self.versionLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(17.f);
        make.top.mas_offset(10.f);
        make.right.mas_offset(-20.f);
        make.height.mas_offset(20.f);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.versionLbl);
        make.top.mas_equalTo(self.versionLbl.mas_bottom).mas_offset(8.f);
        make.height.mas_offset(151);
    }];
    [self.textViewPlaceholderLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.textView).mas_offset(5.f);
        make.right.mas_equalTo(self.textView).mas_offset(-5.f);
    }];
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.versionLbl);
        make.top.mas_equalTo(self.textView.mas_bottom).mas_offset(15.f);
        make.height.mas_offset(20.f);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.versionLbl);
        make.top.mas_equalTo(self.phoneLabel.mas_bottom).mas_offset(8.f);
        make.height.mas_offset(44.f);
    }];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.textField.mas_bottom).mas_offset(30.f);
        make.width.mas_offset(160.f);
        make.height.mas_offset(36.f);
    }];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-(kSafeBottomHeight + 12));
    }];
    [self.desLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

- (void)setupNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification  object:nil];
}

- (void)setupFeedback
{
    self.appId = kFeedbackAppId;
    self.logFilePath = kLogFilePath;
    self.feedbackUrl = kFeedbackUrl;
}

#pragma mark - Event
- (void)back
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)deviceChanged:(NSNotification *)sender
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        [self.versionLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10.f);
            if (@available(iOS 11.0, *)) {
                make.left.mas_equalTo(self.view.mas_safeAreaLayoutGuideLeft).mas_offset(20.f);
            } else {
                make.left.mas_offset(20.f);
            }
            if (@available(iOS 11.0, *)) {
                make.right.mas_equalTo(self.view.mas_safeAreaLayoutGuideRight).mas_offset(-20.f);
            } else {
                make.right.mas_offset(-20.f);
            }
            make.height.mas_offset(36.f);
        }];
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(101.f);
        }];
    }
    if (orientation == UIInterfaceOrientationPortrait) {
        [self.versionLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(20.f);
            make.left.mas_offset(20.f);
            make.right.mas_offset(-20.f);
            make.height.mas_offset(36.f);
        }];
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(260.f);
        }];
    }
}

- (void)submitBtnClicked:(UIButton *)sender
{
    if (!self.feedbackUrl.length) {
        [self back];
        return;
    }
    if (!self.appId.length) {
        [MBProgressHUD jly_showToast:@"please input appid"];
        return;
    }
    if (self.textView.text.length == 0 || [[self.textView.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"请输入反馈内容"]];
        return;
    }
    
    [self submitRequest];
}

- (void)submitRequest
{
    [MBProgressHUD jly_showActivityIndicator];
    
    // 压缩日志文件
    NSString *zipPath = [self compressionLogFileData];
    if (!zipPath.length) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"反馈失败"]];
        return;
    }
    
    // 初始化上传数据
    NSString *postData = [self getPostData];
    
    // 上传日志文件
    [[AFHTTPSessionManager manager] POST:self.feedbackUrl parameters:nil  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFormData:[postData dataUsingEncoding:NSUTF8StringEncoding] name:@"nyy"];
        if (zipPath) {
            NSData *zipData = [NSData dataWithContentsOfFile:zipPath];
            if (zipData == nil || zipData.length == 0) {
                return;
            }
            [formData appendPartWithFileData:zipData
                                        name:@"file"
                                    fileName:@"sylog.zip"
                                    mimeType:@"multipart/form-data"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath isDirectory:nil]) {
                [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
            }
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
        if (statusCode == 204 || statusCode == 206) {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"反馈成功"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self back];
            });
        } else {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"反馈失败"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"反馈失败"]];
    }];
}

// 压缩日志
// Compression log
- (NSString *)compressionLogFileData
{
    NSString *logFile = self.logFilePath;
    NSString *zipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"feedback.zip"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
    }
    BOOL isSuccess = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:logFile]) {
        if ([self isDirectory:logFile]) {
            isSuccess = [SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:logFile];
        } else {
            NSArray *files = @[logFile];
            isSuccess = [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:files];
        }
    }
    return isSuccess ? zipPath : @"";
}

- (NSString *)getPostData
{
    NSString *uploadContent = self.textView.text;
    NSString *networkState = [self networkTypeSting];
    NSString *marketChannel = @"Demo";
    NSString *serviceProvider = [self carrierName];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *guid = @"123456";
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    NSString *reportType = @"UFB";
    NSString *deviceName = [[UIDevice currentDevice] systemName];
    NSString *contact = self.textField.text.length ? self.textField.text : @"";
    
    NSDictionary *dataDict = @{
        @"feedback" : uploadContent,
        @"uid" : self.uid.length ? self.uid : @"",
        @"networkState" : networkState,
        @"marketChannel" : marketChannel,
        @"serviceProvider" : serviceProvider,
        @"productVer" : appVersion,
        @"guid" : guid,
        @"osVer" : systemVersion,
        @"reportType" : reportType,
        @"phoneType" : deviceName,
        @"contactInfo" : contact
    };
    NSString *postData = [NSString stringWithFormat:@"{\"appId\":\"%@\",\"sign\":\"\",\"data\":%@}", self.appId, [self jsonStringFromObject:dataDict]];
    return postData;
}

- (BOOL)isDirectory:(NSString *)filePath
{
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}

- (NSString *)jsonStringFromObject:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"object to json faile, object: %@, error: %@", object, error.localizedDescription);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.textViewPlaceholderLbl.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (!textView.text.length) {
        self.textViewPlaceholderLbl.hidden = NO;
    }
}

#pragma mark - Getter & Setter
- (UILabel *)versionLbl
{
    if (!_versionLbl) {
        UILabel *label = [UILabel new];
        label.textColor = [UIColor colorWithRed:133/255.0 green:133/255.0 blue:133/255.0 alpha:1.0];
        label.font = [UIFont boldSystemFontOfSize:14.f];
        _versionLbl = label;
    }
    return _versionLbl;
}

- (UITextView *)textView
{
    if (!_textView) {
        UITextView *view = [UITextView new];
        view.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        view.font = [UIFont systemFontOfSize:15.f];
        view.delegate = self;
        view.layer.cornerRadius = 2;
        view.layer.borderColor = [UIColor colorWithRed:211/255.0 green:213/255.0 blue:218/255.0 alpha:1.0].CGColor;
        view.layer.borderWidth = 0.5;
        _textView = view;
    }
    return _textView;
}

- (UILabel *)textViewPlaceholderLbl
{
    if (!_textViewPlaceholderLbl) {
        UILabel *label = [UILabel new];
        label.textColor = [UIColor colorWithRed:187/255.0 green:187/255.0 blue:187/255.0 alpha:1.0];
        label.font = [UIFont systemFontOfSize:15.f];
        label.numberOfLines = 0;
        label.text = [NSBundle jly_localizedStringWithKey:@"请勿留空"];
        _textViewPlaceholderLbl = label;
    }
    return _textViewPlaceholderLbl;
}

- (UILabel *)phoneLabel
{
    if (!_phoneLabel) {
        UILabel *label = [UILabel new];
        label.textColor = [UIColor colorWithRed:133/255.0 green:133/255.0 blue:133/255.0 alpha:1.0];
        label.font = [UIFont systemFontOfSize:14.f];
        label.text = [NSBundle jly_localizedStringWithKey:@"联系方式"];
        _phoneLabel = label;
    }
    return _phoneLabel;
}

- (UITextField *)textField
{
    if (!_textField) {
        UITextField *field = [UITextField new];
        field.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        field.font = [UIFont systemFontOfSize:15.f];
        field.layer.cornerRadius = 4.f;
        field.layer.borderColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0].CGColor;
        field.layer.borderWidth = 0.5f;
        field.placeholder = [NSBundle jly_localizedStringWithKey:@"选填"];
        _textField = field;
    }
    return _textField;
}

- (UILabel *)desLabel
{
    if (!_desLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        _desLabel = label;
    }
    return _desLabel;
}

- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        UIButton *btn = [UIButton new];
        [btn setTitle:[NSBundle jly_localizedStringWithKey:@"提交反馈"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        btn.backgroundColor = [UIColor colorWithRed:0/255.0 green:65/255.0 blue:255/255.0 alpha:1.0];
        btn.layer.cornerRadius = 2.f;
        btn.layer.shadowColor = [UIColor colorWithRed:152/255.0 green:223/255.0 blue:209/255.0 alpha:0.42].CGColor;
        btn.layer.shadowOffset = CGSizeMake(0,5);
        btn.layer.shadowOpacity = 1;
        btn.layer.shadowRadius = 13;
        [btn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _submitBtn = btn;
    }
    return _submitBtn;
}

#pragma mark - Device Orientation
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Network info

- (NSString *)networkTypeSting
{
    AFNetworkReachabilityStatus networkReachabilityStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    switch (networkReachabilityStatus) {
        case AFNetworkReachabilityStatusUnknown:
            return @"unknown";
            break;
        case AFNetworkReachabilityStatusNotReachable:
            return @"noNetwork";
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return [self WANNetworkTypeSting];
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return @"wifi";
            break;
    }
    
    return @"unknown";
}

- (NSString *)WANNetworkTypeSting
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *networkType = @"unknown";
    if ([info respondsToSelector:@selector(currentRadioAccessTechnology)]) {
        NSString *currentStatus = info.currentRadioAccessTechnology;
        NSArray *network2G = @[CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x];
        NSArray *network3G = @[CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD];
        NSArray *network4G = @[CTRadioAccessTechnologyLTE];
        
        if ([network2G containsObject:currentStatus]) {
            networkType = @"2g";
        } else if ([network3G containsObject:currentStatus]) {
            networkType = @"3g";
        } else if ([network4G containsObject:currentStatus]) {
            networkType = @"4g";
        } else {
            networkType = @"unknown";
        }
    }
    return networkType;
}

- (NSString *)carrierName
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    NSString *code = carrier.mobileNetworkCode;
    if (code == nil) {
        return @"nosp";
    } else if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"]) {
        return @"chinamobile";
    } else if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"]) {
        return @"chinaunicom";
    } else if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"]) {
        return @"chinatelecom";
    } else if ([code isEqualToString:@"20"]) {
        return @"chinatietong";
    }
    
    return @"";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}


@end
