//
//  UITextField+Expand.m
//  app
//
//  Created by 宁丽环 on 2020/7/28.
//  Copyright © 2020 GasparChu. All rights reserved.
//

#import "UITextField+Expand.h"
#import <objc/runtime.h>

@implementation UITextField (Expand)

static char limit;

- (void)setLimitBlock:(LimitBlock)limitBlock
{
    objc_setAssociatedObject(self, &limit, limitBlock, OBJC_ASSOCIATION_COPY);
}

- (LimitBlock)jyl_limitBlock
{
    return objc_getAssociatedObject(self, &limit);
}

- (void)jyl_lengthLimit:(void (^)(void))limit
{
    [self addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    self.limitBlock = limit;
}

- (void)textFieldEditChanged:(UITextField *)textField
{
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        if (self.jyl_limitBlock) {
            self.jyl_limitBlock();
        }
    }
}

@end
