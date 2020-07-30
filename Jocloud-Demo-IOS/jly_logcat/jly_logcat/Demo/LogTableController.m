//
//  LogTableController.m
//  jly_logcat
//
//  Created by GasparChu on 2020/5/27.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LogTableController.h"
#import "LogTableCell.h"
#import "LogModel.h"

static NSString * const LogTableCellKey = @"LogTableCell";

@interface LogTableController ()

@property (nonatomic, strong) NSArray *dataArray;
// 是否正在拖动
// Is draging
@property (nonatomic, assign) BOOL draging;

@end

@implementation LogTableController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.estimatedRowHeight = 44.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LogTableCell class] forCellReuseIdentifier:LogTableCellKey];
}

- (void)setData:(NSArray *)data
{
    _dataArray = data;
    [self.tableView reloadData];
    if (self.dataArray.count > 0 && !self.draging) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogTableCell *cell = [tableView dequeueReusableCellWithIdentifier:LogTableCellKey forIndexPath:indexPath];
    LogModel *model = self.dataArray[indexPath.row];
    cell.contentLabel.textColor = model.textColor;
    cell.contentLabel.text = model.text;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.estimatedRowHeight;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.draging = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.draging = NO;
}

@end
