//
//  JYLFunctionAlertView.h
//  app
//
//  Created by 宁丽环 on 2020/7/17.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveFunctionModel.h"

@class JYLFunctionAlertView;

@protocol JYLFunctionAlertViewDelegate <NSObject>

//点击确定按钮
- (void)jlyFunctionAlertView:(JYLFunctionAlertView * _Nullable)functionAlertView didSelectItemRow:(NSInteger)row;
//点击镜像
- (void)didChangeMirrorMode:(JYLMirrorMode)mode;
@end

NS_ASSUME_NONNULL_BEGIN

@interface JYLFunctionAlertView : UIView

@property (nonatomic, assign) id <JYLFunctionAlertViewDelegate> delegate;
@property (nonatomic, assign) CGFloat  triangleOriginxConstant;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) LiveFunctionModel *model;

@end

NS_ASSUME_NONNULL_END
