//
//  NSDictionary+Json.h
//  KXiniuCloud
//
//  Created by RPK on 2018/6/12.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Json)

/**
 json转字典

 @param jsonString json字符串
 @return 转换后的字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

/**
 字典转json

 @return json字符串
 */
- (NSString *)dictionaryTurnJson;


@end
