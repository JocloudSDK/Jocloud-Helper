//
//  NSDate+JYLExtention.m
//  AFNetworking
//
//  Created by 宁丽环 on 2020/7/16.
//

#import "NSDate+JYLExtention.h"

@implementation NSDate (JYLExtention)
//获取当前时间
+ (NSString *)jyl_currentDateStr
{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"H:mm:ss"];//设定时间格式,这里可以设置成自己需要的格式
    NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
    return dateString;
}

+ (NSString *)jyl_getCurrentTimeString
{
    NSDateFormatter *formatter = [NSDateFormatter new];
          [formatter setDateFormat:@"MM-dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    NSString *str = [formatter stringFromDate:date];
    return str;
}

@end
