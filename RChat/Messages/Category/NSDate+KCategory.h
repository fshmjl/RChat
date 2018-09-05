//
//  NSDate+KCategory.h
//  KRhinoMail
//
//  Created by RPK on 2017/7/19.
//  Copyright © 2017年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (KCategory)

/**
 *比较from和self的时间差值
 */
+ (NSDateComponents *)deltaFrom:(NSDate *)from;

/**
 获取当前时间
 
 @param dateFormat 时间格式
 @return 时间字符串
 */
+ (NSString *)getCurrentStringTimesWithdateFormat:(NSString *)dateFormat;

/**
 获取当前时间
 */
+ (NSDate *)getCurrentDateTimes;

/**
 *是否为今年
 */
- (BOOL)isThisYear;

/**
 *是否为今天
 */
- (BOOL)isToday;

/**
 *是否为昨天
 */
- (BOOL)isYesterday;

/**
 是否在一周内
 */
- (BOOL)isWeek;

/**
 根据不同格式，格式化时间戳
 
 @param date 时间戳
 @return 格式化后的时间
 */
+ (NSString *)dateFormatter:(NSDate *)date;

// 获取当前时间戳
+ (NSString *)getCurrentTimestamp;

/**
 消息模块部分
 根据不同格式，格式化时间戳
 
 @param date 时间戳
 @return 格式化后的时间
 */
+ (NSString *)messageWithDate:(NSDate *)date;

/**
 时间加随机数
 */
+ (NSString *)timeAndRandom;

/**
 消息id
 
 @return 本地消息id
 */
+ (NSString *)localMessageId;

/**
 两个时间差
 
 @param preTime 上一条消息的时间
 @param lastTime 最后一条消息的时间
 @return 是否显示时间
 */
+ (BOOL)showTimeWithPreviousTime:(NSTimeInterval)preTime lastTime:(NSTimeInterval)lastTime;

/**
 聊天页面消息时间显示
 
 @param recvTime 服务器收到的时间
 @return 处理好的时间
 */
+ (NSString *)messageTimeWithRecvTime:(NSTimeInterval)recvTime;

/**
 会话页面消息时间显示
 
 @param recvTime 服务器收到的时间
 @return 处理好的时间
 */
+ (NSString *)conversationTimeWithRecvTime:(NSTimeInterval)recvTime;

@end
