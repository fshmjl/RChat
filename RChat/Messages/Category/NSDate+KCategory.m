//
//  NSDate+KCategory.m
//  KRhinoMail
//
//  Created by RPK on 2017/7/19.
//  Copyright © 2017年 EIMS. All rights reserved.
//

#import "NSDate+KCategory.h"

@implementation NSDate (KCategory)

+ (NSDateComponents*)deltaFrom:(NSDate *)from
{
    // 初始化日历
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    // 设置日历单元
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    // 返回比较你的数据时间与现在时间的差值
    return [calendar components:unit fromDate:from toDate:[NSDate date] options:0];
}

/**
 获取当前时间

 @param dateFormat 时间格式
 @return 时间字符串
 */
+ (NSString *)getCurrentStringTimesWithdateFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:dateFormat];
    // 现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    // 将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
}

/**
 获取当前时间
 */
+ (NSDate *)getCurrentDateTimes
{
    // 获得时间对象
    NSDate *date = [NSDate date];
    // 获得系统的时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    // 以秒为单位返回当前时间与系统格林尼治时间的差
    NSTimeInterval time = [zone secondsFromGMTForDate:date];
    // 然后把差的时间加上,就是当前系统准确的时间
    NSDate *dateNow = [date dateByAddingTimeInterval:time];
    
    return dateNow;
}

/*
 *例如  2017 - 10 - 01
 *     年份值  月份  日
 */
//判断是否是今年
- (BOOL)isThisYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //现在日期的年份值
    NSInteger nowYear = [calendar component:NSCalendarUnitYear fromDate:[NSDate date]];
    //传入对象的年份值
    NSInteger selfYear = [calendar component:NSCalendarUnitYear fromDate:self];
    
    return nowYear == selfYear;
    
}

// 判断是否是今天
- (BOOL)isToday
{
    NSDateFormatter * fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"yyyy-MM-dd";
    //今天的日期
    NSString * nowString = [fmt stringFromDate:[NSDate date]];
    //传入对象的日期
    NSString * selfString = [fmt stringFromDate:self];
    
    return [nowString isEqualToString:selfString];
    
}

// 判断是否是昨天
- (BOOL)isYesterday
{
    NSDateFormatter * fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"yyyy-MM-dd";
    //今天的日期
    NSDate *nowDate = [fmt dateFromString:[fmt stringFromDate:[NSDate date]]];
    //传入对象的日期
    NSDate *selfDate = [fmt dateFromString:[fmt stringFromDate:self]];
    //二者差值
    NSCalendar * calender = [NSCalendar currentCalendar];
    NSDateComponents * cmps = [calender components:NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear fromDate:selfDate toDate:nowDate options:0];
    
    return cmps.year == 0 && cmps.month == 0 && cmps.day == 1;
    
}

/**
 是否在一周之内
 */
- (BOOL)isWeek
{
    NSDateFormatter * fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    //今天的日期
    NSDate *nowDate = [fmt dateFromString:[fmt stringFromDate:[NSDate date]]];
    //传入对象的日期
    NSDate *selfDate = [fmt dateFromString:[fmt stringFromDate:self]];
    //二者差值
    NSCalendar * calender = [NSCalendar currentCalendar];
    NSDateComponents * cmps = [calender components:NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear fromDate:selfDate toDate:nowDate options:0];
    
    return cmps.year == 0 && cmps.month == 0 && cmps.day == 7;
}

/**
 根据不同格式，格式化时间戳

 @param date 时间戳
 @return 格式化后的时间
 */
+ (NSString *)dateFormatter:(NSDate *)date
{
    // 日期格式化
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];

    if (date.isThisYear)
    {
        if (date.isToday)
        {
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDateComponents *components = [cal components:NSCalendarUnitHour fromDate:date];
            NSInteger currHour = [components hour];
            
            if (currHour < 6) {
                fmt.dateFormat = @"凌晨 HH:mm";
            }else if (currHour >= 6 && currHour < 12) {
                fmt.dateFormat = @"上午 HH:mm";
            }else if (currHour >= 12 && currHour < 18) {
                fmt.dateFormat = @"下午 HH:mm";
            }else {
                fmt.dateFormat = @"晚上 HH:mm";
            }
            
            return [fmt stringFromDate:date];
            
        }else {
            // 其他
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:date];
        }
    }else {
        // 非今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:date];
    }
}

// 获取当前时间戳
+ (NSString *)getCurrentTimestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];     // 获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970] * 1000;    // 精确到毫秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    
    return timeString;
}

/**
 消息模块部分
 根据不同格式，格式化时间戳
 
 @param date 时间戳
 @return 格式化后的时间
 */
+ (NSString *)messageWithDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    // 日期格式化
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];

    if (date.isThisYear)
    {
        if (date.isToday)
        {
            fmt.dateFormat = @"HH:mm";
            return [fmt stringFromDate:date];
        }
        else
        {
            // 其他
            fmt.dateFormat = @"MM-dd";
            return [fmt stringFromDate:date];
        }
    }
    else
    {
        // 非今年
        fmt.dateFormat = @"yyyy-MM-dd";
        return [fmt stringFromDate:date];
    }
}

/**
 聊天页面消息时间显示

 @param recvTime 服务器收到的时间
 @return 处理好的时间
 */
+ (NSString *)messageTimeWithRecvTime:(NSTimeInterval)recvTime
{
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    //hasAMPM==TURE为12小时制，否则为24小时制
    BOOL hasAMPM = containsA.location != NSNotFound;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *recvTimeStr = [NSString stringWithFormat:@"%.0f",recvTime];
    recvTimeStr = [recvTimeStr substringToIndex:recvTimeStr.length - 3];
    
    NSDate *recvDate = [NSDate dateWithTimeIntervalSince1970:[recvTimeStr integerValue]];
    if (recvDate.isToday)
    {
        if (hasAMPM)
        {
            [dateFormatter setDateFormat:@"aa hh:mm"];
        }
        else
        {
            [dateFormatter setDateFormat:@"HH:mm"];
        }
    }
    else if (recvDate.isYesterday)
    {
        if (hasAMPM)
        {
            [dateFormatter setDateFormat:@"aa hh:mm"];
        }
        else
        {
            [dateFormatter setDateFormat:@"HH:mm"];
        }
        
        return [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:recvDate]];
    }
    else if (recvDate.isWeek)
    {
        if (hasAMPM)
        {
            [dateFormatter setDateFormat:@"EEE aa hh:mm"];
        }
        else
        {
            [dateFormatter setDateFormat:@"EEE HH:mm"];
        }
    }
    else if (recvDate.isThisYear)
    {
        if (hasAMPM)
        {
            [dateFormatter setDateFormat:@"MM月dd日 aa hh:mm"];
        }
        else
        {
            [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
        }
    }
    else
    {
        if (hasAMPM)
        {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日 aa hh:mm"];
        }
        else
        {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        }
    }
    
    NSString *receiveTime = [dateFormatter stringFromDate:recvDate];
    
    return receiveTime;
}

/**
 会话页面消息时间显示
 
 @param recvTime 服务器收到的时间
 @return 处理好的时间
 */
+ (NSString *)conversationTimeWithRecvTime:(NSTimeInterval)recvTime
{
    if (recvTime == 0) {
        return @"";
    }
    
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    //hasAMPM==TURE为12小时制，否则为24小时制
    BOOL hasAMPM = containsA.location != NSNotFound;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *recvTimeStr = [NSString stringWithFormat:@"%.0f",recvTime];
    recvTimeStr = [recvTimeStr substringToIndex:recvTimeStr.length - 3];
    
    NSDate *recvDate = [NSDate dateWithTimeIntervalSince1970:[recvTimeStr integerValue]];
    if (recvDate.isToday)
    {
        if (hasAMPM)
        {
            [dateFormatter setDateFormat:@"aa hh:mm"];
        }
        else
        {
            [dateFormatter setDateFormat:@"HH:mm"];
        }
    }
    else if (recvDate.isYesterday)
    {
        return @"昨天";
    }
    else if (recvDate.isWeek)
    {
        if (hasAMPM)
        {
            [dateFormatter setDateFormat:@"EEE"];
        }
        else
        {
            [dateFormatter setDateFormat:@"EEE"];
        }
    }
    else if (recvDate.isThisYear)
    {
        if (hasAMPM)
        {
            [dateFormatter setDateFormat:@"MM月dd日"];
        }
        else
        {
            [dateFormatter setDateFormat:@"MM月dd日"];
        }
    }
    else
    {
        if (hasAMPM)
        {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        }
        else
        {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        }
    }
    
    NSString *receiveTime = [dateFormatter stringFromDate:recvDate];
    
    return receiveTime;
}

/**
 时间加随机数
 */
+ (NSString *)timeAndRandom
{
    NSInteger timeInterval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger random = arc4random() % 10000;
    NSString *result = [NSString stringWithFormat:@"%ld%04ld", timeInterval, (long)random];
    NSLog(@"会话id：%@", result);
    
    return result;
}


/**
 消息id

 @return 本地消息id
 */
+ (NSString *)localMessageId {
    return [self getCurrentTimestamp];
}

/**
 两个时间差

 @param preTime 上一条消息的时间
 @param lastTime 最后一条消息的时间
 @return 是否显示时间
 */
+ (BOOL)showTimeWithPreviousTime:(NSTimeInterval)preTime lastTime:(NSTimeInterval)lastTime
{
//    NSLog(@"preTime:%f, lastTime:%f", preTime, lastTime);
    NSTimeInterval value = lastTime/1000 - preTime/1000;
    BOOL showTime = value > 60 || value < -60;
    
    return showTime;
}

@end
