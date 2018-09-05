//
//  NSArray+Json.h
//  KXiniuCloud
//
//  Created by RPK on 2018/6/19.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Json)

/**
 json转数组

 @param jsonStr json字符串
 @return 数组
 */
+ (instancetype)arrayWithJsonStr:(NSString *)jsonStr;

/**
 数组转json
 
 @return json字符串
 */
- (NSString *)toJSONString;
@end
