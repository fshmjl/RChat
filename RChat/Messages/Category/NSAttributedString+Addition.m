//
//  NSAttributedString+Addition.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/29.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "NSAttributedString+Addition.h"
#import "NSTextAttachment+Emoji.h"

@implementation NSAttributedString (Addition)

- (NSRange)rangeOfAll
{
    return NSMakeRange(0, self.length);
}

- (NSString *)plainTextForRange:(NSRange)range
{
    if (range.location == NSNotFound || range.length == NSNotFound) {
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc] init];
    if (range.length == 0) {
        return result;
    }
    
    NSString *string = self.string;
    [self enumerateAttribute:NSAttachmentAttributeName inRange:range options:kNilOptions usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSTextAttachment *backed = (NSTextAttachment *)value;
        if (backed && backed.emojiName) {
            [result appendString:backed.emojiName];
        } else {
            [result appendString:[string substringWithRange:range]];
        }
    }];
    return result;
}

@end

@implementation NSMutableAttributedString (Addition)

- (void)setTextBackedString:(KTextBackedString *)textBackedString range:(NSRange)range
{
    if (textBackedString && ![NSNull isEqual:textBackedString]) {
        [self addAttribute:NSAttachmentAttributeName value:textBackedString range:range];
    } else {
        [self removeAttribute:NSAttachmentAttributeName range:range];
    }
}

@end
