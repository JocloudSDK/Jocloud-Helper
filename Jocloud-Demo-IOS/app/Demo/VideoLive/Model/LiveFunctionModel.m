//
//  LiveFunctionModel.m
//  app
//
//  Created by 宁丽环 on 2020/7/13.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "LiveFunctionModel.h"

@implementation LiveFunctionModel

+ (instancetype)liveFunctionModelWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle image:(NSString *)imageName functionType:(LiveFunctionType)type; {
    LiveFunctionModel *functionModel = [[LiveFunctionModel alloc]init];
    functionModel.normalTitle = title;
    functionModel.selectedTitle = selectedTitle;
    functionModel.type = type;
    functionModel.imageName = imageName;
    return functionModel;
}

+ (instancetype)liveFunctionModelWithTitle:(NSString *)title functionType:(LiveFunctionAlertType)type
{
    LiveFunctionModel *functionModel = [[LiveFunctionModel alloc]init];
    functionModel.normalTitle = title;
    functionModel.functionType = type;
    if (type == LiveFunctionAlertTypeRenderCut || type == LiveFunctionAlertTypeStallHD) {
        functionModel.isSelected = YES;
    }
    return functionModel;
}

@end
