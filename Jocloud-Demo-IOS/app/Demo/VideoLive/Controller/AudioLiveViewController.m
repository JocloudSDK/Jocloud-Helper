//
//  AudioLiveViewController.m
//  app
//
//  Created by 宁丽环 on 2020/7/9.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "AudioLiveViewController.h"
#import "AudioLiveTableViewCell.h"
#import "LiveFunctionView.h"
#import "LiveFunctionModel.h"
#import "NSBundle+Language.h"
#import "UIImage+JLYBundle.h"
#import "ThunderManager.h"
#import "AppConfigInfo.h"
#import "MBProgressHUD+JLYHUD.h"
#import "AlertView.h"
#import "AuidoUserModel.h"
#import "UIColor+SLExtention.h"
#import "DocumentWebController.h"
#import "LogTableController.h"
#import "FeedbackController.h"
#import "LogManager.h"
#import "LiveWhineView.h"
#import "BaseMacro.h"
#import "AFNetworking.h"
#import "AudioToolBarView.h"
#import "LiveUserModel.h"
#import "Utils.h"
#import "LogHeader.h"
#import "ModulesDataManager.h"
#import "UITextField+Expand.h"
#import "NSDate+JYLExtention.h"

@interface AudioLiveViewController ()<AudioToolBarViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ThunderEventDelegate,AlertViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LiveWhineViewDelegate>

@property (nonatomic, strong) UIAlertController *actionSheetAlertVC;
@property (nonatomic, weak) IBOutlet UILabel *localUIDTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *localRoomIDTitleLabel;
@property (nonatomic, weak) IBOutlet UITextField *localUIDTextField;
@property (nonatomic, weak) IBOutlet UITextField *localRoomIDTextField;
@property (nonatomic, weak) IBOutlet UIButton *startLiveButton;
@property (nonatomic, weak) IBOutlet UIButton *switchModeButton;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, strong) AudioToolBarView *toolView;
@property (nonatomic, weak) IBOutlet UITableView *audienceTableView;
@property (nonatomic, weak) IBOutlet UILabel *peopleTitleLabel;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UITextView *logsContenView;
@property (nonatomic, strong) LiveWhineView *whineView;
@property (nonatomic, strong) ThunderManager *thunderEngine;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) AlertView *alertView;
@property (nonatomic, strong) NSMutableArray *peoplesArray;
@property (nonatomic, assign) BOOL isLiving;//是否正在开播
@property (nonatomic, strong) LiveUserModel *localUserModel;
@property (nonatomic, assign) ThunderRtcAudioConfig audioConfig;
@property (nonatomic, strong) ModulesDataManager *modulesManager;
@end

@implementation AudioLiveViewController

- (ModulesDataManager *)modulesManager
{
    if (!_modulesManager) {
        _modulesManager = [ModulesDataManager sharedManager];
    }
    return _modulesManager;
}

- (NSMutableArray *)peoplesArray
{
    if (!_peoplesArray) {
        _peoplesArray = [[NSMutableArray alloc]init];
    }
    return _peoplesArray;
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

- (BOOL)netStatusAlert
{
    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (AFNetworkReachabilityStatusUnknown == netStatus || AFNetworkReachabilityStatusNotReachable == netStatus) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"网络异常"]];
        return NO;
    } else {
        return YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [self setupUI];
    [self createEngine];
}

- (void)setupUI
{
    self.toolView.hidden = NO;
    self.contentView.hidden = YES;
    self.title = [NSBundle jly_localizedStringWithKey:@"音频开播进阶用法"];
    [self setupLocalUID];
    [self setupLocalRoomId];
 
    [self.startLiveButton setTitle:[NSBundle jly_localizedStringWithKey:@"开播"] forState:UIControlStateNormal];
    [self.startLiveButton setTitle:[NSBundle jly_localizedStringWithKey:@"关播"] forState:UIControlStateSelected];
    
    self.peopleTitleLabel.text = [NSBundle jly_localizedStringWithKey:@"房间人员"];
    
    self.switchModeButton.layer.borderColor = [UIColor sl_colorWithHexString:@"#D3D5DA"].CGColor;
   [self.switchModeButton setTitle:[NSBundle jly_localizedStringWithKey:@"语音编码 单声道 16KHz 18kbps"] forState:UIControlStateNormal];
    
    [self.audienceTableView registerNib:[UINib nibWithNibName:NSStringFromClass([AudioLiveTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([AudioLiveTableViewCell class])];
}

- (void)setupLocalUID
{
    self.localUIDTitleLabel.text = [NSBundle jly_localizedStringWithKey:@"本地UID"];
    self.localUIDTextField.placeholder = [NSBundle jly_localizedStringWithKey:@"最多6位数字"];
    if (self.modulesManager.firstCreateData && self.modulesManager.crossLocalUid.length == 0) {
        NSString *uid = [Utils generateRandomNumberWithDigitCount:6];
        self.localUIDTextField.text = uid;
        self.modulesManager.crossLocalUid = uid;
    } else {
        self.localUIDTextField.text = self.modulesManager.crossLocalUid;
    }
    self.localUIDTextField.delegate = self;
    [self.localUIDTextField jyl_lengthLimit:^{
        if (self.localUIDTextField.text.length > 6) {
            self.localUIDTextField.text = [self.localUIDTextField.text substringToIndex:6];
        }
    }];
    [self.localUIDTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}

- (void)setupLocalRoomId
{
    self.localRoomIDTitleLabel.text = @"Room ID";
    self.localRoomIDTextField.placeholder = [NSBundle jly_localizedStringWithKey:@"最多8位数字"];
    if (self.modulesManager.firstCreateData && self.modulesManager.crossLocalRoomId.length == 0) {
        NSString *roomid = [Utils generateRandomNumberWithDigitCount:4];
        self.localRoomIDTextField.text = roomid;
        self.modulesManager.crossLocalRoomId = roomid;
    } else {
        self.localRoomIDTextField.text = self.modulesManager.crossLocalRoomId;
    }
    self.localRoomIDTextField.delegate = self;
    [self.localRoomIDTextField jyl_lengthLimit:^{
        if (self.localRoomIDTextField.text.length > 8) {
            self.localRoomIDTextField.text = [self.localRoomIDTextField.text substringToIndex:8];
        }
    }];
    [self.localRoomIDTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)createEngine
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.semaphore = dispatch_semaphore_create(1);
    self.thunderEngine = [ThunderManager sharedManager];
    [self.thunderEngine createEngine:kAppId sceneId:0 delegate:self];
    JLYLogInfo(@"UID=%@ createEngine AppId:%@",self.modulesManager.crossLocalUid,kAppId);
    [self.thunderEngine setLogFilePath:kLogFilePath];
    JLYLogInfo(@"UID=%@ setLogFilePath:%@",self.modulesManager.crossLocalUid,kLogFilePath);
    [self.thunderEngine setRoomConfig:THUNDER_CONFIG_ONLY_AUDIO roomConfig:THUNDER_ROOM_CONFIG_MULTIAUDIOROOM];
    JLYLogInfo(@"UID=%@ setRoomConfigMediaMode:%@ roomMode:%@",self.modulesManager.crossLocalUid,@"THUNDER_CONFIG_ONLY_AUDIO",@"THUNDER_ROOM_CONFIG_MULTIAUDIOROOM");
    [self.thunderEngine setAudioVolumeIndication:1.0];
    [self resetAudioConfig];
}

- (IBAction)switchModeButtonClicked:(UIButton *)sender
{
    [self.navigationController presentViewController:self.actionSheetAlertVC animated:YES completion:nil];
}

- (IBAction)startLiveButtonClicked:(UIButton *)sender
{
    if ([self netStatusAlert]) {
        [self.localRoomIDTextField resignFirstResponder];
        [self.localRoomIDTextField resignFirstResponder];
        self.modulesManager.crossLocalUid = self.localUIDTextField.text;
        self.modulesManager.crossLocalRoomId = self.localRoomIDTextField.text;
        if (self.modulesManager.crossLocalRoomId.length == 0  || self.modulesManager.crossLocalUid.length == 0) {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"请完成输入"]];
            return;
        }
        sender.selected = !sender.selected;
        if (sender.selected) {
            [self joinRoom];
        } else {
            [self leaveRoom];
        }
    };
}

- (void)joinRoom
{
    [self.thunderEngine joinRoom:@"" roomName:self.modulesManager.crossLocalRoomId uid:self.modulesManager.crossLocalUid];
    [self configAudio];
    JLYLogInfo(@"UID=%@ joinRoom roomid %@",self.modulesManager.crossLocalUid, self.modulesManager.crossLocalRoomId);
    self.isLiving = YES;
    self.localUserModel = [LiveUserModel new];
    self.localUserModel.audioStoped = NO;
    self.localUserModel.videoStoped = YES;
    self.localUserModel.localVideo = YES;
    self.localUserModel.speakerStoped = NO;
    self.localUserModel.earClosed = NO;
    self.localUserModel.uid = self.modulesManager.crossLocalUid;
    self.contentView.hidden = NO;
    self.localUIDTextField.userInteractionEnabled = NO;
    self.localRoomIDTextField.userInteractionEnabled = NO;
    self.switchModeButton.userInteractionEnabled = NO;
    [self.thunderEngine enableLoudspeaker:!self.localUserModel.speakerStoped];
    JLYLogInfo(@"UID:%@  enableLoudspeaker:%d",self.modulesManager.crossLocalUid,!self.localUserModel.speakerStoped);
    [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ %@",self.modulesManager.crossLocalUid,self.localUserModel.speakerStoped ?@"switched to earphone" :@"switched to speaker"]];
}

- (void)leaveRoom
{
    [self resetEar];
    [self resetSpeaker];
    [self resetWhine];
    [self.thunderEngine leaveRoom];
    JLYLogInfo(@"UID=%@ leaveRoom",self.modulesManager.crossLocalUid);
    [self.peoplesArray removeAllObjects];
    [self.audienceTableView reloadData];
    self.contentView.hidden = YES;
    self.localUIDTextField.userInteractionEnabled = YES;
    self.localRoomIDTextField.userInteractionEnabled = YES;
    self.switchModeButton.userInteractionEnabled = YES;
    self.isLiving = NO;
}

///声道复位
- (void)resetAudioConfig
{
    self.audioConfig = THUNDER_AUDIO_CONFIG_SPEECH_STANDARD;
}

//变声复位
- (void)resetWhine
{
    [self offWhine];
    [self.whineView reset];
}

//复位耳返
- (void)resetEar
{
    self.localUserModel.earClosed = NO;
    [self.thunderEngine setEnableInEarMonitor:self.localUserModel.earClosed];
    JLYLogInfo(@"UID:%@  setEnableInEarMonitor:%d",self.modulesManager.crossLocalUid,self.localUserModel.earClosed);
    [self.toolView setEarBtnStatusStopped:self.localUserModel.earClosed];
    [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ %@",self.modulesManager.crossLocalUid,self.localUserModel.earClosed ? @"Ear-in On":@"Ear-in Off"]];
}

//复位扬声器
- (void)resetSpeaker
{
    if (self.localUserModel.speakerStoped) {
        self.localUserModel.speakerStoped = NO;
    }
    [self.thunderEngine enableLoudspeaker:!self.localUserModel.speakerStoped];
    JLYLogInfo(@"UID:%@  enableLoudspeaker:%d",self.modulesManager.crossLocalUid,!self.localUserModel.speakerStoped);
    [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ %@",self.modulesManager.crossLocalUid,self.localUserModel.speakerStoped ?@"switched to earphone" :@"switched to speaker"]];
    [self.toolView setSpeakerBtnStatusStopped:self.localUserModel.speakerStoped];
}

- (void)configAudio
{
    [self.thunderEngine setAudioConfig:self.audioConfig commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];
    JLYLogInfo(@"UID:%@  setAudioConfig: %@",self.modulesManager.crossLocalUid,[self audioConfigLogsStringWithMode:self.audioConfig]);
    [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ joined with audio config = %@",self.modulesManager.crossLocalUid,[NSBundle jly_localizedStringWithKey:[self audioConfigLogsStringWithMode:self.audioConfig]]]];
    [self.switchModeButton setTitle:[NSBundle jly_localizedStringWithKey:[self audioConfigStringWithMode:self.audioConfig]] forState:UIControlStateNormal];
}

- (NSString *)audioConfigStringWithMode:(ThunderRtcAudioConfig)config
{
    NSString *audioConfigString = nil;
    if (config == THUNDER_AUDIO_CONFIG_SPEECH_STANDARD) {
        audioConfigString = @"语音编码 单声道 16KHz 18kbps";
        
    } else if (config == THUNDER_AUDIO_CONFIG_MUSIC_STANDARD_STEREO) {
        audioConfigString = @"音乐编码 双声道 44.1KHz 24kbps EAAC+";
        
    } else if (config == THUNDER_AUDIO_CONFIG_MUSIC_STANDARD) {
        audioConfigString = @"音乐编码 单声道 48KHz 40kbps";
        
    } else if (config == THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO) {
        audioConfigString = @"音乐编码 双声道 44.1KHz 128kbps AAC L";
        
    } else if (config == THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO_192) {
        audioConfigString = @"音乐编码 双声道 44.1KHz 192kbps AAC LC_192K";
    }
    return audioConfigString;
}

- (NSString *)audioConfigLogsStringWithMode:(ThunderRtcAudioConfig)config
{
  NSString *audioConfigLogsString = nil;
    if (config == THUNDER_AUDIO_CONFIG_SPEECH_STANDARD) {
        audioConfigLogsString = @"Speech Mono 16KHz 18kbps";
        
    } else if (config == THUNDER_AUDIO_CONFIG_MUSIC_STANDARD_STEREO) {
        audioConfigLogsString = @"Speech Mono 44.1KHz 24kbps EAAC+";
        
    } else if (config == THUNDER_AUDIO_CONFIG_MUSIC_STANDARD) {
        audioConfigLogsString = @"Speech Mono 48KHz 40kbps";
        
    } else if (config == THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO) {
        audioConfigLogsString = @"Speech Mono 44.1KHz 128kbps AAC L";
        
    } else if (config == THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO_192) {
        audioConfigLogsString = @"Speech Mono 44.1KHz 192kbps AAC LC_192K";
    }
    return audioConfigLogsString;
}

- (void)reloadPeopleListViewWithUid:(NSString *)uid
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", uid]; //过滤条件
    NSArray *filteredArray= [self.peoplesArray filteredArrayUsingPredicate:predicate]; //最终结果filteredArray
    if (!filteredArray.count) {
        [self.peoplesArray addObject:[AuidoUserModel auidoUserModelWithUid:uid]];
        JLYLogInfo(@"UID:%@  reloadPeopleListViewWithUid:%@",self.modulesManager.crossLocalUid, uid);
        [self.audienceTableView reloadData];
    }
}

- (void)stopMircWithUid:(NSString *)uid stop:(BOOL)stopped
{
    // add semaphore
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    if ([uid isEqualToString:self.modulesManager.crossLocalUid]) {
        [self.thunderEngine stopLocalAudioStream:stopped];
        JLYLogInfo(@"localUID:%@ stopLocalAudioStream:%d",self.modulesManager.crossLocalUid,stopped);
        [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ %@",self.modulesManager.crossLocalUid,stopped ? @"muted" :@"unmuted"]];
    } else {
        [self.thunderEngine stopRemoteAudioStream:uid stopped:stopped];
        JLYLogInfo(@"localUID:%@  remoteUid: %@ stopRemoteAudioStream:%d",self.modulesManager.crossLocalUid,uid,stopped);
        [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"You %@ UID=%@",stopped ? @"muted" :@"unmuted",uid]];
    }
    dispatch_semaphore_signal(_semaphore);
}

- (void)back
{
    if (self.isLiving) {
        [self showAlertView];
    } else {
        [self leaveRoom];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peoplesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioLiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AudioLiveTableViewCell class]) forIndexPath:indexPath];
    AuidoUserModel *user = self.peoplesArray[indexPath.row];
    cell.model = user;
    if ([user.uid isEqualToString:self.modulesManager.crossLocalUid]) {
        cell.leftTextLabel.text = [user.uid stringByAppendingString:[NSString stringWithFormat:@"(%@)",[NSBundle jly_localizedStringWithKey:@"我"]]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AuidoUserModel *user = self.peoplesArray[indexPath.row];
    user.isSelected = !user.isSelected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self stopMircWithUid:user.uid stop:user.isSelected];
}

- (AudioToolBarView *)toolView
{
    if (!_toolView) {
        AudioToolBarView *view = [AudioToolBarView new];
        view.delegate = self;
        _toolView = view;
        [_toolView leftButtonsEnableAction:NO];
        [self.view addSubview:_toolView];
        [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.bottom.mas_offset(kSafeBottomHeight > 0 ? -15: -10);
            make.height.mas_offset(36.f);
        }];
    }
    return _toolView;
}

- (UIAlertController *)actionSheetAlertVC
{
    if (!_actionSheetAlertVC) {
        _actionSheetAlertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:[NSBundle jly_localizedStringWithKey:@"语音编码 单声道 16KHz 18kbps"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.thunderEngine setAudioConfig:THUNDER_AUDIO_CONFIG_SPEECH_STANDARD commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];
            self.audioConfig = THUNDER_AUDIO_CONFIG_SPEECH_STANDARD;
            [self.switchModeButton setTitle:[NSBundle jly_localizedStringWithKey:@"语音编码 单声道 16KHz 18kbps"] forState:UIControlStateNormal];
            JLYLogInfo(@"UID:%@  setAudioConfig:%@",self.modulesManager.crossLocalUid,@"语音编码 单声道 16KHz 18kbps");
            [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ joined with audio config = %@",self.modulesManager.crossLocalUid,[NSBundle jly_localizedStringWithKey:[self audioConfigLogsStringWithMode:self.audioConfig]]]];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:[NSBundle jly_localizedStringWithKey:@"音乐编码 双声道 44.1KHz 24kbps EAAC+"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.thunderEngine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_STANDARD_STEREO commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];
            self.audioConfig = THUNDER_AUDIO_CONFIG_MUSIC_STANDARD_STEREO;
            [self.switchModeButton setTitle:[NSBundle jly_localizedStringWithKey:@"音乐编码 双声道 44.1KHz 24kbps EAAC+"] forState:UIControlStateNormal];
            JLYLogInfo(@"UID:%@  setAudioConfig:%@",self.modulesManager.crossLocalUid,@"音乐编码 双声道 44.1KHz 24kbps EAAC+");
            [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ joined with audio config = %@",self.modulesManager.crossLocalUid,[NSBundle jly_localizedStringWithKey:[self audioConfigLogsStringWithMode:self.audioConfig]]]];
        }];
        
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:[NSBundle jly_localizedStringWithKey:@"音乐编码 单声道 48KHz 40kbps"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.thunderEngine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_STANDARD commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];
            self.audioConfig = THUNDER_AUDIO_CONFIG_MUSIC_STANDARD;
            [self.switchModeButton setTitle:[NSBundle jly_localizedStringWithKey:@"音乐编码 单声道 48KHz 40kbps"] forState:UIControlStateNormal];
            JLYLogInfo(@"UID:%@  setAudioConfig:%@",self.modulesManager.crossLocalUid,@"音乐编码 单声道 48KHz 40kbps");
            [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ joined with audio config = Speech 48KHz 40kbps",self.modulesManager.crossLocalUid]];
            [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ joined with audio config = %@",self.modulesManager.crossLocalUid,[NSBundle jly_localizedStringWithKey:[self audioConfigLogsStringWithMode:self.audioConfig]]]];
        }];
        UIAlertAction *action4 = [UIAlertAction actionWithTitle:[NSBundle jly_localizedStringWithKey:@"音乐编码 双声道 44.1KHz 128kbps AAC L"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.thunderEngine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];
            self.audioConfig = THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO;
            [self.switchModeButton setTitle:[NSBundle jly_localizedStringWithKey:@"音乐编码 双声道 44.1KHz 128kbps AAC L"] forState:UIControlStateNormal];
            JLYLogInfo(@"UID:%@  setAudioConfig:%@",self.modulesManager.crossLocalUid,@"音乐编码 双声道 44.1KHz 128kbps AAC L");
            [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ joined with audio config = %@",self.modulesManager.crossLocalUid,[NSBundle jly_localizedStringWithKey:[self audioConfigLogsStringWithMode:self.audioConfig]]]];
        }];
        UIAlertAction *action5 = [UIAlertAction actionWithTitle:[NSBundle jly_localizedStringWithKey:@"音乐编码 双声道 44.1KHz 192kbps AAC LC_192K"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.thunderEngine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO_192 commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];
            self.audioConfig = THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO_192;
            [self.switchModeButton setTitle:[NSBundle jly_localizedStringWithKey:@"音乐编码 双声道 44.1KHz 192kbps AAC LC_192K"] forState:UIControlStateNormal];
            JLYLogInfo(@"UID:%@  setAudioConfig:%@",self.modulesManager.crossLocalUid,@"音乐编码 双声道 44.1KHz 192kbps AAC LC_192K");
            [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ joined with audio config = %@",self.modulesManager.crossLocalUid,[NSBundle jly_localizedStringWithKey:[self audioConfigLogsStringWithMode:self.audioConfig]]]];
        }];
        UIAlertAction *action6 = [UIAlertAction actionWithTitle:[NSBundle jly_localizedStringWithKey:@"取消"] style:UIAlertActionStyleCancel handler:nil];
        [_actionSheetAlertVC addAction:action1];
        [_actionSheetAlertVC addAction:action2];
        [_actionSheetAlertVC addAction:action3];
        [_actionSheetAlertVC addAction:action4];
        [_actionSheetAlertVC addAction:action5];
        [_actionSheetAlertVC addAction:action6];
    }
    return _actionSheetAlertVC;
}

- (LiveWhineView *)whineView
{
    if (!_whineView) {
        _whineView = [LiveWhineView shareWhineView];
        [self.view addSubview:self.whineView];
        _whineView.delegate = self;
        _whineView.hidden = YES;
        [_whineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.bottom.mas_equalTo(self.toolView.mas_bottom);
        }];
    }
    return _whineView;
}

#pragma mark - AlertViewDelegate

- (void)sureAction
{
    [self leaveRoom];
    self.modulesManager.firstCreateData = NO;
    [self hideAlertView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction:(BOOL)isTimeOut
{
    [self hideAlertView];
}
#pragma mark - AudioToolBarViewDelegate

- (void)speakerSwitchClicked
{
    if ([self netStatusAlert]) {
        [self speakerClicked];
    };
}

- (void)earSwitchClicked
{
    if ([self netStatusAlert]) {
        [self earReturnClicked];
    }
}

- (void)whineClicked
{
    if ([self netStatusAlert]) {
        [self varietyClicked];
    }
}

#pragma mark cell action

- (void)apiClicked
{
    DocumentWebController *con = [[DocumentWebController alloc] init];
    NSString *url = kApiUrl;
    if ([NSBundle jly_currentLanguageIsEn]) {
        url = [url stringByAppendingString:@"audio/audio_README.md"];
    } else {
        url = [url stringByAppendingString:@"vaudio/audio_README.zh.md"];
    }
    con.documentUrl = url;
    con.title = @"API";
    [self.navigationController pushViewController:con animated:YES];
}

- (void)logClicked
{
    LogTableController *con = [[LogManager sharedInstance] getNewLogController];
    con.title = [NSBundle jly_localizedStringWithKey:@"日志"];
    [self.navigationController pushViewController:con animated:YES];
}

- (void)feedbackClicked
{
    FeedbackController *con = [FeedbackController new];
    con.uid = self.modulesManager.crossLocalUid;
    [self.navigationController pushViewController:con animated:YES];
}

//扬声器
- (void)speakerClicked
{
    self.localUserModel.speakerStoped = !self.localUserModel.speakerStoped;
    [self.thunderEngine enableLoudspeaker:!self.localUserModel.speakerStoped];
    JLYLogInfo(@"UID:%@  enableLoudspeaker:%d",self.modulesManager.crossLocalUid,!self.localUserModel.speakerStoped);
    [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ %@",self.modulesManager.crossLocalUid,self.localUserModel.speakerStoped ?@"switched to earphone" :@"switched to speaker"]];
    [self.toolView setSpeakerBtnStatusStopped:self.localUserModel.speakerStoped];
}

//耳返
- (void)earReturnClicked
{
    self.localUserModel.earClosed = !self.localUserModel.earClosed;
    [self.thunderEngine setEnableInEarMonitor:self.localUserModel.earClosed ];
    JLYLogInfo(@"UID:%@  setEnableInEarMonitor:%d",self.modulesManager.crossLocalUid,self.localUserModel.earClosed);
    [self.toolView setEarBtnStatusStopped:self.localUserModel.earClosed];
    [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ %@",self.modulesManager.crossLocalUid,self.localUserModel.earClosed ? @"Ear-in On":@"Ear-in Off"]];
}

//变声
- (void)varietyClicked
{
    self.whineView.hidden = !self.whineView.hidden;
}

- (AuidoUserModel *)audioUserModelWithUid:(NSString *)uid
{
    AuidoUserModel *userModel  = nil;
    for (AuidoUserModel *user in self.peoplesArray) {
        if ([user.uid isEqualToString:uid]) {
            userModel = user;
            return userModel;
        }
    }
    return nil;
}

#pragma mark - LiveWhineViewDelegate
- (NSString *)modeStringWithMode:(ThunderRtcVoiceChangerMode)mode
{
    NSString *logstring = nil;
    if (mode == THUNDER_VOICE_CHANGER_ETHEREAL) {
        logstring = @"Ethereal";
    } else if (mode == THUNDER_VOICE_CHANGER_THRILLER) {
        logstring = @"Thriller";
    } else if (mode == THUNDER_VOICE_CHANGER_LUBAN) {
        logstring = @"Luban";
        
    } else if (mode == THUNDER_VOICE_CHANGER_LORIE) {
        logstring = @"Lorie";
    } else if (mode == THUNDER_VOICE_CHANGER_UNCLE) {
        logstring = @"Uncle";
    } else if (mode == THUNDER_VOICE_CHANGER_DIEFAT) {
        logstring = @"Die-fat";
    } else if (mode == THUNDER_VOICE_CHANGER_BADBOY) {
        logstring = @"Bad boy";
        
    } else if (mode == THUNDER_VOICE_CHANGER_WRACRAFT) {
        logstring = @"Wracraft";
    } else if (mode == THUNDER_VOICE_CHANGER_HEAVYMETAL) {
        logstring = @"Heavy metal";
    } else if (mode == THUNDER_VOICE_CHANGER_COLD) {
        logstring = @"Cold";
    } else if (mode == THUNDER_VOICE_CHANGER_HEAVYMECHINERY) {
        logstring = @"Heavy machinery";
    } else if (mode == THUNDER_VOICE_CHANGER_TRAPPEDBEAST) {
        logstring = @"Trapped breast";
    } else if (mode == THUNDER_VOICE_CHANGER_POWERCURRENT) {
        logstring =  @"Power current";
    }
    return logstring;
}

- (void)whineViewSetVoiceChanger:(ThunderRtcVoiceChangerMode)mode
{
    [self.thunderEngine setVoiceChanger:mode];
    JLYLogInfo(@"UID:%@  setVoiceChanger mode:%ld",self.modulesManager.crossLocalUid,(long)mode);
    [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ changed voice to %@",self.modulesManager.crossLocalUid,[self modeStringWithMode:mode]]];
}

- (void)offWhine
{
    [self.thunderEngine setVoiceChanger:THUNDER_VOICE_CHANGER_NONE];
    [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ turned off voice changer",self.modulesManager.crossLocalUid]];
}

- (void)onWhineWithMode:(ThunderRtcVoiceChangerMode)mode
{
    [self.thunderEngine setVoiceChanger:mode];
    [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ changed voice to %@",self.modulesManager.crossLocalUid,[self modeStringWithMode:mode]]];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length == 0) {
        [self.startLiveButton setBackgroundImage:[UIImage imageNamed:@"joinroom_bg"] forState:UIControlStateNormal];
    }
    if (self.localRoomIDTextField.text.length > 0 && self.localUIDTextField.text.length > 0) {
        [self.startLiveButton setBackgroundImage:[UIImage imageNamed:@"joinroom_selectedbg"] forState:UIControlStateNormal];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.modulesManager.crossLocalUid = self.localUIDTextField.text;
    self.modulesManager.crossLocalRoomId = self.localRoomIDTextField.text;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    ///不能以0开始
    if (range.length == 0 && range.location == 0 && [string isEqualToString:@"0"]) {
        textField.text = nil;
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.whineView.hidden = YES;
}

#pragma mark - ThunderEventDelegate
- (void) thunderEngine:(ThunderEngine *)engine onJoinRoomSuccess:(NSString *)room withUid:(NSString *)uid elapsed:(NSInteger)elapsed
{
    JLYLogInfo(@"UID:%@  onJoinRoomSuccess  start",self.modulesManager.crossLocalUid);
    [_toolView leftButtonsEnableAction:YES];
    [self.thunderEngine setEnableInEarMonitor:NO];
    JLYLogInfo(@"UID:%@  setEnableInEarMonitor: 0",self.modulesManager.crossLocalUid);
    [self.thunderEngine stopAllRemoteAudioStreams:NO];
    JLYLogInfo(@"UID:%@  stopAllRemoteAudioStreams: 0",self.modulesManager.crossLocalUid);
    [self.thunderEngine stopLocalAudioStream:NO];
    JLYLogInfo(@"UID:%@  stopLocalAudioStream: 0",self.modulesManager.crossLocalUid);
    self.switchModeButton.selected = YES;
    self.switchModeButton.userInteractionEnabled = NO;
    [self reloadPeopleListViewWithUid:uid];
    JLYLogInfo(@"UID:%@  onJoinRoomSuccess  end",self.modulesManager.crossLocalUid);
    
}

- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onRemoteAudioStopped:(BOOL)stopped byUid:(nonnull NSString *)uid
{
    [self remoteUserAudioStopedWithUid:uid stoped:stopped];
    JLYLogInfo(@"UID:%@  onRemoteAudioStopped:%d byUid:%@",self.modulesManager.crossLocalUid,stopped, uid);
}

- (void)remoteUserAudioStopedWithUid:(NSString *)uid stoped:(BOOL)stoped
{
    if (stoped) {
        // Resume streaming mute operation
        [self.thunderEngine stopRemoteAudioStream:uid stopped:NO];
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        __block AuidoUserModel *stopUser  = nil;
        [self.peoplesArray enumerateObjectsUsingBlock:^(AuidoUserModel * _Nonnull userUid, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([userUid.uid isEqualToString:uid]) {
                stopUser = userUid;
                *stop = YES;
            }
        }];
        if (stopUser) {
            [self.peoplesArray removeObject:stopUser];
            [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ left",uid]];
            [self.audienceTableView reloadData];
        }
        dispatch_semaphore_signal(_semaphore);
    }
}

- (void)thunderEngine:(ThunderEngine *)engine onLeaveRoomWithStats:(ThunderRtcRoomStats *)stats
{
    JLYLogInfo(@"UID:%@  onLeaveRoomWithStats  start",self.modulesManager.crossLocalUid);
    self.isLiving = NO;
    [self.peoplesArray removeAllObjects];
    [_audienceTableView reloadData];
    [_toolView leftButtonsEnableAction:NO];
    // 关闭的流进行恢复
    // Closed stream for recovery
    [self.thunderEngine stopAllRemoteAudioStreams:YES]; // 为了让下面的stopAllRemoteVideoStreams生效/In order for the following stopAllRemoteVideoStreams to take effect
    [self.thunderEngine stopAllRemoteAudioStreams:NO];
}

- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onPlayVolumeIndication:(NSArray<ThunderRtcAudioVolumeInfo *> * _Nonnull)speakers
          totalVolume:(NSInteger)totalVolume
{
    // 加锁
    // add semaphore
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    if (self.peoplesArray.count == 0) {
        // 添加本地用户
        // add local user
        [self.peoplesArray addObject:[AuidoUserModel auidoUserModelWithUid:self.modulesManager.crossLocalUid]];
    }
    
    if (self.peoplesArray.count == 1) {
        // 添加正在说话的人
        // add talking user
        for (ThunderRtcAudioVolumeInfo *user in speakers) {
            [self.peoplesArray addObject:[AuidoUserModel auidoUserModelWithUid:user.uid]];
            if (![user.uid isEqualToString:self.modulesManager.crossLocalUid]) {
            [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ joined",user.uid]];
            }
        }
        [self.audienceTableView reloadData];
    } else {
        // 同步音量数据已经添加新的用户
        // Synchronized volume data has been added for new users
        NSMutableArray *newSpeakers = [[NSMutableArray alloc] init];
        [speakers enumerateObjectsUsingBlock:^(ThunderRtcAudioVolumeInfo *obj, NSUInteger idx, BOOL *stop) {
            __block BOOL found = NO;
            [self.peoplesArray enumerateObjectsUsingBlock:^(AuidoUserModel *user, NSUInteger index, BOOL *theStop) {
                if ([obj.uid isEqualToString:user.uid]) {
                    // 单条更新，避免滚动reloadData卡顿
                    // Update single cell, avoid rolling reloadData stuck
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [_audienceTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    found = YES;
                    *theStop = YES;
                }
            }];
            if (!found) {
                [newSpeakers addObject:[AuidoUserModel auidoUserModelWithUid:obj.uid]];
                [self reloadLogsContentViewWithString:[NSString stringWithFormat:@"UID=%@ joined",obj.uid]];
            }
        }];
        // 如果有新加成员
        // If there are new members
        if (newSpeakers.count) {
            [self.peoplesArray addObjectsFromArray:newSpeakers];
            [_audienceTableView reloadData];
        }
    }
    dispatch_semaphore_signal(_semaphore);
}

- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onCaptureVolumeIndication:(NSInteger)totalVolume cpt:(NSUInteger)cpt micVolume:(NSInteger)micVolume
{
    // 加锁
    // Add semaphore
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    // 设置本地音量
    // Set local volume
    // 如果只有自己时更新数据，否则同其他音量数据在onPlayVolumeIndication里更新
    // Update the data if only you own, otherwise update it with other volume data in onPlayVolumeIndication
    if (self.peoplesArray.count <= 1) {
        
        if (self.peoplesArray.count == 0) {
            [self.peoplesArray addObject:[AuidoUserModel auidoUserModelWithUid:self.modulesManager.crossLocalUid]];
            [self.audienceTableView reloadData];
        } else {
            // 单条更新，避免滚动reloadData卡顿
            // Update single cell, avoid rolling reloadData stuck
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.audienceTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    dispatch_semaphore_signal(_semaphore);
}

#pragma mark - Logs

- (void)reloadLogsContentViewWithString:(NSString *)logString
{
    self.logsContenView.text = [self.logsContenView.text stringByAppendingFormat:@"[%@] %@\n",[NSDate jyl_getCurrentTimeString],logString];
}

@end
