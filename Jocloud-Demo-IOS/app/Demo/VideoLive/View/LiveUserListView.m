//
//  LiveUserListView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/5.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveUserListView.h"
#import "NSBundle+Language.h"
#import "UIColor+SLExtention.h"


@interface LiveUserListView()<UITableViewDelegate, UITableViewDataSource>
/** 全员禁言*/
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *shutupBtn;
/** 用户列表*/
@property (nonatomic, weak) IBOutlet UITableView *userTableView;

// 需要的是主播列表，还是观众列表
@property (nonatomic, assign)BOOL needAnchor;

@end
static  NSString *reuseIdentifier = @"LiveListTableViewCell";
@implementation LiveUserListView

+ (instancetype)liveUserListView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
    self.userTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.userTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    [self.shutupBtn setTitle:NSLocalizedString(@"Ban All",nil) forState:UIControlStateNormal];
    [self.shutupBtn setTitle:NSLocalizedString(@"Unban All",nil) forState:UIControlStateSelected];
    self.shutupBtn.hidden = YES;
    self.userTableView.rowHeight = 40.0f;
    UITapGestureRecognizer *hidden = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidden)];
    [self addGestureRecognizer:hidden];
    self.titleLabel.text = [NSBundle jly_localizedStringWithKey:@"房间人员"];
   
}

- (void)hidden
{
    self.hidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
  return self.userDataArray.count;
   
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HMRUserId *user = self.userDataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%llu",user.ID];
    cell.textLabel.textColor = [UIColor sl_colorWithHexString:@"#1C1C1C"];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    if (user.ID == [HMRMe getMe].ID) {
        cell.textLabel.text = [NSString stringWithFormat:@"%llu(%@)",user.ID,[NSBundle jly_localizedStringWithKey:@"我"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = nil;
        //观众列表管理
        model = self.userDataArray[indexPath.row];
        if (self.clickBlock) {
            
            self.clickBlock(NO, model);
        }
    
}

- (void)refreshUserViewWithRoomId:(NSString *)roomId
{
    //@"在线观众"
    [self.userTableView reloadData];
}


- (void)refreshAnchorViewWithArray:(NSArray<HMRUserId *> *)dataArray
{
    self.userDataArray = nil;
    //@"在线主播"
    self.titleLabel.text = NSLocalizedString(@"Broadcasters",nil);
    self.shutupBtn.hidden  = YES;
    [self.userTableView reloadData];
}


- (IBAction)allMuteBtnClick:(UIButton *)sender
{
    if (self.allMuteBlock) {
        self.allMuteBlock(sender);
    }
}
- (void)setUserDataArray:(NSMutableArray *)userDataArray
{
    _userDataArray = userDataArray;
    NSMutableArray *tempArray = [_userDataArray mutableCopy];
    for (HMRUserId *user in tempArray) {
        if (user.ID == [HMRMe getMe].ID) {
            [_userDataArray exchangeObjectAtIndex:0 withObjectAtIndex:[_userDataArray indexOfObject:user]];
        }
    }
    [self.userTableView reloadData];
    
}

@end
