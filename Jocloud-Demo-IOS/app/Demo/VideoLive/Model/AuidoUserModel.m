//
//  auidoUserModel.m
//  app
//
//  Created by 宁丽环 on 2020/7/14.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "AuidoUserModel.h"

@implementation AuidoUserModel

+ (instancetype)auidoUserModelWithUid:(NSString *)uid
{
    AuidoUserModel *model = [[AuidoUserModel alloc]init];
    model.uid = uid;
    return model;
}

@end
