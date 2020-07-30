//
//  VideoLiveHomeTableViewCell.m
//  app
//
//  Created by 宁丽环 on 2020/7/11.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "VideoLiveHomeTableViewCell.h"
#import "NSBundle+Language.h"
#import "UIColor+SLExtention.h"


@interface VideoLiveHomeTableViewCell ()<UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UILabel *startLiveLabel;
@property (nonatomic, weak) IBOutlet UILabel *audienceJoinLabel;
@property (nonatomic, weak) IBOutlet UIButton *createRoomButton;
@property (nonatomic, weak) IBOutlet UIButton *joinRoomButton;
//进阶用法
@property (nonatomic, weak) IBOutlet UITextView *remarkTextView;

@property (nonatomic, weak) IBOutlet UITextField *roomNamberTextField;

@end

@implementation VideoLiveHomeTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.roomNamberTextField.delegate = self;
    self.startLiveLabel.text = [NSBundle jly_localizedStringWithKey:@"开播进入"];
    self.audienceJoinLabel.text = [NSBundle jly_localizedStringWithKey:@"观看进入"];
    [self.createRoomButton setTitle:[NSBundle jly_localizedStringWithKey:@"创建房间"] forState:UIControlStateNormal];
    self.roomNamberTextField.placeholder = [NSBundle jly_localizedStringWithKey:@"最多8位数字"];
    [self.joinRoomButton setTitle:[NSBundle jly_localizedStringWithKey:@"加入房间"] forState:UIControlStateNormal];
   
    self.remarkTextView.text = [NSBundle jly_localizedStringWithKey:
                                @"本Demo演示以下视频开播进阶用法:\n- 横竖屏开播\n- 渲染模式\n- 镜像\n- 开关\n- 档位\n- 前后摄像头切换"];
    self.createRoomButton.layer.cornerRadius = 2.0f;
    self.createRoomButton.layer.masksToBounds = YES;
    self.roomNamberTextField.layer.borderColor = [UIColor sl_colorWithHexString:@"#D3D5DA"].CGColor;
    
    self.roomNamberTextField.layer.borderWidth = 0.5f;
    self.roomNamberTextField.layer.cornerRadius = 2.0f;
    self.roomNamberTextField.layer.masksToBounds = YES;
    
    self.joinRoomButton.layer.cornerRadius = 2.0f;
    self.joinRoomButton.layer.masksToBounds = YES;
    self.remarkTextView.layer.borderWidth = 0.5f;
    self.remarkTextView.layer.borderColor = [UIColor sl_colorWithHexString:@"#D3D5DA"].CGColor;
    self.remarkTextView.layer.cornerRadius = 2.0f;
    self.remarkTextView.layer.masksToBounds = YES;
}

- (void)setDelegate:(id<VideoLiveHomeTableViewCellDelegate,UITextFieldDelegate>)delegate
{
    _delegate = delegate;
    self.roomNamberTextField.delegate = _delegate;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (IBAction)createRoomBtnClicked:(UIButton *)sender
{
     [self.roomNamberTextField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCreateChannel)]) {
        [self.delegate clickCreateChannel];
    }
}

- (IBAction)joinRoomBtnClicked:(UIButton *)sender
{
    [self.roomNamberTextField resignFirstResponder];
    if (self.roomNamberTextField.text.length) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickJoinChannel)]) {
            [self.delegate clickJoinChannel];
        }
    }
}

- (void)setJoinButtonEnable:(BOOL)joinButtonEnable
{
    self.joinRoomButton.selected = joinButtonEnable;
}

@end
