//
//  JYLChatRoomViewController.m
//  app
//
//  Created by 宁丽环 on 2020/7/10.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "JYLChatRoomViewController.h"
#import "LivePublicTalkCell.h"
#import "LiveFunctionView.h"
#import "DocumentWebController.h"
#import "LogTableController.h"
#import "AppConfigInfo.h"
#import "UIImage+JLYBundle.h"
#import "LogManager.h"
#import "NSBundle+Language.h"
#import "FeedbackController.h"
#import "IQKeyboardManager.h"
#import "UIColor+SLExtention.h"
#import "HummerManager.h"
#import "MBProgressHUD+JLYHUD.h"
#import "Utils.h"
#import "NSString+BGExtension.h"
#import "NSDate+JYLExtention.h"
#import "LivePublicTalkView.h"
#import "LiveUserListView.h"
#import "AFNetworking.h"
#import "BaseMacro.h"
#import "LogHeader.h"
#import "ModulesDataManager.h"
#import "AlertView.h"
#import "UITextField+Expand.h"

// iPhone X系列判断
#define  IS_iPhoneX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size)  || CGSizeEqualToSize(CGSizeMake(414.f, 896.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(896.f, 414.f), [UIScreen mainScreen].bounds.size))
// 安全区域高度
#define TabbarSafeBottomMargin     (IS_iPhoneX ? 34.f : 0.f)
// 首页的选择器的宽度
#define Live_Tool_H 50

@interface JYLChatRoomViewController ()<LiveFunctionViewDelegate,UITextFieldDelegate,HMREventObserver, HMRPeerServiceObserver,HMRRoomObserver,HMRRoomMemberObserver,AlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *localUIDTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *localRoomIDTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *localUIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *localRoomIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *peopleListButton;
@property (nonatomic, strong) LiveFunctionView *rightFunctionView;
@property (nonatomic, strong) LivePublicTalkView *publicTalkView;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFieldHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFieldWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFieldLeftConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomContentView;
@property (nonatomic, strong) LiveUserListView *userListView;
@property (nonatomic, weak) IBOutlet UILabel *chatTextLabel;
@property (nonatomic, strong) HummerManager *hummerManager;
@property (nonatomic, assign) BOOL isLiveing;//是否正在开播
@property (nonatomic, strong) NSMutableArray *peoplesArray;
@property (nonatomic, assign) BOOL showUserList;//是否显示观众列表
@property (nonatomic, strong) ModulesDataManager *modulesManager;
@property (nonatomic, strong) AlertView *alertView;
@property (nonatomic, assign) BOOL isOFFline; //是否已经下线

@end

static NSString *reuseIdentifier = @"LivePublicTalkCell";

@implementation JYLChatRoomViewController

- (HummerManager *)hummerManager
{
    if (!_hummerManager) {
        _hummerManager = [HummerManager sharedManager];
    }
    return _hummerManager;
}

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

// 用户列表
- (LiveUserListView *)userListView
{
    if (!_userListView) {
        _userListView = [LiveUserListView liveUserListView];
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow addSubview:_userListView];
        _userListView.roomId = self.modulesManager.crossLocalRoomId;
        [_userListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        _userListView.hidden = YES;
    }
    return _userListView;
}

//显示用户列表
- (void)showUserListView
{
    self.userListView.hidden = NO;
}

- (LivePublicTalkView *)publicTalkView
{
    if (!_publicTalkView) {
        _publicTalkView = [[LivePublicTalkView alloc]init];
        [self.bottomContentView addSubview:_publicTalkView];
        [_publicTalkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.peopleListButton.mas_bottom).offset(10);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    return _publicTalkView;
}

- (LiveFunctionView *)rightFunctionView
{
    if (!_rightFunctionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
        CGFloat jyl_w =  190;
        _rightFunctionView = [[LiveFunctionView alloc]initWithLayout:layout];
        _rightFunctionView.dataArray =[NSMutableArray arrayWithArray:@[@[[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_feedback" functionType:LiveFunctionTypefeedback],[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_api" functionType:LiveFunctionTypeApi],[LiveFunctionModel liveFunctionModelWithTitle:nil selectedTitle:nil image:@"baseui_toolbar_log" functionType:LiveFunctionTypeLog]]]];
        [self.view addSubview:_rightFunctionView];
        _rightFunctionView.delegate = self;
        [_rightFunctionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(jyl_w);
            make.height.mas_equalTo(60);
        }];
    }
    return _rightFunctionView;
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

- (void)hideAlertView
{
    [self.alertView removeFromSuperview];
    _alertView = nil;
}

- (void)showAlertView
{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:self.alertView];
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(window);
    }];
}

//断网提示
- (BOOL)netStatusAlert
{
    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (AFNetworkReachabilityStatusUnknown == netStatus || AFNetworkReachabilityStatusNotReachable == netStatus) {
        return NO;
    } else{
        return YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    IQKeyboardManager *keyboardManager =  [IQKeyboardManager sharedManager];
    keyboardManager.enable = NO;
    keyboardManager.enableAutoToolbar = NO;
    self.navigationController.navigationBar.translucent = NO;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self createManager];
}



- (void)setupUI
{
    
    self.title = [NSBundle jly_localizedStringWithKey:@"聊天室"];
    [self setupLocalUID];
    [self setupLocalRoomId];
    [self.rightFunctionView refreshView];
    self.bottomContentView.hidden = YES;
    self.publicTalkView.hidden = YES;
    
    [self.startLiveButton setTitle:[NSBundle jly_localizedStringWithKey:@"加入房间"] forState:UIControlStateNormal];
    [self.startLiveButton setTitle:[NSBundle jly_localizedStringWithKey:@"退出房间"] forState:UIControlStateSelected];
    [self.startLiveButton setBackgroundImage:[UIImage imageNamed:@"joinroom_selectedbg"] forState:UIControlStateNormal];
    
    self.chatTextLabel.text = [NSBundle jly_localizedStringWithKey:@"    聊两句"];
    self.chatTextField.alpha = 0.5f;
    self.chatTextField.userInteractionEnabled = NO;
    
    [self.peopleListButton setTitle:[NSBundle jly_localizedStringWithKey:@"房间人员"] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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

- (void)createManager
{
    [self.hummerManager startWithAppId:kAppId.longLongValue appVersion:[Utils appVersion] eventObserver:self];
    [self.hummerManager setLoggerFilePath:kLogFilePath];
    [self.hummerManager addObserver:self];
}

#pragma mark-  action
- (IBAction)joinRoomButtonAction:(UIButton *)sender
{
    if ([self netStatusAlert]) {
        [self.localRoomIDTextField resignFirstResponder];
        [self.localRoomIDTextField resignFirstResponder];
        self.modulesManager.crossLocalRoomId = self.localRoomIDTextField.text;
        self.modulesManager.crossLocalUid = self.localUIDTextField.text;
        if (self.modulesManager.crossLocalRoomId.length == 0  || self.modulesManager.crossLocalUid.length == 0) {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"请完成输入"]];
            return;
        }
        if (!sender.selected) {
            [self joinRoom];
        } else {
            [self leaveRoom];
        }
    } else {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"网络异常"]];
    }
}

- (void)joinRoom
{
    [self.hummerManager loginWithUid:self.modulesManager.crossLocalUid.longLongValue region:[self.hummerManager region] token:@"" completion:^(HMRRequestId reqId, NSError *error) {
        JLYLogInfo(@"UID:%@  loginWithUid Success",self.modulesManager.crossLocalUid);
        
        if (!error) {
            [self.hummerManager joinRoom:self.modulesManager.crossLocalRoomId completion:^(HMRRequestId reqId, NSError *error) {
                if (!error) {
                    JLYLogInfo(@"UID:%@  onJoinRoomSuccess",self.modulesManager.crossLocalUid);
                    self.isLiveing = YES;
                    self.localUIDTextField.userInteractionEnabled = NO;
                    self.localRoomIDTextField.userInteractionEnabled = NO;
                    self.chatTextField.alpha = 1.0f;
                    self.chatTextField.userInteractionEnabled = YES;
                    self.bottomContentView.hidden = NO;
                    self.publicTalkView.hidden = NO;
                    self.startLiveButton.selected = YES;
                    //获取房间人数
                    [self getRoomUserList];
                    
                } else {
                    self.chatTextField.alpha = 0.5f;
                    self.chatTextField.userInteractionEnabled = NO;
                    self.startLiveButton.selected = NO;
                    [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"进入房间失败"]];
                    JLYLogInfo(@"UID:%@  onJoinRoomSuccess error",self.modulesManager.crossLocalUid);
                }
            }];
        } else {
            self.chatTextField.alpha = 0.5f;
            self.chatTextField.userInteractionEnabled = NO;
            self.startLiveButton.selected = NO;
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"登录失败"]];
            JLYLogInfo(@"UID:%@  loginWithUid error",self.modulesManager.crossLocalUid);
        }
    }];
}

- (void)leaveRoom
{
    [self.hummerManager logout];
    JLYLogInfo(@"UID:%@  logout",self.modulesManager.crossLocalUid);
    self.isLiveing = NO;
    self.isOFFline = NO;
    self.showUserList = NO;
    self.localUIDTextField.userInteractionEnabled = YES;
    self.localRoomIDTextField.userInteractionEnabled = YES;
    self.chatTextField.alpha = 0.5f;
    self.chatTextField.userInteractionEnabled = NO;
    [self.publicTalkView clean];
    self.bottomContentView.hidden = YES;
    self.startLiveButton.selected = NO;
}

- (void)back
{
    if (self.isLiveing) {
        [self showAlertView];
    } else {
        [self leaveRoom];
        self.modulesManager.firstCreateData = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)showPeopleList:(UIButton *)sender
{
    if ([self netStatusAlert]) {
        if (self.isOFFline) {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"断线超时，已退出房间"]];
            return;
        }
        self.showUserList = YES;
        [self getRoomUserList];
    } else {
        if (!self.isOFFline) {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"网络异常"]];
        } else {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"断线超时，已退出房间"]];
        }
    }
}

- (void)apiClicked
{
    DocumentWebController *con = [[DocumentWebController alloc] init];
    NSString *url = kApiUrl;
    if ([NSBundle jly_currentLanguageIsEn]) {
        url = [url stringByAppendingString:@"chat_room/chat_room_README.md"];
    } else {
        url = [url stringByAppendingString:@"chat_room/chat_room_README.zh.md"];
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

- (void)refreshPeopleCount:(NSInteger)count
{
    [self.peopleListButton setTitle:[[NSBundle jly_localizedStringWithKey:@"房间人数"] stringByAppendingFormat:@":%ld",count] forState:UIControlStateNormal];
}

#pragma mark- LiveFunctionViewDelegate

- (void)liveFunctionViewDidSelectItemWithType:(LiveFunctionType)type selected:(BOOL)selected
{
    switch (type) {
        case LiveFunctionTypeApi:
            [self apiClicked];
            break;
        case LiveFunctionTypeLog:
            [self logClicked];
            break;
        case LiveFunctionTypefeedback:
            [self feedbackClicked];
            break;
        default:
            break;
    }
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.chatTextField]) {
        NSDictionary *messageDict = @{
            @"Uid" :self.modulesManager.crossLocalUid,
            @"message":[textField.text copy],
            @"time":[NSDate jyl_currentDateStr],
            @"type":kMessageMsg
        };
        [self sendMessageWithDictionary:messageDict];
        textField.text = nil;
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.localRoomIDTextField] || [textField isEqual:self.localUIDTextField]) {
        if (range.length == 0 && range.location == 0 && [string isEqualToString:@"0"]) {
            textField.text = nil;
            return NO;
        }
        return YES;
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark - 发送文字消息

- (void)sendMessageWithDictionary:(NSDictionary *)messageDict
{
    if ([self netStatusAlert]) {
        if (self.isOFFline) {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"断线超时，已退出房间"]];
            return;
        }
        NSMutableString *sendString = [[NSMutableString alloc]initWithString:[NSString yy_stringFromJsonObject:messageDict]];
        if ([[messageDict objectForKey:@"type"] isEqualToString:kNoticeMsg]) {
            [self.publicTalkView reloadWithDataString:sendString];
            
        } else if ([[messageDict objectForKey:@"type"] isEqualToString:kMessageMsg]) {
            [self.hummerManager sendMessage:sendString inRoom:self.modulesManager.crossLocalRoomId completionHandler:^(NSError * _Nullable error) {
            }];
        }
    } else {
        if (!self.isOFFline) {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"网络异常"]];
        } else {
            [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"断线超时，已退出房间"]];
        }
    }
}

#pragma mark  - 键盘通知

- (void)keyboardWillShow:(NSNotification *)note
{
    if (!self.chatTextField.isFirstResponder) {
        return;
    }
    NSValue *value = [note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat animationDuration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions animationCurve = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.chatTextField.placeholder = [NSBundle jly_localizedStringWithKey:@"    聊两句"];
    typeof (self)weakSelf = self;
    
    [UIView animateWithDuration:animationDuration delay:0 options:animationCurve animations:^{
        weakSelf.textFieldBottomConstraint.constant =  [value CGRectValue].size.height;
        weakSelf.chatTextFieldWidthConstraint.constant = SCREEN_WIDTH;
        weakSelf.chatTextFieldLeftConstraint.constant = 0;
    } completion:nil];
    
}

- (void)keyboardWillHide:(NSNotification *)note
{
    if (!self.chatTextField.isFirstResponder) {
        return;
    }
    self.textFieldBottomConstraint.constant = 20;
    self.chatTextFieldLeftConstraint.constant = 20;
    self.chatTextFieldWidthConstraint.constant = 80;
    self.chatTextField.placeholder = nil;
    self.chatTextField.text = nil;
}





#pragma mark - AlertViewDelegate
- (void)sureAction
{
    [self leaveRoom];
    self.modulesManager.firstCreateData = NO;
    [self.navigationController popViewControllerAnimated:YES];
    [self hideAlertView];
}

- (void)cancelAction:(BOOL)isTimeOut
{
    [self hideAlertView];
}

- (void)getRoomUserList
{
    [self.hummerManager queryMembers:self.modulesManager.crossLocalRoomId completion:^(HMRRequestId  _Nonnull requestId, NSArray<HMRUserId *> * _Nonnull members, NSError * _Nonnull error) {
        if (!error) {
            [self.peoplesArray removeAllObjects];
            [self.peoplesArray addObjectsFromArray:members];
            self.userListView.userDataArray = self.peoplesArray;
            if (self.showUserList) {
                [self showUserListView];
            }
            JLYLogInfo(@"UID:%@  queryMembers success",self.modulesManager.crossLocalUid);
            
        } else {
            JLYLogInfo(@"UID:%@  queryMembers error:%@",self.modulesManager.crossLocalUid, error);
        }
    }];
}

#pragma mark - HMRRoomObserver
- (void)didRoomMessageReceived:(HMRMessage *)message fromUser:(HMRUserId *)user inRoom:(HMRRoomId *)roomId
{
    NSString *dataString  =[[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding];
    [self.publicTalkView reloadWithDataString:dataString];
}

#pragma mark - HMRRoomMemberObserver

- (void)didRoomMemberJoined:(NSSet<HMRUserId *> *)members inRoom:(HMRRoomId *)roomId
{
    for (HMRUserId *user in members) {
        NSDictionary *messageDict = @{
            @"Uid" :[NSString stringWithFormat:@"%llu",user.ID],
            @"message":[NSString stringWithFormat:@"%@ %@",[NSBundle jly_localizedStringWithKey:@"【系统消息】"],[NSBundle jly_localizedStringWithKey:@"进入房间"]],
            @"time":[NSDate jyl_currentDateStr],
            @"type":kNoticeMsg
        };
        JLYLogInfo(@"UID:%llu  didRoomMemberJoined",user.ID);
        [self sendMessageWithDictionary:messageDict];
        if (![self.peoplesArray containsObject:user]) {
            [self.peoplesArray addObject:user];
        }
    }
}

- (void)didRoomMemberLeft:(NSSet<HMRUserId *> *)members inRoom:(HMRRoomId *)roomId
{
    for (HMRUserId *user in members) {
        NSDictionary *messageDict = @{
            @"Uid" :[NSString stringWithFormat:@"%llu",user.ID],
            @"message":[NSString stringWithFormat:@"%@ %@",[NSBundle jly_localizedStringWithKey:@"【系统消息】"],[NSBundle jly_localizedStringWithKey:@"离开房间"]],
            @"time":[NSDate jyl_currentDateStr],
            @"type":kNoticeMsg
        };
        JLYLogInfo(@"UID:%llu  didRoomMemberLeft",user.ID);
        [self sendMessageWithDictionary:messageDict];
        if ([self.peoplesArray containsObject:user]) {
            [self.peoplesArray removeObject:user];
        }
    }
}

- (void)didRoomMemberCountChanged:(HMRRoomId *)roomId
                          ofCount:(NSInteger)count
{
    [self refreshPeopleCount:count];
}

///断网超时
- (void)didRoomMemberOffline:(NSSet<HMRRoomId *> *)roomIds
{
    self.isOFFline = YES;
    [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"断线超时，已退出房间"]];
    JLYLogInfo(@"UID:%@  didRoomMemberOffline",self.modulesManager.crossLocalUid);
}


@end
