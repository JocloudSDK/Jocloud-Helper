//
//  LivePublicTalkView.m
//  app
//
//  Created by 宁丽环 on 2020/7/16.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LivePublicTalkView.h"
#import "LivePublicTalkCell.h"
#import "UIColor+SLExtention.h"
#import "NSString+BGExtension.h"
#import "AppConfigInfo.h"


@interface LivePublicTalkView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *talkTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

static NSString *reuseIdentifier = @"LivePublicTalkCell";

@implementation  LivePublicTalkModel

+ (instancetype)livePublicTalkModelWithJsonString:(NSString *)jsonString
{
    LivePublicTalkModel *model = [[LivePublicTalkModel alloc]init];
    NSDictionary *messageDict = [jsonString yy_jsonObjectFromString];
    model.uid = [messageDict objectForKey:@"Uid"];
    model.time = [messageDict objectForKey:@"time"];
    model.message = [messageDict objectForKey:@"message"];
    model.type = [messageDict objectForKey:@"type"];
    return model;
}

@end

@implementation LivePublicTalkView
- (instancetype)init
{
    if (self == [super init]) {
        self = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([LivePublicTalkView class]) owner:nil options:nil].lastObject;
        self.talkTableView.delegate = self;
        self.talkTableView.dataSource = self;
        [self.talkTableView registerNib:[UINib nibWithNibName:NSStringFromClass([LivePublicTalkCell class]) bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    }
    return self;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (NSAttributedString *)fectoryTalkStringWithString:(NSString *)str color:(UIColor *)color
{
    return [[NSAttributedString alloc]initWithString:str attributes:@{NSForegroundColorAttributeName: color,NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
}

#pragma mark- TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LivePublicTalkCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor sl_colorWithHexString:@"#F7F8FC"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.uidLabel.textColor = [UIColor clearColor];
    cell.timeLabel.textColor = [UIColor clearColor];
    LivePublicTalkModel *model = self.dataArray[indexPath.row];
    NSAttributedString *attributedString = nil;
    if ([model.type isEqualToString:kMessageMsg]) {
        attributedString = [self fectoryTalkStringWithString:model.message color:[UIColor sl_colorWithHexString:@"#1C1C1C"]];
        cell.uidLabel.textColor = [UIColor sl_colorWithHexString:@"#1C1C1C"];
        cell.timeLabel.textColor = [UIColor sl_colorWithHexString:@"#1C1C1C"];
    } else {
        attributedString = [self fectoryTalkStringWithString:model.message color:[UIColor sl_colorWithHexString:@"#FFC94C"]];
        cell.uidLabel.textColor = [UIColor sl_colorWithHexString:@"#FFC94C"];
        cell.timeLabel.textColor = [UIColor sl_colorWithHexString:@"#FFC94C"];
    }
    cell.talkLable.attributedText = attributedString;
    cell.uidLabel.text = model.uid;
    cell.timeLabel.text = model.time;
    return cell;
}

- (void)reloadWithDataString:(NSString *)dataString
{
    LivePublicTalkModel *model = [LivePublicTalkModel livePublicTalkModelWithJsonString:dataString];
    [self.dataArray addObject:model];
    [self.talkTableView reloadData];
    [self.talkTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (void)clean
{
    [self.dataArray removeAllObjects];
    [self.talkTableView reloadData];
}
@end
