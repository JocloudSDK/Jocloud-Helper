//
//  VideoLiveBroadcastViewController.m
//  app
//
//  Created by 宁丽环 on 2020/7/7.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "VideoLiveBroadcastViewController.h"
#import "DocumentWebController.h"
#import "LogTableController.h"
#import "AppConfigInfo.h"
#import "UIImage+JLYBundle.h"
#import "LiveFunctionView.h"
#import "LogManager.h"
#import "NSBundle+Language.h"
#import "FeedbackController.h"
#import "ThunderManager.h"
#import "AFNetworking.h"
#import "Utils.h"
#import "LiveView.h"
#import "MBProgressHUD+JLYHUD.h"
#import "LogHeader.h"
#import "LiveFunctionModel.h"
#import "BaseMacro.h"
#import "JYLFunctionAlertView.h"
#import "AppDelegate.h"
#import "ModulesDataManager.h"

#define  FunctionAlert_H 151
#define  FunctionAlert_W 345

@interface VideoLiveBroadcastViewController ()<LiveFunctionViewDelegate,ThunderEventDelegate,LiveViewDelegate,JYLFunctionAlertViewDelegate>

@property (nonatomic, strong) LiveFunctionView *leftFunctionView;
@property (nonatomic, strong) LiveFunctionView *rightFunctionView;
//档位
@property (nonatomic, strong) JYLFunctionAlertView *gearAlertView;
//镜像模式
@property (nonatomic, strong) JYLFunctionAlertView *mirrorAlertView;
//渲染模式
@property (nonatomic, strong) JYLFunctionAlertView *renderingAlertView;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) ThunderManager *thunderEngine;
@property (nonatomic, copy) NSString *localUid;
@property (nonatomic, assign) BOOL bFront;
@property (nonatomic, strong) LiveView *liveView;
@property (nonatomic, weak) IBOutlet UILabel *roomIDLabel;
@property (nonatomic, weak) IBOutlet UILabel *anchorUIDLabel;
@property (nonatomic, weak) IBOutlet UILabel *localUIDLabel;
@property (nonatomic, weak) IBOutlet UIButton *closeMircButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topConstraint;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) NSNumber *orientation; //屏幕方向
@property (nonatomic, strong) ModulesDataManager *modulesManager;
@end

@implementation VideoLiveBroadcastViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
    self.navigationController.navigationBarHidden = YES;
    [self begainFullScreen];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

//进入全屏
- (void)begainFullScreen
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    //强制归正：
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = [self.orientation intValue];
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

// 退出全屏
- (void)endFullScreen
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    //强制归正：
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (ModulesDataManager *)modulesManager
{
    if (!_modulesManager) {
        _modulesManager = [ModulesDataManager sharedManager];
    }
    return _modulesManager;
}

// 清晰度档位
- (JYLFunctionAlertView *)gearAlertView
{
    if (!_gearAlertView) {
        _gearAlertView = [[JYLFunctionAlertView alloc]init];
        [self.view addSubview:_gearAlertView];
        _gearAlertView.dataArray = @[
            [LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"流畅 320*240 15fps 300k" ] functionType:LiveFunctionAlertTypeStallSmooth],
            [LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"标清 640*368 24fps 550k"] functionType:LiveFunctionAlertTypeStallMark],
            [LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"高清 960*544 24fps 1000k"] functionType:LiveFunctionAlertTypeStallHD],
            [LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"超清 1280*720 24fps 1500k"] functionType:LiveFunctionAlertTypeStallClear],];
        _gearAlertView.delegate = self;
        [_gearAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.width.mas_equalTo(FunctionAlert_W);
            make.height.mas_equalTo(_gearAlertView.dataArray.count * 36 + 18);
            make.bottom.mas_equalTo(self.leftFunctionView.mas_top).offset(- 25);
        }];
    }
    return _gearAlertView;
}

//渲染模式
- (JYLFunctionAlertView *)renderingAlertView
{
    if (!_renderingAlertView) {
        _renderingAlertView = [[JYLFunctionAlertView alloc]init];
        [self.view addSubview:_renderingAlertView];
        _renderingAlertView.dataArray =  @[
            [LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"拉伸铺满窗口"] functionType:LiveFunctionAlertTypeRenderStretch] ,
            [LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"裁剪铺满窗口"] functionType:LiveFunctionAlertTypeRenderCut] ,
            [LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"适应窗口,比例不适应的，留黑边"] functionType:LiveFunctionAlertTypeRenderFit]];
        [_renderingAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.width.mas_equalTo(FunctionAlert_W);
            make.height.mas_equalTo(_renderingAlertView.dataArray.count *  36 + 18);
            make.bottom.mas_equalTo(self.leftFunctionView.mas_top).offset(- 25);
        }];
        _renderingAlertView.delegate = self;
        
    }
    return _renderingAlertView;
}

// 镜像
- (JYLFunctionAlertView *)mirrorAlertView
{
    if (!_mirrorAlertView) {
        _mirrorAlertView = [[JYLFunctionAlertView alloc]init];
        [self.view addSubview:_mirrorAlertView];
        _mirrorAlertView.dataArray = @[
            [LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"预览:"] functionType:LiveFunctionAlertTypeMirrorPreview],
            [LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"推流:"] functionType:LiveFunctionAlertTypeMirrorPushflow]];
        _mirrorAlertView.delegate = self;
        [_mirrorAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.width.mas_equalTo(FunctionAlert_W);
            make.height.mas_equalTo(_mirrorAlertView.dataArray.count * 36 + 18);
            make.bottom.mas_equalTo(self.leftFunctionView.mas_top).offset(- 25);
        }];
    }
    return _mirrorAlertView;
}


- (LiveFunctionView *)leftFunctionView
{
    if (!_leftFunctionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.sectionInset =  UIEdgeInsetsMake(0, 10, 10, 0);
        CGFloat padding = 10.0;
        CGFloat item_h = 36;
        CGFloat jyl_h =  self.isAnchor ? (item_h + padding) * 2 : item_h + 2 * padding;
        _leftFunctionView = [[LiveFunctionView alloc]initWithLayout:layout];
        _leftFunctionView.dataArray = self.isAnchor ? [NSMutableArray arrayWithArray:@[@[[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"档位"] selectedTitle:nil image:nil functionType:LiveFunctionTypeQuality],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"镜像"] selectedTitle:nil image:nil functionType:LiveFunctionTypeMirror],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"渲染模式"] selectedTitle:nil image:nil functionType:LiveFunctionTypeRender]],@[[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"横屏"] selectedTitle:[NSBundle jly_localizedStringWithKey:@"竖屏"] image:nil functionType:LiveFunctionTypeDirection],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"关摄像头"] selectedTitle:[NSBundle jly_localizedStringWithKey:@"开摄像头"] image:nil functionType:LiveFunctionTypeOnOrOffCamera],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"后摄像头"] selectedTitle:[NSBundle jly_localizedStringWithKey:@"前摄像头"] image:nil functionType:LiveFunctionTypeFrontOrRearCamera]]]] :  [NSMutableArray arrayWithArray:@[@[[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"横屏"] selectedTitle:[NSBundle jly_localizedStringWithKey:@"竖屏"] image:nil functionType:LiveFunctionTypeDirection],[LiveFunctionModel liveFunctionModelWithTitle:[NSBundle jly_localizedStringWithKey:@"渲染模式"] selectedTitle:nil image:nil functionType:LiveFunctionTypeRender]]]];
        [self.view addSubview:_leftFunctionView];
        _leftFunctionView.delegate = self;
        [_leftFunctionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.rightFunctionView.mas_left);
            make.bottom.mas_equalTo(kSafeBottomHeight > 0 ? -15: 0);
            make.height.mas_equalTo(jyl_h);
            make.left.mas_equalTo(0);
        }];
    }
    return _leftFunctionView;
}

- (LiveFunctionView *)rightFunctionView
{
    if (!_rightFunctionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 10, 20);
        CGFloat item_h = 50.0;
        CGFloat jyl_w = 90.0;
        CGFloat jyl_h = item_h * 3.0 + 30.0;
        _rightFunctionView = [[LiveFunctionView alloc]initWithLayout:layout];
        _rightFunctionView.dataArray =[NSMutableArray arrayWithArray:@[@[[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_black_feedback" functionType:LiveFunctionTypefeedback],[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_black_api" functionType:LiveFunctionTypeApi],[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_black_log" functionType:LiveFunctionTypeLog]]]];
        [self.view addSubview:_rightFunctionView];
        _rightFunctionView.delegate = self;
        [_rightFunctionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(jyl_w);
            make.height.mas_equalTo(jyl_h);
        }];
    }
    return _rightFunctionView;
}

- (void)setLocalUid:(NSString *)localUid
{
    _localUid = localUid;
    self.localUIDLabel.text = [[NSBundle jly_localizedStringWithKey:@"本地UID:"] stringByAppendingString:_localUid];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.leftFunctionView refreshView];
    [self.rightFunctionView refreshView];
    if (self.isAnchor) {
        [self configAnchorID];
    }
    if (self.modulesManager.firstCreateData && self.modulesManager.crossLocalUid.length == 0) {
        NSString *uid = [Utils generateRandomNumberWithDigitCount:6];
        self.localUid = uid;
        self.modulesManager.crossLocalUid = uid;
    } else {
        self.localUid = self.modulesManager.crossLocalUid;
    }
    [self setupUI];
    [self createEngine];
}

- (void)configAnchorID
{
    if (self.modulesManager.firstCreateData && self.modulesManager.crossLocalUid.length == 0) {
        NSString *uid = [Utils generateRandomNumberWithDigitCount:6];
        self.ownerUid = uid;
        self.modulesManager.crossLocalUid = uid;
    } else {
        self.ownerUid = self.modulesManager.crossLocalUid;
    }
    if (self.modulesManager.firstCreateData && self.modulesManager.crossLocalRoomId.length == 0) {
        NSString *roomid = [Utils generateRandomNumberWithDigitCount:4];
        self.roomId = roomid;
        self.modulesManager.crossLocalRoomId = roomid;
    } else {
        self.roomId = self.modulesManager.crossLocalRoomId;
    }
}

- (void)setupUI
{
    self.topConstraint.constant = kStatusBarHeight + 10;
    self.titleLabel.text = [NSBundle jly_localizedStringWithKey:@" 视频开播进阶用法 "];
    self.roomIDLabel.text = [@"RoomID:" stringByAppendingString:self.roomId];
    if (self.isAnchor) {
        self.localUIDLabel.text = nil;
        self.closeMircButton.hidden = NO;
        [self.closeMircButton setTitle:[NSBundle jly_localizedStringWithKey:@"闭麦"] forState:UIControlStateNormal];
        [self.closeMircButton setTitle:[NSBundle jly_localizedStringWithKey:@"开麦"] forState:UIControlStateSelected];
    }
    self.anchorUIDLabel.text =  [[NSBundle jly_localizedStringWithKey:@"主播UID:"] stringByAppendingString:self.ownerUid ? self.ownerUid : @""];
    self.liveView = [[LiveView alloc]init];
    self.liveView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.liveView];
    [self.view sendSubviewToBack:self.liveView];
    [self.liveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)createEngine
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.semaphore = dispatch_semaphore_create(1);
    self.thunderEngine = [ThunderManager sharedManager];
    [self.thunderEngine createEngine:kAppId sceneId:0 delegate:self];
    JLYLogInfo(@"UID=%@ createEngineAppId:%@",self.localUid,kAppId);
    [self.thunderEngine setLogFilePath:kLogFilePath];
    JLYLogInfo(@"UID=%@ setLogFilePath:%@",self.localUid,kLogFilePath);
    //设置媒体模式和房间模式
    [self.thunderEngine setRoomConfig:THUNDER_CONFIG_NORMAL roomConfig:THUNDER_ROOM_CONFIG_LIVE];
    JLYLogInfo(@"UID=%@ setRoomConfigMediaMode:%@ roomMode:%@",self.localUid,@"THUNDER_CONFIG_NORMAL",@"THUNDER_ROOM_CONFIG_LIVE");
    [self joinRoom];
}

- (void)joinRoom
{
    if (self.isAnchor) {
        [self.thunderEngine joinRoom:@"" roomName:self.roomId uid:self.ownerUid];
    } else {
        [self.thunderEngine joinRoom:@"" roomName:self.roomId uid:self.localUid];
        self.ownerUid = @"";
    }
    JLYLogInfo(@"UID=%@ joinRoom Anchor:%d",self.localUid,self.isAnchor);
}

#pragma mark - 横竖屏方向

- (void)orientationChanged:(NSNotification *)noti
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait: {            // Device oriented
            self.topConstraint.constant = kStatusBarHeight + 10;
            [self.thunderEngine setVideoCaptureOrientation:THUNDER_VIDEO_CAPTURE_ORIENTATION_PORTRAIT];
            self.orientation = @1;
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            self.topConstraint.constant = 20;
            [self.thunderEngine setVideoCaptureOrientation:THUNDER_VIDEO_CAPTURE_ORIENTATION_LANDSCAPE];
            self.orientation = @3;
        }
            break;
        default:
            break;
    }
    [self updateLeftFunctionViewWithOrientation:orientation];
}

- (void)updateLeftFunctionViewWithOrientation:(UIDeviceOrientation)orientation
{
    CGFloat padding = 10;
    CGFloat item_h = 36;
    [self.leftFunctionView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (orientation == UIDeviceOrientationPortrait) {
            CGFloat jyl_h =  self.isAnchor ? (item_h + padding) * 2 : 53;
            make.height.mas_equalTo(jyl_h);
        } else if (orientation == UIDeviceOrientationLandscapeLeft) {
            make.height.mas_equalTo(53);
        }
    }];
    
}

#pragma mark-  action

- (IBAction)back:(UIButton *)sender
{
    [self.thunderEngine leaveRoom];
    JLYLogInfo(@"UID=%@ leaveRoom",self.localUid);
    [self.navigationController popViewControllerAnimated:YES];
}


//关闭麦克风
- (IBAction)closeMircButtonClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.thunderEngine stopLocalAudioStream:sender.selected];
    JLYLogInfo(@"UID=%@ stopLocalAudioStream: %d",self.localUid,sender.selected);
    self.liveView.userModel.videoStoped = sender.selected;
}

///api
- (void)apiClicked
{
    DocumentWebController *con = [[DocumentWebController alloc] init];
    NSString *url = kApiUrl;
    if ([NSBundle jly_currentLanguageIsEn]) {
      url = [url stringByAppendingString:@"video_advanced/video_advanced_README.md"];
    } else {
      url = [url stringByAppendingString:@"video_advanced/video_advanced_README.zh.md"];
    }
    con.documentUrl = url;
    con.title = @"API";
    [self.navigationController pushViewController:con animated:YES];
}

///log
- (void)logClicked
{
    LogTableController *con = [[LogManager sharedInstance] getNewLogController];
    con.title = [NSBundle jly_localizedStringWithKey:@"日志"];
    [self.navigationController pushViewController:con animated:YES];
}

///反馈
- (void)feedbackClicked
{
    //注销通知
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
    //禁止横屏
    [self endFullScreen];
    FeedbackController *con = [FeedbackController new];
    if (self.isAnchor) {
        con.uid = self.ownerUid;
    } else {
        con.uid = self.localUid;
    }
    [self.navigationController pushViewController:con animated:YES];
}

///清晰度
- (void)qualityClicked
{
    self.gearAlertView.hidden = NO;
}

- (void)mirrorClicked:(BOOL)isSelected
{
    if (isSelected) {
        self.mirrorAlertView.hidden = NO;
    } else {
        self.mirrorAlertView.hidden = YES;
    }
}

///渲染模式
- (void)renderClicked
{
    self.renderingAlertView.hidden = NO;
}

///横竖屏
- (void)directionClicked:(BOOL)isSelected
{
    NSNumber *orientation = isSelected ? [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight] :[NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:orientation forKey:@"orientation"];
    self.orientation = orientation;
}

///打开关闭摄像头
- (void)onOrOffCameraClicked:(BOOL)isSelected
{
    [self.thunderEngine stopLocalCapture:isSelected];
    JLYLogInfo(@"UID=%@ stopLocalCapture: %d",self.localUid,isSelected);
    [self.thunderEngine stopLocalVideoStream:isSelected];
    JLYLogInfo(@"UID=%@ stopLocalVideoStream: %d",self.localUid,isSelected);
    self.liveView.userModel.videoStoped = isSelected;
}

///切换前后摄像头
- (void)frontOrRearCameraClicked:(BOOL)isSelected
{
    self.bFront = !isSelected;
    [self.thunderEngine switchFrontCamera:self.bFront];
    JLYLogInfo(@"UID=%@ switchFrontCamera: %d",self.localUid,self.bFront);
}

#pragma mark- LiveFunctionViewDelegate

- (void)liveFunctionViewDidSelectItemWithType:(LiveFunctionType)type selected:(BOOL)selected
{
    switch (type) {
        case LiveFunctionTypeQuality: {//档位

            [self qualityClicked];
            self.renderingAlertView.hidden = YES;
            self.mirrorAlertView.hidden = YES;
        }
            break;
        case LiveFunctionTypeMirror: {
            [self mirrorClicked:selected];
            self.gearAlertView.hidden = YES;
            self.renderingAlertView.hidden = YES;
        }
            break;
        case LiveFunctionTypeRender: {
            [self renderClicked];
            self.gearAlertView.hidden = YES;
            self.mirrorAlertView.hidden = YES;
        }
            break;
        case LiveFunctionTypeDirection: {
            [self directionClicked:selected];
            [self hiddenFunctionAlertView];
        }
            break;
        case LiveFunctionTypeOnOrOffCamera: {
            [self onOrOffCameraClicked:selected];
            [self hiddenFunctionAlertView];
        }
            break;
        case LiveFunctionTypeFrontOrRearCamera: {
            [self frontOrRearCameraClicked:selected];
            [self hiddenFunctionAlertView];
            
        }
            break;
        case LiveFunctionTypeApi: {
            [self apiClicked];
            [self hiddenFunctionAlertView];
            
        }
            break;
        case LiveFunctionTypeLog: {
            [self logClicked];
            [self hiddenFunctionAlertView];
            
        }
            break;
        case LiveFunctionTypefeedback: {
            [self feedbackClicked];
            [self hiddenFunctionAlertView];
        }
            break;
        default:
            break;
    }
}

#pragma mark- JYLFunctionAlertViewDelegate

- (void)jlyFunctionAlertView:(JYLFunctionAlertView *)functionAlertView didSelectItemRow:(NSInteger)row
{
    if ([functionAlertView isEqual:self.gearAlertView]) {
        ThunderPublishVideoMode mode = THUNDERPUBLISH_VIDEO_MODE_DEFAULT;
        switch (row) {
            case 0:
                mode = THUNDERPUBLISH_VIDEO_MODE_NORMAL;//流畅
                break;
            case 1:
                mode = THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY;//标清
                break;
            case 2:
                mode = THUNDERPUBLISH_VIDEO_MODE_SUPERQULITY;//高清
                break;
            case 3:
                mode = THUNDERPUBLISH_VIDEO_MODE_BLUERAY_2M;//超清
                break;
            default:
                break;
        }
        [self.thunderEngine switchPublishMode:mode];
        
    } else if ([functionAlertView isEqual:self.renderingAlertView]) {
        ThunderVideoRenderMode mode = THUNDER_RENDER_MODE_FILL;
        switch (row) {
            case 0:
                mode = THUNDER_RENDER_MODE_FILL;
                break;
            case 1:
                mode = THUNDER_RENDER_MODE_CLIP_TO_BOUNDS;
                break;
            case 2:
                mode = THUNDER_RENDER_MODE_ASPECT_FIT;
                break;
            default:
                break;
        }
        [self switchRenderingModeMode:mode];
    }
}

- (void)switchRenderingModeMode:(ThunderVideoRenderMode)mode
{
    if (self.isAnchor) {
        [self.thunderEngine setLocalCanvasScaleMode:mode];
        JLYLogInfo(@"UID=%@ setLocalCanvasScaleMode: %ld",self.localUid,mode);
    } else {
        [self.thunderEngine setRemoteCanvasScaleMode:self.ownerUid mode:mode];
        JLYLogInfo(@"UID=%@ setRemoteCanvasScaleMode: %ld",self.localUid,mode);
    }
}

//镜像
- (void)didChangeMirrorMode:(JYLMirrorMode)mode;
{
    switch (mode) {
        case JYLMirrorMode_PREVIEW_MIRROR_PUBLISH_NO_MIRROR: {
            [self.thunderEngine setLocalVideoMirrorMode:THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR];
            JLYLogInfo(@"UID=%@ setLocalVideoMirrorMode: %@",self.localUid,@"THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR");
        }
            break;
        case JYLMirrorMode_PREVIEW_PUBLISH_BOTH_MIRROR: {
            [self.thunderEngine setLocalVideoMirrorMode:THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR];
            JLYLogInfo(@"UID=%@ setLocalVideoMirrorMode: %@",self.localUid,@"THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR");
        }
            break;
        case JYLMirrorMode_PUBLISH_BOTH_NO_MIRROR: {
            [self.thunderEngine setLocalVideoMirrorMode:THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_NO_MIRROR];
            JLYLogInfo(@"UID=%@ setLocalVideoMirrorMode: %@",self.localUid,@"THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_NO_MIRROR");
        }
            break;
        case JYLMirrorMode_PREVIEW_NO_MIRROR_PUBLISH_MIRROR: {
            [self.thunderEngine setLocalVideoMirrorMode:THUNDER_VIDEO_MIRROR_MODE_PREVIEW_NO_MIRROR_PUBLISH_MIRROR];
            JLYLogInfo(@"UID=%@ setLocalVideoMirrorMode: %@",self.localUid,@"THUNDER_VIDEO_MIRROR_MODE_PREVIEW_NO_MIRROR_PUBLISH_MIRROR");
        }
            break;
        default:
            break;
    }
}

#pragma mark - ThunderEventDelegate
- (void)thunderEngine:(ThunderEngine *)engine onJoinRoomSuccess:(NSString *)room withUid:(NSString *)uid elapsed:(NSInteger)elapsed
{
    JLYLogInfo(@"UID=%@ joined roomID=%@",uid,room);
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.bFront = YES;
    [self.thunderEngine switchFrontCamera:self.bFront];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    self.liveView.delegate = self;
    LiveUserModel *model = [LiveUserModel new];
    model.audioStoped = NO;
    model.videoStoped = NO;
    model.localVideo = YES;
    model.uid = self.ownerUid;
    self.liveView.userModel = model;
    if (self.isAnchor) {
        [self.thunderEngine startPush:self.liveView uid:model.uid liveMode:THUNDERPUBLISH_VIDEO_MODE_SUPERQULITY];
        JLYLogInfo(@"Stream is publishing by UID=%@",uid);
        [self.thunderEngine setLocalVideoMirrorMode:THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR];
        JLYLogInfo(@"UID=%@ setLocalVideoMirrorMode %@",uid,@"THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR");
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"已成功开播"]];
    } else {
        [self.thunderEngine prepareRemoteView: self.liveView remoteUid:uid];
        JLYLogInfo(@"UID=%@ prepareRemoteView",uid);
    }
    dispatch_semaphore_signal(self.semaphore);
    self.leftFunctionView.enabled = YES;
}

- (void)thunderEngine:(ThunderEngine *)engine onRemoteAudioStopped:(BOOL)stopped byUid:(NSString *)uid
{
    self.ownerUid = uid;
    if (stopped) {
        JLYLogInfo(@"UID=%@ turned off microphone",uid);
    } else {
        JLYLogInfo(@"UID=%@ turned on microphone",uid);
    }
    [self handleOnRemoteStreamStopped:stopped uid:uid type:RemoteStreamTypeAudio];
}

- (void)thunderEngine:(ThunderEngine *)engine onRemoteVideoStopped:(BOOL)stopped byUid:(NSString *)uid
{
    self.ownerUid = uid;
    self.anchorUIDLabel.text =  [[NSBundle jly_localizedStringWithKey:@"主播UID:"] stringByAppendingString:self.ownerUid ? self.ownerUid : @""];
    if (stopped) {
        JLYLogInfo(@"UID=%@ turned off camera",uid);
    } else {
        JLYLogInfo(@"UID=%@ turned on camera",uid);
    }
    [self handleOnRemoteStreamStopped:stopped uid:uid type:RemoteStreamTypeVideo];
}

- (void)handleOnRemoteStreamStopped:(BOOL)stopped uid:(NSString *)uid type:(RemoteStreamType)type
{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    if (stopped) {
        [self handleOnRemoteStreamStopped:uid type:type];
    } else {
        [self handleOnRemoteStreamStarted:uid type:type];
    }
    dispatch_semaphore_signal(self.semaphore);
}


- (void)handleOnRemoteStreamStarted:(NSString *)uid type:(RemoteStreamType)type
{
    self.liveView.delegate = self;
    LiveUserModel *model = [LiveUserModel new];
    model.uid = uid;
    [model updateStatusOnRemoteStopped:NO type:type];
    self.liveView.userModel = model;
    if (!self.isAnchor) {
        [self.thunderEngine prepareRemoteView: self.liveView remoteUid:uid];
        JLYLogInfo(@"UID=%@ prepareRemoteView",uid);
    }
}

- (void)handleOnRemoteStreamStopped:(NSString *)uid type:(RemoteStreamType)type
{
    //暂时不做处理
}

#pragma mark - touchesBegan

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hiddenFunctionAlertView];
}

- (void)hiddenFunctionAlertView
{
    self.gearAlertView.hidden = YES;
    self.renderingAlertView.hidden = YES;
    self.mirrorAlertView.hidden = YES;
}

@end
