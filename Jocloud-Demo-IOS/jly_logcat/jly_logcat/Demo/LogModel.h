//
//  LogModel.h
//  jly_logcat
//
//  Created by GasparChu on 2020/5/28.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogModel : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *textColor;

@end

NS_ASSUME_NONNULL_END
