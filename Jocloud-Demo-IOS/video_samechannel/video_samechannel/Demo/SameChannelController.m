//
//  SameChannelController.m
//  video_samechannel
//
//  Created by GasparChu on 2020/6/2.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "SameChannelController.h"
#import "SameCanvasCell.h"
#import "LogHeader.h"
#import "UICollectionViewCell+JLYRegister.h"
#import "Masonry.h"
#import "InputView.h"
#import "ToolBarView.h"
#import "ThunderManager.h"
#import "MBProgressHUD+JLYHUD.h"
#import "FeedbackController.h"
#import "Utils.h"
#import "AppConfigInfo.h"
#import "NSBundle+Language.h"
#import "DocumentWebController.h"
#import "BaseMacro.h"
#import "AFNetworking.h"
#import "UIButton+JLYButton.h"
#import "AlertView.h"
#import "ModulesDataManager.h"

static NSInteger const kLivingMaxCount = 4;

@interface SameChannelController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ToolBarViewDelegate, ThunderEventDelegate, SameCanvasCellDelegate, LiveViewDelegate, InputViewDelegate, AlertViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) InputView *uidView;
@property (nonatomic, strong) InputView *roomidView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) ToolBarView *toolView;
@property (nonatomic, strong) UIView *logView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) ThunderManager *thunderEngine;
@property (nonatomic, strong) NSMutableArray *liveUsersArr;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, assign) BOOL bFront;
@property (nonatomic, strong) AlertView *alertView;
@property (nonatomic, strong) ModulesDataManager *modulesManager;

@end

@implementation SameChannelController

- (void)dealloc
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self createEngine];
}

- (void)createEngine
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.semaphore = dispatch_semaphore_create(1);
    self.thunderEngine = [ThunderManager sharedManager];
    [self.thunderEngine createEngine:kAppId sceneId:0 delegate:self];
    [self.thunderEngine setLogFilePath:kLogFilePath];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)setupUI
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = [NSBundle jly_localizedStringWithKey:@"同房间多人连麦"];
    [self.view addSubview:self.collectionView];
    [SameCanvasCell jly_registerCellWithCollectionView:self.collectionView];
    [self.view addSubview:self.uidView];
    [self.view addSubview:self.roomidView];
    [self.view addSubview:self.playBtn];
    [self.view addSubview:self.toolView];
    [self.view addSubview:self.logView];
    
    [self addChildViewController:[LogManager sharedInstance].logController];
    [self.logView addSubview:[LogManager sharedInstance].logController.view];
    [LogManager sharedInstance].logController.view.backgroundColor = [UIColor clearColor];
    [self.logView.layer addSublayer:self.gradientLayer];
    
    [self setupLayout];
}

- (void)setupLayout
{
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(10.f);
        make.left.mas_offset(15.f);
        make.right.mas_offset(-15.f);
        make.height.mas_equalTo(@(self.view.bounds.size.width - 30));
    }];
    [self.uidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.collectionView);
        make.top.mas_equalTo(self.collectionView.mas_bottom).mas_offset(12.f);
        make.height.mas_offset(53.f);
        make.width.mas_offset(120.f);
    }];
    [self.roomidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.width.mas_equalTo(self.uidView);
        make.left.mas_equalTo(self.uidView.mas_right).mas_offset(15.f);
    }];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.roomidView.mas_right).mas_offset(15.f);
        make.right.mas_equalTo(self.collectionView);
        make.bottom.mas_equalTo(self.roomidView);
        make.height.mas_offset(32.f);
    }];
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.collectionView);
        make.bottom.mas_offset(-(kSafeBottomHeight + 12));
        make.height.mas_offset(36.f);
    }];
    [self.logView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.collectionView);
        make.top.mas_equalTo(self.uidView.mas_bottom).mas_offset(15.f);
        make.bottom.mas_equalTo(self.toolView.mas_top).mas_offset(-9.f);
    }];
    [[LogManager sharedInstance].logController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0.f);
    }];
    [self.view layoutIfNeeded];
    self.gradientLayer.frame = (CGRect) {0, 0, self.logView.frame.size.width, self.logView.frame.size.height};
}

#pragma mark - Event
- (void)back
{
    if (self.liveUsersArr.count > 0) {//在开播
        [self showAlertView];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        self.modulesManager.firstCreateData = NO;
    }
}

- (void)clickPlayBtn:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (!self.uidView.inputText.length || !self.roomidView.inputText.length) {
        return;
    }
    
    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (AFNetworkReachabilityStatusUnknown == netStatus || AFNetworkReachabilityStatusNotReachable == netStatus) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"网络异常"]];
        return;
    }
    
    if (!sender.isSelected) {
        [self.thunderEngine joinRoom:@"" roomName:self.roomidView.inputText uid:self.uidView.inputText];
    } else {
        [self.thunderEngine leaveRoom];
    }
}

#pragma mark - ThunderEventDelegate
- (void)thunderEngine:(ThunderEngine *)engine onJoinRoomSuccess:(NSString *)room withUid:(NSString *)uid elapsed:(NSInteger)elapsed
{
    JLYLogInfo(@"UID=%@ joined roomID=%@",uid,room);
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.playBtn.selected = YES;
    self.bFront = YES;
    [self.thunderEngine switchFrontCamera:self.bFront];
    [_toolView leftButtonsEnableAction:YES];
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    LiveView *view = [LiveView new];
    view.delegate = self;
    LiveUserModel *model = [LiveUserModel new];
    model.audioStoped = NO;
    model.videoStoped = NO;
    model.localVideo = YES;
    model.uid = self.uidView.inputText;
    view.userModel = model;
    [self.thunderEngine startPush:view uid:self.uidView.inputText liveMode:THUNDERPUBLISH_VIDEO_MODE_NORMAL];
    [self.liveUsersArr addObject:view];
    [self.collectionView reloadData];
    [self.uidView setEditStatus:NO];
    [self.roomidView setEditStatus:NO];
    
    JLYLogInfo(@"Stream is publishing by UID=%@",uid);
    [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"已成功开播"]];
    dispatch_semaphore_signal(self.semaphore);
}

- (void)thunderEngine:(ThunderEngine *)engine onLeaveRoomWithStats:(ThunderRtcRoomStats *)stats
{
    JLYLogInfo(@"Stream is stopped by UID=%@",_uidView.inputText);
    JLYLogInfo(@"UID=%@ has left the room",_uidView.inputText);
    self.playBtn.selected = NO;
    [self.toolView setVideoBtnStatusStopped:NO];
    [self.toolView setAudioBtnStatusStopped:NO];
    [_toolView leftButtonsEnableAction:NO];
    
    LiveView *view = self.liveUsersArr[0];
    [view removeFromSuperview];
    [self.liveUsersArr removeAllObjects];
    [self.collectionView reloadData];
    [self.thunderEngine stopAllRemoteAudioStreams:NO];
    [self.thunderEngine stopAllRemoteVideoStreams:NO];
    [self.uidView setEditStatus:YES];
    [self.roomidView setEditStatus:YES];
    
    [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"已关播"]];
}

- (void)thunderEngine:(ThunderEngine *)engine onRemoteAudioStopped:(BOOL)stopped byUid:(NSString *)uid
{
    if (stopped) {
        JLYLogInfo(@"UID=%@ turned off microphone",uid);
    } else {
        JLYLogInfo(@"UID=%@ turned on microphone",uid);
    }
    [self handleOnRemoteStreamStopped:stopped uid:uid type:RemoteStreamTypeAudio];
}

- (void)thunderEngine:(ThunderEngine *)engine onRemoteVideoStopped:(BOOL)stopped byUid:(NSString *)uid
{
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

- (void)handleOnRemoteStreamStopped:(NSString *)uid type:(RemoteStreamType)type
{
    __block NSInteger index = 0;
    [self.liveUsersArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LiveView *view = obj;
        if ([uid isEqualToString:view.userModel.uid]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    LiveView *view = self.liveUsersArr[index];
    LiveUserModel *model = view.userModel;
    [model updateStatusOnRemoteStopped:YES type:type];
    // index <= kLivingMaxCount - 1 表明显示在视图上，正在直播
    // index <= kLivingMaxCount - 1 Show on the view, live streaming
    if (index <= kLivingMaxCount - 1) {
        // 当音视频流都没有时删除连麦用户
        // Delete users when there is no audio and video stream
        if (model.videoStoped && model.audioStoped) {
            [view removeFromSuperview];
            // 恢复对远程用户音频流和视频流的设置，避免远程用户退出后再次进入房间还保持上次的mute操作
            // Restore the settings of the audio stream and video stream of the remote user to prevent the remote user from re-entering the room after exiting and maintain the previous mute operation
            [self.thunderEngine stopRemoteAudioStream:model.uid stopped:NO];
            [self.thunderEngine stopRemoteVideoStream:model.uid stopped:NO];
            // 需要把 view 置为 nil
            // Need to set view to nil
            [self.thunderEngine prepareRemoteView:nil remoteUid:model.uid];
            [self.liveUsersArr removeObject:view];
            [self.collectionView reloadData];
            JLYLogInfo(@"UID=%@ has left the room",uid);
        }
    } else {
        // 当音视频流都没有时删除用户
        // Delete users when there is no audio and video stream
        if (model.videoStoped && model.audioStoped) {
            // 需要把 view 置为 nil
            // Need to set view to nil
            [self.thunderEngine prepareRemoteView:nil remoteUid:model.uid];
            [self.liveUsersArr removeObject:view];
        }
    }
}

- (void)handleOnRemoteStreamStarted:(NSString *)uid type:(RemoteStreamType)type
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userModel.uid == %@", uid];
    NSArray *filterArr = [self.liveUsersArr filteredArrayUsingPredicate:predicate];
    if (filterArr.count) {
        // 已存在
        // existed
        LiveView *view = filterArr.firstObject;
        LiveUserModel *model = view.userModel;
        [model updateStatusOnRemoteStopped:NO type:type];
    } else {
        // 不存在
        // Not existed
        LiveView *view = [LiveView new];
        view.delegate = self;
        LiveUserModel *model = [LiveUserModel new];
        model.uid = uid;
        [model updateStatusOnRemoteStopped:NO type:type];
        view.userModel = model;
        [self.thunderEngine prepareRemoteView:view remoteUid:model.uid];
        [self.liveUsersArr addObject:view];
        [self.collectionView reloadData];
        
        JLYLogInfo(@"UID=%@ joined ", uid);
    }
}

#pragma mark - SameCanvasCellDelegate
- (void)cameraBtnClicked:(LiveUserModel *)model stoped:(BOOL)stoped
{
    model.videoUnSubscribe = stoped;
    [self.thunderEngine stopRemoteVideoStream:model.uid stopped:stoped];
}

- (void)audioBtnClicked:(LiveUserModel *)model stoped:(BOOL)stoped
{
    model.audioUnSubscribe = stoped;
    [self.thunderEngine stopRemoteAudioStream:model.uid stopped:stoped];
}

#pragma mark - LiveViewDelegate
- (void)fullScreenGestureClicked:(UIView *)view
{
    LiveUserModel *model = [(LiveView *)view userModel];
    if (model.fullScreen) {
        model.fullScreen = NO;
        [view removeFromSuperview];
        [self.collectionView reloadData];
    } else {
        model.fullScreen = YES;
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.collectionView);
        }];
    }
}

#pragma mark - InputViewDelegate
- (void)inputTextChanged
{
    if (self.uidView.inputText.length == 0 || self.roomidView.inputText.length == 0) {
        self.playBtn.enabled = NO;
    } else {
        self.playBtn.enabled = YES;
    }
    self.modulesManager.crossLocalUid = self.uidView.inputText;
    self.modulesManager.crossLocalRoomId = self.roomidView.inputText;
}

#pragma mark - AlertViewDelegate
- (void)sureAction
{
    [self.thunderEngine leaveRoom];
    self.modulesManager.firstCreateData = NO;
    [self.navigationController popViewControllerAnimated:YES];
    [self hideAlertView];
}
- (void)cancelAction:(BOOL)isTimeOut
{
    [self hideAlertView];
}

#pragma mark - ToolBarViewDelegate
- (void)cameraSwitchClicked
{
    if (!self.liveUsersArr.count) {
        return;
    }
    int result = [self.thunderEngine switchFrontCamera:!self.bFront];
    if (result == 0) {
        self.bFront = !self.bFront;
    }
}

- (void)cameraClicked
{
    if (!self.liveUsersArr.count) {
        return;
    }
    LiveView *view = self.liveUsersArr.firstObject;
    LiveUserModel *model = view.userModel;
    model.videoStoped = !model.videoStoped;
    [self.thunderEngine stopLocalVideoStream:model.videoStoped];
    [self.toolView setVideoBtnStatusStopped:model.videoStoped];
}

- (void)audioClicked
{
    if (!self.liveUsersArr.count) {
        return;
    }
    LiveView *view = self.liveUsersArr.firstObject;
    LiveUserModel *model = view.userModel;
    model.audioStoped = !model.audioStoped;
    [self.thunderEngine stopLocalAudioStream:model.audioStoped];
    [self.toolView setAudioBtnStatusStopped:model.audioStoped];
}

- (void)feedbackClicked
{
    FeedbackController *con = [FeedbackController new];
    con.uid = self.uidView.inputText;
    [self.navigationController pushViewController:con animated:YES];
}

- (void)documentClicked
{
    DocumentWebController *con = [[DocumentWebController alloc] init];
    con.documentUrl = kGithubUrl;
    [self.navigationController pushViewController:con animated:YES];
}

- (void)apiClicked
{
    DocumentWebController *con = [[DocumentWebController alloc] init];
    con.documentUrl = kGithubUrl;
    con.title = @"API";
    [self.navigationController pushViewController:con animated:YES];
}

- (void)logClicked
{
    LogTableController *con = [[LogManager sharedInstance] getNewLogController];
    con.title = [NSBundle jly_localizedStringWithKey:@"日志"];
    [self.navigationController pushViewController:con animated:YES];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return kLivingMaxCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SameCanvasCell *cell = [SameCanvasCell jly_cellWithCollectionView:collectionView indexPath:indexPath];
    cell.delegate = self;
    if (indexPath.item < self.liveUsersArr.count) {
        LiveView *view = self.liveUsersArr[indexPath.item];
        [cell setLiveView:view];
    } else {
        [cell setLiveView:nil];
    }
    return cell;
}

#pragma mark Getter/Setter
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.itemSize = (CGSize) {([UIScreen mainScreen].bounds.size.width - 31) / 2.0, ([UIScreen mainScreen].bounds.size.width - 31) / 2.0};
        flowLayout.minimumLineSpacing = 1;
        flowLayout.minimumInteritemSpacing = 1;
        UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        view.backgroundColor = [UIColor whiteColor];
        view.delegate = self;
        view.dataSource = self;
        view.layer.cornerRadius = 4;
        _collectionView = view;
    }
    return _collectionView;
}

- (InputView *)uidView
{
    if (!_uidView) {
        InputView *view = [InputView new];
        [view setTitle:@"UID"];
        [view setMaxLength:6];
        [view setPlaceholder:[NSBundle jly_localizedStringWithKey:@"最多6位数字"]];
        if (self.modulesManager.firstCreateData && self.modulesManager.crossLocalUid.length == 0) {
            NSString *uid = [Utils generateRandomNumberWithDigitCount:6];
            [view setInputText:uid];
            self.modulesManager.crossLocalUid = uid;
        } else {
            [view setInputText:self.modulesManager.crossLocalUid];
        }
        
        view.delegate = self;
        _uidView = view;
    }
    return _uidView;
}

- (InputView *)roomidView
{
    if (!_roomidView) {
        InputView *view = [InputView new];
        [view setTitle:@"Room ID"];
        [view setMaxLength:8];
        [view setPlaceholder:[NSBundle jly_localizedStringWithKey:@"最多8位数字"]];
        if (self.modulesManager.firstCreateData && self.modulesManager.crossLocalRoomId.length == 0) {
            NSString *roomId = [Utils generateRandomNumberWithDigitCount:4];
            [view setInputText:roomId];
            self.modulesManager.crossLocalRoomId = roomId;
        } else {
            [view setInputText:self.modulesManager.crossLocalRoomId];
        }
        _roomidView = view;
        view.delegate = self;
    }
    return _roomidView;
}

- (UIButton *)playBtn
{
    if (!_playBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:[NSBundle jly_localizedStringWithKey:@"开播"] forState:UIControlStateNormal];
        [btn setTitle:[NSBundle jly_localizedStringWithKey:@"关播"] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        btn.backgroundColor = [UIColor colorWithRed:0/255.0 green:65/255.0 blue:255/255.0 alpha:1.0];
        [btn addTarget:self action:@selector(clickPlayBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 2;
        btn.jly_touchDownBgColor = [UIColor colorWithRed:3/255.0 green:52/255.0 blue:195/255.0 alpha:1.0];
        btn.jly_enableBgColor = [UIColor colorWithRed:0/255.0 green:65/255.0 blue:255/255.0 alpha:1.0];
        btn.jly_disEnableBgColor = [UIColor colorWithRed:211/255.0 green:213/255.0 blue:218/255.0 alpha:1.0];
        _playBtn = btn;
    }
    return _playBtn;
}

- (ToolBarView *)toolView
{
    if (!_toolView) {
        ToolBarView *view = [ToolBarView new];
        view.delegate = self;
        _toolView = view;
        [_toolView leftButtonsEnableAction:NO];
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

- (NSMutableArray *)liveUsersArr
{
    if (!_liveUsersArr) {
        NSMutableArray *mArr = [NSMutableArray array];
        _liveUsersArr = mArr;
    }
    return _liveUsersArr;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)showAlertView
{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:self.alertView];
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(window);
    }];
}

- (void)hideAlertView
{
    [self.alertView removeFromSuperview];
    _alertView = nil;
}

- (AlertView *)alertView
{
    if (!_alertView) {
        _alertView = [[AlertView alloc] init];
        _alertView.delegate = self;
        [_alertView setAlertType:AlertViewTypeNormal];
    }
    return _alertView;
}

- (ModulesDataManager *)modulesManager
{
    if (!_modulesManager) {
        _modulesManager = [ModulesDataManager sharedManager];
    }
    return _modulesManager;
}
@end
