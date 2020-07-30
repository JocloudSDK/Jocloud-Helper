//
//  LiveFunctionCollectionViewCell.m
//  app
//
//  Created by 宁丽环 on 2020/7/8.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LiveFunctionCollectionViewCell.h"
#import "UIImage+JLYBundle.h"
#import "NSBundle+Language.h"


@interface LiveFunctionCollectionViewCell ()
@property (nonatomic, weak) IBOutlet UIButton *functionButton;

@end


@implementation LiveFunctionCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
  
}

- (void)setModel:(LiveFunctionModel *)model
{
    _model = model;
    if (model.imageName) {
        [self.functionButton setImage:[UIImage jly_imageWithName:model.imageName bundle:@"baseui" targetClass:NSClassFromString(@"ToolBarView")] forState:UIControlStateNormal];
    }
    UIImage *selectedImage = [UIImage jly_imageWithName:[NSString stringWithFormat:@"%@_s",model.imageName] bundle:@"baseui" targetClass:NSClassFromString(@"ToolBarView")];
    if (selectedImage) {
        [self.functionButton setImage:selectedImage forState:UIControlStateSelected];
    }
    [self.functionButton setTitle:model.normalTitle forState:UIControlStateNormal];

    [self.functionButton setTitle:model.selectedTitle forState:UIControlStateSelected];
    
    self.functionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.functionButton.selected = model.isSelected;
    if (_model.type == LiveFunctionTypeApi || _model.type == LiveFunctionTypeLog || _model.type  == LiveFunctionTypefeedback|| model.type == LiveFunctionTypeSpeaker|| model.type ==LiveFunctionTypeEarReturn|| model.type == LiveFunctionTypeEarVariety) {
        self.functionButton.backgroundColor = [UIColor clearColor];
    } else {
        self.functionButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    }
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    [self.functionButton setTitleColor:titleColor forState:UIControlStateNormal];
}

@end
