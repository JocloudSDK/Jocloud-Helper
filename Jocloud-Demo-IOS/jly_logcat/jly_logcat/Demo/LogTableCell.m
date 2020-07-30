//
//  LogTableCell.m
//  jly_logcat
//
//  Created by GasparChu on 2020/5/27.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LogTableCell.h"

@implementation LogTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.contentLabel];
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.contentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:2];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2];
    [self.contentView addConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
}

#pragma mark - Getter & Setter
- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:12.f];
        label.numberOfLines = 0;
        _contentLabel = label;
    }
    return _contentLabel;
}

@end
