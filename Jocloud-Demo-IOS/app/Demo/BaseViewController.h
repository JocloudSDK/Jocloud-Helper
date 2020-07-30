//
//  BaseViewController.h
//  app
//
//  Created by 宁丽环 on 2020/7/7.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "NSBundle+Language.h"
// 屏幕宽/高
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

- (void)backAction;

@end

NS_ASSUME_NONNULL_END
