//
//  NSTextAttachment+Emoji.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/25.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "NSTextAttachment+Emoji.h"

static const char *emojiNameKey = "emojiName";
static const char *emojiSizeKey = "emojiSize";

@implementation NSTextAttachment (Emoji)

- (NSString *)emojiName {
    return objc_getAssociatedObject(self, emojiNameKey);
}

- (void)setEmojiName:(NSString *)emojiName {
    objc_setAssociatedObject(self, emojiNameKey, emojiName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)emojiSize {
    return objc_getAssociatedObject(self, emojiSizeKey);
}

- (void)setEmojiSize:(id)emojiSize {
    objc_setAssociatedObject(self, emojiSizeKey, emojiSize, OBJC_ASSOCIATION_ASSIGN);
}

@end
