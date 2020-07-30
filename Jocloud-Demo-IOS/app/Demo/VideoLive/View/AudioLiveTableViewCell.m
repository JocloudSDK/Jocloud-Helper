//
//  AudioLiveTableViewCell.m
//  app
//
//  Created by 宁丽环 on 2020/7/10.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "AudioLiveTableViewCell.h"

@implementation AudioLiveTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)setModel:(AuidoUserModel *)model
{
    _model = model;
    self.leftTextLabel.text = _model.uid;
    self.mircImageView.image = model.isSelected ?[UIImage imageNamed:@"audio_volume_close"]:[UIImage imageNamed:@"audio_volume_3"];
}

@end
