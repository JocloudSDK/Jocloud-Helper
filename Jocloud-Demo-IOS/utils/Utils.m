//
//  Utils.m
//  Utils
//
//  Created by iPhuan on 2019/8/6.
//  Copyright © 2019 SY. All rights reserved.
//


#import "Utils.h"
#import <mach/mach.h>
#import <assert.h>

@implementation Utils

+ (NSString *)appVersion
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    return infoDic[@"CFBundleShortVersionString"];
}


+ (NSString *)appBuildVersion
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    return infoDic[@"CFBundleVersion"];
}

+ (NSDictionary *)dicFromJsonString:(NSString *)json
{
    NSError *error = nil;
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    return dic;
}

+ (NSString *)generateRandomNumberWithDigitCount:(NSInteger)count
{
    NSUInteger num = pow(10, count) - 1 - pow(10, count - 1) + 1;
    NSUInteger uidNumber = (NSUInteger)(pow(10, count - 1) + (arc4random() % num));
    return [NSString stringWithFormat:@"%lu", (unsigned long)uidNumber];
}

+ (float)cpuUsage
{
    kern_return_t           kr;
    thread_array_t          thread_list;
    mach_msg_type_number_t  thread_count;
    thread_info_data_t      thinfo;
    mach_msg_type_number_t  thread_info_count;
    thread_basic_info_t     basic_info_th;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
  float  cpu_usage = 0;
    
    for (int i = 0; i < thread_count; i++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[i], THREAD_BASIC_INFO,(thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;

        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            cpu_usage += basic_info_th->cpu_usage;
        }
    }
    
    cpu_usage = cpu_usage / (float)TH_USAGE_SCALE * 100.0;
    
    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    
    return cpu_usage;
}

+ (NSString *)memoryUsage
{
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
    }
    NSString *string = [NSByteCountFormatter stringFromByteCount:memoryUsageInByte countStyle:NSByteCountFormatterCountStyleMemory];
    return string;
}



@end


