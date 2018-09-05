//
//  NSString+Category.m
//  RChat
//
//  Created by eims on 2018/9/4.
//  Copyright © 2018年 RPK. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

// 判断字符串是否是全空格
- (BOOL)isEmptyString
{
    if (!self || !self.length)
    {
        return true;
    }
    else
    {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *isString = [self stringByTrimmingCharactersInSet:set];
        
        if ([isString length] == 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}

@end
