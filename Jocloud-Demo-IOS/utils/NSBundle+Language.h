//
//  NSBundle+Language.h
//  SCClassRoom
//
//  Created by GasparChu on 2020/3/5.
//  Copyright © 2020 SY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (Language)

/// 当前语言是否是英文
/// Whether the current language is English
+ (BOOL)jly_currentLanguageIsEn;

/// 获取本地字符
/// Get local characters
+ (NSString *)jly_localizedStringWithKey:(NSString *)key;

/// 切换至中文
/// Switch to Chinese
+ (void)jly_switchLanguageToHans;

/// 切换至英文
/// Switch to English
+ (void)jly_switchLanguageToEn;

@end

NS_ASSUME_NONNULL_END
