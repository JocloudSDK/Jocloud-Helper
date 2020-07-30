//
//  MoudlesDataManager.m
//  AFNetworking
//
//  Created by Huan on 2020/6/19.
//

#import "ModulesDataManager.h"

@implementation ModulesDataManager

+ (instancetype)sharedManager
{
    static ModulesDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
