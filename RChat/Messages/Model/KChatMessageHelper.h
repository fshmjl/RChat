//
//  KChatMessageHelper.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/4.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KChatMessageHelper : NSObject

/**
 输入框显示是不是表情，而是表情字符串

 @param text 字符串
 @return 富文本
 */
+ (NSAttributedString *)formatMessageString:(NSString *)text;

/**
 在消息页面显示的富文本
 
 @param att 输入框得到的富文本
 @return 处理好的可以显示在页面上的富文本
 */
+ (NSAttributedString *)formatMessageAtt:(NSAttributedString *)att;

@end
