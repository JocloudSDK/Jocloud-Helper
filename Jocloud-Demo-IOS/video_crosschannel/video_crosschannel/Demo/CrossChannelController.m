//
//  CrossChannelController.m
//  video_crosschannel
//
//  Created by Huan on 2020/6/12.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "CrossChannelController.h"
#import "LogHeader.h"
#import "CrossChannelView.h"
#import "Masonry.h"
#import "NSBundle+Language.h"
#import "HummerManager.h"
#import "ThunderManager.h"
#import "AppConfigInfo.h"
#import "Utils.h"
#import "CrossLiveUserModel.h"
#import "MBProgressHUD+JLYHUD.h"
#import "FeedbackController.h"
#import "DocumentWebController.h"
#import "AlertView.h"


@interface CrossChannelController ()<CrossChannelViewDelegate, ThunderEventDelegate, HMREventObserver, HMRPeerServiceObserver, AlertViewDelegate>

@property (nonatomic, strong) ThunderManager *thunderManager;
@property (nonatomic, strong) HummerManager *hummerManager;
@property (nonatomic, strong) CrossChannelView *crossView;
@property (nonatomic, strong) CrossLiveUserModel *localUserModel;
@property (nonatomic, strong) CrossLiveUserModel *remoteUserModel;

@property (nonatomic, assign) BOOL bFront;

@property (nonatomic, copy) NSString *originStreamTask;                     //源流任务
@property (nonatomic, copy) NSString *transcodingStreamTask;                //混流任务

@property (nonatomic, strong) AlertView *alertView;

@end

@implementation CrossChannelController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self createManager];
}

- (void)createManager
{
    [self.thunderManager createEngine:kAppId sceneId:0 delegate:self];
    [self.thunderManager setLogFilePath:kLogFilePath];
    [self.hummerManager startWithAppId:kAppId.longLongValue appVersion:[Utils appVersion] eventObserver:self];
    [self.hummerManager setLoggerFilePath:kLogFilePath];
    [self.hummerManager addObserver:self];
}

- (void)joinRoom
{
    [self.thunderManager joinRoom:@"" roomName:self.crossView.localRoomId uid:self.crossView.localUid];
}

- (void)leaveRoom
{
    //如果正在推流则停止推流
    if (self.originStreamTask.length > 0 || self.transcodingStreamTask.length > 0 || self.remoteUserModel.isLive) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"请先取消连麦和停止推流"]];
        return;
    }
    [self.thunderManager leaveRoom];
}

- (void)startLive
{
    [self.thunderManager startPush:self.crossView.localLiveItemView.userCanvasView uid:self.crossView.localUid liveMode:THUNDERPUBLISH_VIDEO_MODE_NORMAL];
    [self.crossView setInputViewEnabled:NO type:InputViewTypeLocal];
    [self.crossView setInputViewEnabled:YES type:InputViewTypeStream];
    [self.crossView setInputViewEnabled:YES type:InputViewTypeRemote];
    JLYLogInfo(@"Stream is publishing by UID=%@",self.crossView.localUid);
}

//连接远端用户
- (void)connectionRemoteUser
{
    self.crossView.remoteConBtn.selected = YES;
    self.remoteUserModel.isLive = YES;
    self.remoteUserModel.audioStoped = NO;
    self.remoteUserModel.canvasType = CanvasTypeRemote;
    self.crossView.remoteLiveItemView.userModel = self.remoteUserModel;
    [self.thunderManager addSubscribe:self.remoteUserModel.roomId uid:self.remoteUserModel.uid];
    [self.thunderManager prepareRemoteView:self.crossView.remoteLiveItemView.userCanvasView remoteUid:self.remoteUserModel.uid];
    [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"已成功连麦"]];
    [self.crossView setInputViewEnabled:NO type:InputViewTypeRemote];
}

//与远端用户断开连接
- (void)disConnectionRemoteUser
{
    [self.remoteUserModel resetModelData];
    self.crossView.remoteLiveItemView.userModel = self.remoteUserModel;
    self.remoteUserModel = nil;
    self.crossView.remoteConBtn.selected = NO;
    [self.thunderManager removeSubscribe:self.remoteUserModel.roomId uid:self.remoteUserModel.uid];
    [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"连麦已结束"]];
    [self.crossView setInputViewEnabled:YES type:InputViewTypeRemote];
}

//发送邀请
- (void)sendInviteMessageToRemoteUser
{
    NSString *timeSp = [self getCurrentDate];
    NSDictionary *extras = @{
        @"send_timestamp" : timeSp
    };
    [self.hummerManager sendPeerMessageToUser:self.crossView.remoteUid content:self.crossView.localRoomId type:kMessageInvite extras:extras completionHandler:^(NSError * _Nullable error) {
        if (error) {
            JLYLogError(@"Failed to send invitation to UID=%@, roomID=%@ ",self.crossView.remoteUid,self.crossView.remoteRoomId);
        } else {
            JLYLogInfo(@"Invitation to UID=%@, roomID=%@ is sent",self.crossView.remoteUid,self.crossView.remoteRoomId);
            [self showAlertViewWithType:AlertViewTypeToast];
        }
    }];
}

//取消连麦
- (void)sendCancelMessageToRemoteUser
{
    [self.hummerManager sendPeerMessageToUser:self.remoteUserModel.uid content:self.remoteUserModel.roomId type:kMessageCancel extras:[NSDictionary dictionary] completionHandler:^(NSError * _Nullable error) {
        if (!error && self.remoteUserModel.isLive) {
            [self disConnectionRemoteUser];
        }
    }];
}

//开启旁路推流
- (void)startPushStreams
{
    int setTaskResult;
    int publishResult;
    if (self.remoteUserModel.isLive) {//推混流
        LiveTranscoding *liveTrans = [self getLiveTranscoding];
        self.transcodingStreamTask = [Utils generateRandomNumberWithDigitCount:10];
        setTaskResult = [self.thunderManager setLiveTranscodingTask:self.transcodingStreamTask transcoding:liveTrans];
        publishResult = [self.thunderManager addPublishTranscodingStreamUrl:self.transcodingStreamTask url:kPushStreamUrl];
    } else {//推源流
        LiveTranscoding *liveTrans = [self getLiveTranscoding];
        self.originStreamTask = [Utils generateRandomNumberWithDigitCount:10];
        //添加任务
        setTaskResult = [self.thunderManager setLiveTranscodingTask:self.originStreamTask transcoding:liveTrans];
        //添加源流推流地址
        publishResult = [self.thunderManager addPublishOriginStreamUrl:kPushStreamUrl];
    }
    if (setTaskResult==0  && publishResult==0) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"推流成功"]];
        [self.crossView setInputViewEnabled:NO type:InputViewTypeStream];
        JLYLogInfo(@"Pushing %@",kPushStreamUrl);
    } else {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"推流失败，请检查推流地址或服务"]];
        JLYLogInfo(@"Failed to push %@",kPushStreamUrl);
    }
}

//结束旁路推流
- (void)endPushStreams
{
    int removeTaskResult = 0;
    int removepublishResult = 0;
    if (self.originStreamTask.length > 0) {//停止推源流
        //删除源流推流地址
        removeTaskResult = [self.thunderManager removePublishOriginStreamUrl:kPushStreamUrl];
        //删除转吗任务
        removepublishResult = [self.thunderManager removeLiveTranscodingTask:self.originStreamTask];
    } else if (self.transcodingStreamTask.length > 0) {
        //删除旁路推流地址
        removeTaskResult = [self.thunderManager removePublishTranscodingStreamUrl:self.transcodingStreamTask url:kPushStreamUrl];
        //删除转吗任务
        removepublishResult = [self.thunderManager removeLiveTranscodingTask:self.transcodingStreamTask];
    }
    if (removeTaskResult==0 && removepublishResult==0) {
        self.transcodingStreamTask =  @"";
        self.originStreamTask = @"";
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"推流已停止"]];
        [self.crossView setInputViewEnabled:YES type:InputViewTypeStream];
        JLYLogInfo(@"RTMP stream is stopped");
    }
}

- (void)back
{
    if (self.localUserModel.isLive) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"请先关闭直播"]];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ThunderEngineDelegate
- (void)thunderEngine:(ThunderEngine *)engine onJoinRoomSuccess:(NSString *)room withUid:(NSString *)uid elapsed:(NSInteger)elapsed
{
    
    JLYLogInfo(@"UID=%@ joined roomID=%@",uid,room);
    [self.hummerManager loginWithUid:self.crossView.localUid.longLongValue region:[self.hummerManager region] token:@"" completion:^(HMRRequestId reqId, NSError *error) {
        if (!error) {
            self.bFront = YES;
            self.crossView.localPlayBtn.selected = YES;
            [self.crossView.toolBarView leftButtonsEnableAction:YES];
            self.localUserModel = [[CrossLiveUserModel alloc] init];
            self.localUserModel.isLive = YES;
            self.localUserModel.audioStoped = NO;
            self.localUserModel.canvasType = CanvasTypeLocal;
            self.crossView.localLiveItemView.userModel = self.localUserModel;
            [self.crossView refreshButtonEnabled];
            [self startLive];
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"已成功开播"]];
        } else {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"进入房间失败"]];
        }
    }];
}

- (void)thunderEngine:(ThunderEngine *)engine onLeaveRoomWithStats:(ThunderRtcRoomStats *)stats
{
    JLYLogInfo(@"Stream is stopped by UID=%@",self.crossView.localUid);
    JLYLogInfo(@"UID=%@ has left the room",self.crossView.localUid);
    [self.hummerManager logout];
    self.crossView.localPlayBtn.selected = NO;
    [self.localUserModel resetModelData];
    self.crossView.localLiveItemView.userModel = self.localUserModel;
    [self.crossView.toolBarView leftButtonsEnableAction:NO];
    [self.crossView refreshButtonEnabled];
    [self.crossView setInputViewEnabled:YES type:InputViewTypeLocal];
    [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"已关播"]];
}

- (void)thunderEngine:(ThunderEngine *)engine onNetworkQuality:(NSString *)uid txQuality:(ThunderLiveRtcNetworkQuality)txQuality rxQuality:(ThunderLiveRtcNetworkQuality)rxQuality
{
    if ([uid isEqualToString:@"0"]) {
        self.localUserModel.quality = (int)txQuality;
        [self.crossView.localLiveItemView refreshQuality];
    } else if ([uid isEqualToString:self.remoteUserModel.uid]) {
        self.remoteUserModel.quality = (int)txQuality;
        [self.crossView.remoteLiveItemView refreshQuality];
    }
}

- (void)thunderEngine:(ThunderEngine *)engine onRoomStats:(RoomStats *)stats
{
    self.localUserModel.txBitrate = stats.txBitrate / 1000;
    self.localUserModel.txAudioBitrate = stats.txAudioBitrate / 1000;
    self.localUserModel.txVideoBitrate = stats.txVideoBitrate / 1000;
    self.localUserModel.rxBitrate = stats.rxBitrate / 1000;
    self.localUserModel.rxAudioBitrate = stats.rxAudioBitrate / 1000;
    self.localUserModel.rxVideoBitrate = stats.rxVideoBitrate / 1000;
    [self.crossView.localLiveItemView refreshQualityData];
}

#pragma mark HMREventObserver
- (void)didPeerMessageReceived:(HMRMessage *)message fromUser:(HMRUserId *)user
{
    NSString *roomId = [[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding];
    NSString *uid = [NSString stringWithFormat:@"%llu",user.ID];
    if ([message.type isEqualToString:kMessageInvite]) {//被邀请连麦
        JLYLogInfo(@" Invitation from UID=%@, roomID=%@ is received",uid,roomId);
        if ([roomId isEqualToString:self.crossView.localRoomId]) {
            return;
        }
        if (self.remoteUserModel.isLive || _alertView != nil) {// 如果正在与他人连麦则发送单播信令消息告知对方忙线
            JLYLogInfo(@"Invitation from UID=%@, roomID=%@ is rejected by system",uid,roomId);
            [self.hummerManager sendPeerMessageToUser:[NSString stringWithFormat:@"%llu",user.ID] content:self.crossView.localRoomId type:kMessageBusy extras:[NSDictionary dictionary] completionHandler:^(NSError * _Nullable error) {
            }];
        } else {
            NSString *newTime = [self getCurrentDate];
            NSDictionary *extras = message.extras;
            NSString *oldTime =  [extras.allKeys containsObject:@"send_timestamp"] ? [message.extras objectForKey:@"send_timestamp"] : @"0";
            long time = newTime.longLongValue - oldTime.longLongValue;
            if (time < 15) {
                self.remoteUserModel.uid = uid;
                self.remoteUserModel.roomId = roomId;
                [self showAlertViewWithType:AlertViewTypeTimer];
            }
        }
    } else if ([message.type isEqualToString:kMessageBusy]) {//对方正在连麦中
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"远端用户在连麦中，请稍后再试"]];
    } else if ([message.type isEqualToString:kMessageAccept]) {//对方同意连麦
        JLYLogInfo(@"Invitation is accepted by UID=%@",uid);
        [self hideAlertView];
        NSString *receiverUid = [NSString stringWithFormat:@"%llu",user.ID];
        if ([receiverUid isEqualToString:self.crossView.remoteUid]) {
            self.remoteUserModel.uid = receiverUid;
            NSString *roomId = [[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding];
            self.remoteUserModel.roomId = roomId;
            [self connectionRemoteUser];
        }
    } else if ([message.type isEqualToString:kMessageReject]) {//对方拒绝了连麦
        JLYLogInfo(@"Invitation is rejected by UID=%@",uid);
        [self hideAlertView];
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"连麦申请被拒"]];
    } else if ([message.type isEqualToString:kMessageCancel]) {//取消连麦
        JLYLogInfo(@"1v1 video call is ended by UID=%@",uid);
        [self disConnectionRemoteUser];
    }
}

#pragma mark - AlertViewDelegate
- (void)sureAction
{
    [self hideAlertView];
    [self.crossView setRemoteUid:self.remoteUserModel.uid roomId:self.remoteUserModel.roomId];
    //同意连麦
    JLYLogInfo(@"Invitation is accepted by you");
    [self.hummerManager sendPeerMessageToUser:self.remoteUserModel.uid content:self.crossView.localRoomId type:kMessageAccept extras:[NSDictionary dictionary] completionHandler:^(NSError * _Nullable error) {
        if (!error) {
            [self connectionRemoteUser];
        }
    }];
}

- (void)cancelAction:(BOOL)isTimeOut
{
    [self hideAlertView];
    //拒绝连麦
    if (isTimeOut) {
        JLYLogInfo(@"Invitation from UID=%@, roomID=%@ is expired",self.remoteUserModel.uid,self.remoteUserModel.roomId);
    } else {
        JLYLogInfo(@"Invitation is rejected by you");
    }
    
    [self.hummerManager sendPeerMessageToUser:self.remoteUserModel.uid content:self.crossView.localRoomId type:kMessageReject extras:[NSDictionary dictionary] completionHandler:^(NSError * _Nullable error) {
        
    }];
}

- (void)timeOutAction
{
    JLYLogInfo(@"No response from UID=%@, roomID=%@",self.crossView.remoteUid,self.crossView.remoteRoomId);
    [self hideAlertView];
    //邀请连麦超时
    [self sendCancelMessageToRemoteUser];
    [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"申请超时"]];
}

#pragma mark CrossChannelViewDelegate
- (void)optionLiveWithIsLive:(BOOL)isLive
{
    if (isLive) {
        [self joinRoom];
        [self.view endEditing:YES];
    } else {
        [self leaveRoom];
    }
}

- (void)optionVideoCallWithIsConnection:(BOOL)isConnection
{
    if (isConnection) {
        [self sendInviteMessageToRemoteUser];
        [self.view endEditing:YES];
    } else {
        JLYLogInfo(@"1v1 video call is ended by you");
        [self sendCancelMessageToRemoteUser];
    }
}

- (void)optionPushStreamWithIsPush:(BOOL)isPush
{
    if (isPush) {
        [self startPushStreams];
        [self.view endEditing:YES];
    } else {
        [self endPushStreams];
    }
}

- (void)cameraSwitchClicked
{
    int result = [self.thunderManager switchFrontCamera:!self.bFront];
    if (result == 0) {
        self.bFront = !self.bFront;
    }
}

- (void)audioClicked
{
    self.localUserModel.audioStoped = !self.localUserModel.audioStoped;
    [self.thunderManager stopLocalAudioStream:self.localUserModel.audioStoped];
    [self.crossView.toolBarView setAudioBtnStatusStopped:self.localUserModel.audioStoped];
}

- (void)feedbackClicked
{
    FeedbackController *con = [FeedbackController new];
    con.uid = self.crossView.localUid;
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
    con.title = @"Log/日志";
    [self.navigationController pushViewController:con animated:YES];
}



- (void)setupUI
{
    self.navigationItem.title = [NSBundle jly_localizedStringWithKey:@"跨房间连麦"];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:[LogManager sharedInstance].logController];
    CrossChannelView *crossView = [[CrossChannelView alloc] init];
    crossView.delegate = self;
    [crossView.toolBarView leftButtonsEnableAction:NO];
    [crossView setInputViewEnabled:NO type:InputViewTypeStream];
    [crossView setInputViewEnabled:NO type:InputViewTypeRemote];
    [self.view addSubview:crossView];
    self.crossView = crossView;
    [crossView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
}

- (void)showAlertViewWithType:(AlertViewType)type
{
    self.alertView.alertType = type;
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:self.alertView];
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(window);
    }];
}
- (LiveTranscoding *)getLiveTranscoding
{
    CGFloat videoWidth = 640;
    CGFloat videoHeight = 480;
    LiveTranscoding *liveTrans = nil;
    if (self.remoteUserModel.isLive) {//推混流
        liveTrans = [[LiveTranscoding alloc] init];
        [liveTrans setTransCodingMode:TRANSCODING_MODE_640X480];
        
        CGFloat width = videoWidth / 2;
        
        TranscodingUserObj *localUser = [[TranscodingUserObj alloc] init];
        localUser.uid = self.crossView.localUid;
        localUser.roomId = self.crossView.localRoomId;
        localUser.bCrop = YES;
        localUser.zOrder = 0;
        localUser.layoutX = 0;
        localUser.layoutY = 0;
        localUser.layoutW = width;
        localUser.layoutH = videoHeight;
        
        TranscodingUserObj *remoteUser = [[TranscodingUserObj alloc] init];
        remoteUser.uid = self.crossView.remoteUid;
        remoteUser.roomId = self.crossView.remoteRoomId;
        remoteUser.bCrop = YES;
        remoteUser.zOrder = 1;
        remoteUser.layoutX = width;
        remoteUser.layoutY = 0;
        remoteUser.layoutW = width;
        remoteUser.layoutH = videoHeight;
        
        NSMutableArray *arrayM = [NSMutableArray array];
        [arrayM addObject:localUser];
        [arrayM addObject:remoteUser];
        [liveTrans setUsers:arrayM];
    } else {//推源流
        liveTrans = [[LiveTranscoding alloc] init];
        [liveTrans setTransCodingMode:TRANSCODING_MODE_640X480];
        
        TranscodingUserObj *localUser = [[TranscodingUserObj alloc] init];
        localUser.uid = self.crossView.localUid;
        localUser.roomId = self.crossView.localRoomId;
        localUser.bCrop = YES;
        localUser.zOrder = 0;
        localUser.layoutX = 0;
        localUser.layoutY = 0;
        localUser.layoutW = videoWidth;
        localUser.layoutH = videoHeight;
        
        NSMutableArray *arrayM = [NSMutableArray array];
        [arrayM addObject:localUser];
        [liveTrans setUsers:arrayM];
    }
    return liveTrans;
}

- (NSString *)getCurrentDate
{
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970])];
    return timeSp;
}

- (void)hideAlertView
{
    [self.alertView stopTimer];
    [self.alertView removeFromSuperview];
    _alertView = nil;
}

- (ThunderManager *)thunderManager
{
    if (!_thunderManager) {
        _thunderManager = [ThunderManager sharedManager];
    }
    return _thunderManager;
}

- (HummerManager *)hummerManager
{
    if (!_hummerManager) {
        _hummerManager = [HummerManager sharedManager];
    }
    return _hummerManager;
}

- (CrossLiveUserModel *)localUserModel
{
    if (!_localUserModel) {
        _localUserModel = [[CrossLiveUserModel alloc] init];
        _localUserModel.canvasType = CanvasTypeLocal;
    }
    return _localUserModel;
}

- (CrossLiveUserModel *)remoteUserModel
{
    if (!_remoteUserModel) {
        _remoteUserModel = [[CrossLiveUserModel alloc] init];
        _localUserModel.canvasType = CanvasTypeRemote;
    }
    return _remoteUserModel;
}

- (AlertView *)alertView
{
    if (!_alertView) {
        AlertView *alertView = [[AlertView alloc] init];
        alertView.delegate = self;
        _alertView = alertView;
    }
    return _alertView;
}

@end
