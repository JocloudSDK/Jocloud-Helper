//
//  BaseMacro.h
//  app
//
//  Created by GasparChu on 2020/5/28.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#ifndef BaseMacro_h
#define BaseMacro_h

/// Top Bar Height
#define kStatusBarHeight        ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define kTopBarHeight           (kStatusBarHeight + 44.f)
#define kScreenWidth            [UIScreen mainScreen].bounds.size.width
#define kScreenHeight           [UIScreen mainScreen].bounds.size.height

#define kSafeBottomHeight       safeBottomHeight()

static inline CGFloat safeBottomHeight()
{
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }else {
        return 0;
    }
}



#endif /* BaseMacro_h */
