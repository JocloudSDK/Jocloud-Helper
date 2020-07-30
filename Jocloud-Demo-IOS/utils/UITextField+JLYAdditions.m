//
//  UITextField+JLYAdditions.m
//  SCClassRoom
//
//  Created by GasparChu on 2020/3/10.
//  Copyright © 2020 SY. All rights reserved.
//

#import "UITextField+JLYAdditions.h"
#import <objc/runtime.h>

@implementation UITextField (JLYAdditions)


- (void)setMaxInputLenth:(NSInteger)maxLen
{
    NSString *toBeString = self.text;
    UITextRange *selectedRange = [self markedTextRange];
    UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
    
    if (!position || !selectedRange) {
        if (toBeString.length > maxLen) {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:maxLen];
            if (rangeIndex.length == 1) {
                self.text = [toBeString substringToIndex:maxLen];
            }
            else {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLen)];
                self.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}

#pragma mark - Event
- (BOOL)jly_isInputNum:(NSString *)string
{
    if (0 == string.length) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:string]) {
        return YES;
    }
    return NO;
}

- (void)textEditingChanged:(UITextField *)textField
{
    if (self.jly_maxLength) {
        [textField setMaxInputLenth:self.jly_maxLength];
    }
}

#pragma mark - Getter & Setter
- (void)setJly_maxLength:(NSUInteger)jly_maxLength
{
    objc_setAssociatedObject(self, @selector(jly_maxLength), @(jly_maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:self action:@selector(textEditingChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (NSUInteger)jly_maxLength
{
    NSNumber *maxLength = objc_getAssociatedObject(self, @selector(jly_maxLength));
    return maxLength.unsignedIntValue;
}

@end
