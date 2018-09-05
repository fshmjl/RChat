//
//  NSDictionary+Json.m
//  KXiniuCloud
//
//  Created by RPK on 2018/6/12.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "NSDictionary+Json.h"

@implementation NSDictionary (Json)

/**
 json转字典

 @param jsonString json字符串
 @return 字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {

    if (jsonString == nil || [jsonString isEqualToString:@""]) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];

    if(err) {
        NSLog(@"json解析失败：%@", err);
        return nil;
    }

    return dic;
}

/**
 字典转json

 @return json
 */
- (NSString *)dictionaryTurnJson
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
