//
//  JYLButtonTableViewCell.m
//  app
//
//  Created by 宁丽环 on 2020/7/17.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "JYLButtonTableViewCell.h"
#import "NSBundle+Language.h"


@interface JYLButtonTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;

@end

@implementation JYLButtonTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.leftButton.selected = YES;
     
}

- (void)setModel:(LiveFunctionModel *)model
{
    _model = model;
    _model.isSelectedLeft = YES;
    self.titleLabel.text = _model.normalTitle;
    [self.leftButton setTitle:[NSBundle jly_localizedStringWithKey:@" 镜像 "] forState:UIControlStateNormal];
    [self.rightButton setTitle:[NSBundle jly_localizedStringWithKey:@"不镜像"] forState:UIControlStateNormal];
}

- (IBAction)leftButtonClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.rightButton.selected = NO;
        _model.isSelectedLeft = YES;
        _model.isSelectedRight = NO;
    } else {
        self.rightButton.selected = YES;
        _model.isSelectedLeft = NO;
        _model.isSelectedRight = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeMirrorMode:)]) {
        [self.delegate didChangeMirrorMode:_model];
    }
}

- (IBAction)rightButtonClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.leftButton.selected = NO;
        _model.isSelectedLeft = NO;
        _model.isSelectedRight = YES;
    } else {
        self.leftButton.selected = YES;
        _model.isSelectedLeft = YES;
        _model.isSelectedRight = NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeMirrorMode:)]) {
           [self.delegate didChangeMirrorMode:_model];
       }
}

@end
