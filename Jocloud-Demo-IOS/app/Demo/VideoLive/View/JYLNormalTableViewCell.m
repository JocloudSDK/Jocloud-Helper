//
//  JYLNormalTableViewCell.m
//  app
//
//  Created by 宁丽环 on 2020/7/17.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "JYLNormalTableViewCell.h"
#import "UIColor+SLExtention.h"


@interface JYLNormalTableViewCell()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@end

@implementation JYLNormalTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)setModel:(LiveFunctionModel *)model
{
    _model = model;
    self.titleLabel.text = _model.normalTitle;
    if (_model.isSelected) {
        self.titleLabel.textColor = [UIColor sl_colorWithHexString:@"#4877FF"];
    } else {
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}
@end
