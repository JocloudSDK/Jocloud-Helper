//
//  VideoLiveViewController.m
//  app
//
//  Created by 宁丽环 on 2020/7/7.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "VideoLiveViewController.h"
#import "VideoLiveBroadcastViewController.h"
#import "VideoLiveHomeTableViewCell.h"
#import "AFNetworking.h"
#import "MBProgressHUD+JLYHUD.h"
#import "AppDelegate.h"


@interface VideoLiveViewController ()<UITableViewDelegate,UITableViewDataSource,VideoLiveHomeTableViewCellDelegate,UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *roomID;
@end

@implementation VideoLiveViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self endFullScreen];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSBundle jly_localizedStringWithKey:@" 视频开播进阶用法 "];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([VideoLiveHomeTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([VideoLiveHomeTableViewCell class])];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoLiveHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([VideoLiveHomeTableViewCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - VideoLiveHomeTableViewCellDelegate

//创建房间
- (void)clickCreateChannel
{
    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (AFNetworkReachabilityStatusUnknown == netStatus || AFNetworkReachabilityStatusNotReachable == netStatus) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"网络异常"]];
        return;
    }
    VideoLiveBroadcastViewController *vc = [[VideoLiveBroadcastViewController alloc]init];
    vc.isAnchor = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//加入房间
- (void)clickJoinChannel
{
    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (AFNetworkReachabilityStatusUnknown == netStatus || AFNetworkReachabilityStatusNotReachable == netStatus) {
        [MBProgressHUD jly_showToast:[NSBundle jly_localizedStringWithKey:@"网络异常"]];
        return;
    }
    VideoLiveBroadcastViewController *vc = [[VideoLiveBroadcastViewController alloc]init];
    vc.isAnchor = NO;
    vc.roomId = self.roomID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.roomID = textField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //roomid 开头不为0
    if (range.length == 0 && range.location == 0 && [string isEqualToString:@"0"]) {
        textField.text = nil;
        return NO;
    }
    VideoLiveHomeTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (range.length == 1 && string.length == 0) {
        if (range.location  == 0) {
            cell.joinButtonEnable = NO;
        }
        return YES;
        
    } else if (textField.text.length >= 8) {
        
        textField.text = [textField.text substringToIndex:8];
        cell.joinButtonEnable = YES;
        return NO;
        
    } else {
        cell.joinButtonEnable = YES;
        
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    VideoLiveHomeTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    cell.joinButtonEnable = NO;
    
    return YES;
}
@end
