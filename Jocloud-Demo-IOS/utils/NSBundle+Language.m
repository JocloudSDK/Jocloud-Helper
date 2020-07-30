//
//  NSBundle+Language.m
//  SCClassRoom
//
//  Created by GasparChu on 2020/3/5.
//  Copyright © 2020 SY. All rights reserved.
//

#import "NSBundle+Language.h"
#import <objc/runtime.h>

static NSString *const LanguageKey = @"LanguageKey";
static NSString *const LanguageCodeForEn = @"en";
static NSString *const LanguageCodeForCn = @"zh-Hans";


@implementation NSBundle (Language)

+ (BOOL)jly_currentLanguageIsEn
{
    NSString *sysLanguageCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    NSString *localLanguageCode = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageKey];
    NSString *currentLanguageCode = localLanguageCode.length ? localLanguageCode : sysLanguageCode;
    if ([currentLanguageCode containsString:LanguageCodeForEn]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)jly_localizedStringWithKey:(NSString *)key
{
    NSString *sysLanguageCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    NSString *localLanguageCode = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageKey];
    NSString *currentLanguageCode = localLanguageCode.length ? localLanguageCode : sysLanguageCode;
    
    NSBundle *currentBundle = nil;
    if ([currentLanguageCode containsString:LanguageCodeForEn]) {
        currentLanguageCode = LanguageCodeForEn;
        currentBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:currentLanguageCode ofType:@"lproj"]];
    } else {
        currentLanguageCode = LanguageCodeForCn;
        currentBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:currentLanguageCode ofType:@"lproj"]];
    }
    return currentBundle ? [currentBundle localizedStringForKey:key value:nil table:@"InfoPlist"] : key;
}

+ (void)jly_switchLanguageToHans
{
    [self switchLanguageCode:LanguageCodeForCn];
}

+ (void)jly_switchLanguageToEn
{
    [self switchLanguageCode:LanguageCodeForEn];
}

+ (void)switchLanguageCode:(NSString *)code
{
    [[NSUserDefaults standardUserDefaults] setObject:code forKey:LanguageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
