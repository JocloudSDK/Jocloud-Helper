//
//  JYLFunctionAlertView.m
//  app
//
//  Created by 宁丽环 on 2020/7/17.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "JYLFunctionAlertView.h"
#import "JYLNormalTableViewCell.h"
#import "JYLButtonTableViewCell.h"

@interface JYLFunctionAlertView ()<UITableViewDelegate,UITableViewDataSource,JYLButtonTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *triangleLeftConstraint;
@property (nonatomic, weak) IBOutlet UITableView *contentTabelView;
@property (nonatomic, assign) JYLMirrorMode mode;

@end

@implementation JYLFunctionAlertView

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (instancetype)init
{
    if (self == [super init]) {
        self = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([JYLFunctionAlertView class]) owner:nil options:nil].lastObject;
        self.contentTabelView.delegate = self;
        self.contentTabelView.dataSource = self;
        self.contentTabelView.rowHeight = 36.0f;
        [self.contentTabelView registerNib:[UINib nibWithNibName:NSStringFromClass([JYLNormalTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([JYLNormalTableViewCell class])];
        [self.contentTabelView registerNib:[UINib nibWithNibName:NSStringFromClass([JYLButtonTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([JYLButtonTableViewCell class])];
    }
    return self;
}

- (void)setTriangleOriginxConstant:(CGFloat)triangleOriginxConstant
{
    _triangleOriginxConstant = triangleOriginxConstant;
    self.triangleLeftConstraint.constant = _triangleOriginxConstant;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiveFunctionModel *model = self.dataArray[indexPath.row];
    if (model.functionType == LiveFunctionAlertTypeMirrorPreview || model.functionType == LiveFunctionAlertTypeMirrorPushflow) {
        JYLButtonTableViewCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JYLButtonTableViewCell class]) forIndexPath:indexPath];
        buttonCell.model = model;
        buttonCell.delegate = self;
        return buttonCell;
    } else {
        JYLNormalTableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JYLNormalTableViewCell class]) forIndexPath:indexPath];
        normalCell.model = model;
        return normalCell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return  self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.selected = NO;
    for (LiveFunctionModel *model in self.dataArray) {
        model.isSelected = NO;
    }
    LiveFunctionModel *model = self.dataArray[indexPath.row];
    model.isSelected = !model.isSelected;
    [self.contentTabelView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(jlyFunctionAlertView:didSelectItemRow:)]) {
        [self.delegate jlyFunctionAlertView:self didSelectItemRow:indexPath.row];
    }
}

#pragma mark - JYLButtonTableViewCellDelegate
- (void)didChangeMirrorMode:(LiveFunctionModel *)model
{
    LiveFunctionModel *mirrorModel = nil;
    //预览
    if (model.functionType == LiveFunctionAlertTypeMirrorPreview) {
        mirrorModel = self.dataArray.lastObject;
        if (model.isSelectedLeft && mirrorModel.isSelectedRight) {
            
            self.mode = JYLMirrorMode_PREVIEW_MIRROR_PUBLISH_NO_MIRROR;
            
        } else if (model.isSelectedRight && mirrorModel.isSelectedLeft) {
            self.mode = JYLMirrorMode_PREVIEW_NO_MIRROR_PUBLISH_MIRROR;//预览不镜像，开播镜像
            
        }
        
    } else if (model.functionType == LiveFunctionAlertTypeMirrorPushflow) {
    //推流
        mirrorModel = self.dataArray.firstObject;
        if (model.isSelectedLeft && mirrorModel.isSelectedRight) {
            
            self.mode = JYLMirrorMode_PREVIEW_NO_MIRROR_PUBLISH_MIRROR;//预览不镜像，开播镜像
            
        } else if (model.isSelectedRight && mirrorModel.isSelectedLeft) {
            self.mode = JYLMirrorMode_PREVIEW_MIRROR_PUBLISH_NO_MIRROR;//预览镜像，推流不镜像
            
        }
    }
    
    if (model.isSelectedLeft && mirrorModel.isSelectedLeft) {
        
        self.mode = JYLMirrorMode_PREVIEW_PUBLISH_BOTH_MIRROR; //都镜像
        
    } else if (model.isSelectedRight && mirrorModel.isSelectedRight) {
        self.mode = JYLMirrorMode_PUBLISH_BOTH_NO_MIRROR; //都不镜像
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeMirrorMode:)]) {
        [self.delegate didChangeMirrorMode:self.mode];
    }
}
@end
