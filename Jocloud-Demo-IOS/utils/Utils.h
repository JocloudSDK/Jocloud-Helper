//
//  Utils.h
//  Utils
//
//  Created by iPhuan on 2019/8/6.
//  Copyright © 2019 SY. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Utils : NSObject

/// app version
+ (NSString *)appVersion;

/// app build version
+ (NSString *)appBuildVersion;

/// json 转 dic
/// json to dic
+ (NSDictionary *)dicFromJsonString:(NSString *)json;

/// 生成随机数
/// Get random number
+ (NSString *)generateRandomNumberWithDigitCount:(NSInteger)count;

@end
