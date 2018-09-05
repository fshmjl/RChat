//
//  NSArray+Json.m
//  KXiniuCloud
//
//  Created by RPK on 2018/6/19.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "NSArray+Json.h"

@implementation NSArray (Json)

/**
 json转数组
 
 @param jsonStr json字符串
 @return 数组
 */
+ (instancetype)arrayWithJsonStr:(NSString *)jsonStr {
    if (!jsonStr) {
        return nil;
    }
    return  [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:nil];
}

/**
 数组转json

 @return json字符串
 */
- (NSString *)toJSONString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                                     error:nil];
    
    if (data == nil) {
        return nil;
    }
    
    NSString *string = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    return string;
}

@end
