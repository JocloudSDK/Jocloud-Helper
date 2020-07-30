//
//  WhineCollectionViewCell.m
//  app
//
//  Created by 宁丽环 on 2020/7/15.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "WhineCollectionViewCell.h"
#import "UIColor+SLExtention.h"

@implementation WhineCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.layer.borderColor = [UIColor sl_colorWithHexString:@"#F3F4F8"].CGColor;
    self.titleLabel.layer.borderWidth = 1.0f;
    self.titleLabel.layer.cornerRadius = 4.0f;
    self.titleLabel.layer.masksToBounds = YES;
}

- (void)setModel:(LiveFunctionModel *)model
{
    _model = model;
    self.titleLabel.text = model.normalTitle;
    if (_enabled) {
        if (model.isSelected) {
            self.titleLabel.textColor = [UIColor sl_colorWithHexString:@"#0041FF"];
            self.titleLabel.layer.borderColor = [UIColor sl_colorWithHexString:@"#0041FF"].CGColor;
        } else {
            self.titleLabel.textColor = [UIColor sl_colorWithHexString:@"#7A7A7A"];
            self.titleLabel.layer.borderColor = [UIColor sl_colorWithHexString:@"#F3F4F8"].CGColor;
        }
    } else {
        self.titleLabel.textColor = [UIColor sl_colorWithHexString:@"#7A7A7A"];
        self.titleLabel.layer.borderColor = [UIColor sl_colorWithHexString:@"#F3F4F8"].CGColor;
    }
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
      self.userInteractionEnabled = _enabled;
    if (enabled) {
        self.titleLabel.backgroundColor = [UIColor sl_colorWithHexString:@"F3F4F8"];
          } else {
        self.titleLabel.backgroundColor = [UIColor sl_colorWithHexString:@"FCFCFD"];
    }
}
@end
