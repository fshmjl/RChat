//
//  KTextView.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/28.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KTextView.h"


#import "NSString+Size.h"
#import "KChatMessageHelper.h"
#import "UIScrollView+Addition.h"
#import "NSAttributedString+Addition.h"

@interface KTextView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end

@implementation KTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [self addGestureRecognizer:self.longPress];
    }
    
    return self;
}

- (void)longPressAction:(id)longPress {
    [self selectAll:self];
}

- (void)cut:(id)sender
{
    NSString *string = [self.attributedText plainTextForRange:self.selectedRange];
    if (string.length) {
        [UIPasteboard generalPasteboard].string = string;

        NSRange selectedRange = self.selectedRange;
        NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [attributeContent replaceCharactersInRange:self.selectedRange withString:@""];
        self.attributedText = attributeContent;
        self.selectedRange = NSMakeRange(selectedRange.location, 0);

        if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
    }
}

- (void)copy:(id)sender
{
    NSString *string = [self.attributedText plainTextForRange:self.selectedRange];
    if (string.length) {
        [UIPasteboard generalPasteboard].string = string;
    }
    self.selectedRange = NSMakeRange(self.text.length, 0);
}

- (void)paste:(id)sender
{
    NSString *string = UIPasteboard.generalPasteboard.string;
    if (string.length) {
        // 如果需要在输入框显示表情
        // NSAttributedString *attributedString = [KChatMessageHelper formatMessageString:string];
        NSMutableAttributedString *attributedPasteString = [[NSMutableAttributedString alloc] initWithString:string];
        NSRange selectedRange = self.selectedRange;

        NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [attributeContent replaceCharactersInRange:self.selectedRange withAttributedString:attributedPasteString];
        [attributeContent addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributeContent.length)];


        self.attributedText = attributeContent;
        self.selectedRange = NSMakeRange(selectedRange.location + attributedPasteString.length, 0);

        if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
    }
}

- (BOOL)canBecomeFirstResponder
{
//    return self.isInputBox;
    return YES;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.isInputBox) {
        return [super canPerformAction:action withSender:sender];
    }
    else {
        if (action == @selector(copy:) || action == @selector(select:) || action == @selector(selectAll:)) {
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if (!self.isInputBox) {
//        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
//            NSLog(@"UILongPressGestureRecognizer**********:%@",gestureRecognizer);
//        }
//        else {
//            NSLog(@"gestureRecognizer---------:%@",gestureRecognizer);
//        }
//    }
    
    return YES;
}



@end
