//
//  QuickStartCell.m
//  app
//
//  Created by GasparChu on 2020/6/1.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "QuickStartCell.h"
#import "NSBundle+Language.h"

@interface QuickStartCell ()
@property (nonatomic, weak) IBOutlet UIView *crossChannelView;
@property (nonatomic, weak) IBOutlet UIView *sameChannelView;
@property (nonatomic, weak) IBOutlet UILabel *quickLabel;
@property (nonatomic, weak) IBOutlet UILabel *desLabel;
@property (nonatomic, weak) IBOutlet UILabel *crossLabel;
@property (nonatomic, weak) IBOutlet UILabel *sameLabel;

@end

@implementation QuickStartCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self refreshView];
}

- (void)refreshView
{
    self.quickLabel.text = [NSBundle jly_localizedStringWithKey:@"快速开始"];
    self.desLabel.text = [NSBundle jly_localizedStringWithKey:@"使用媒体和消息SDK的基础功能快速实现视频互动"];
    self.crossLabel.text = [NSBundle jly_localizedStringWithKey:@"跨房间连麦"];
    self.sameLabel.text = [NSBundle jly_localizedStringWithKey:@"同房间多人连麦"];
}

- (IBAction)clickCrossChannel:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(clickCrossChannel)]) {
        [self.delegate clickCrossChannel];
    }
    self.crossChannelView.backgroundColor = [UIColor clearColor];
}

- (IBAction)touchDownCrossChannel:(UIButton *)sender
{
    self.crossChannelView.backgroundColor = [UIColor colorWithRed:245/255.0 green:247/255.0 blue:253/255.0 alpha:1.0];
}

- (IBAction)touchOutCrossChannel:(UIButton *)sender
{
    self.crossChannelView.backgroundColor = [UIColor clearColor];
}

- (IBAction)clickSameChannel:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(clickSameChannel)]) {
        [self.delegate clickSameChannel];
    }
    self.sameChannelView.backgroundColor = [UIColor clearColor];
}

- (IBAction)touchDownSameChannel:(UIButton *)sender
{
    self.sameChannelView.backgroundColor = [UIColor colorWithRed:245/255.0 green:247/255.0 blue:253/255.0 alpha:1.0];
}

- (IBAction)touchOutSameChannel:(UIButton *)sender
{
    self.sameChannelView.backgroundColor = [UIColor clearColor];
}

@end
