//
//  KNetworkDetection.h
//  KXiniuCloud
//
//  Created by RPK on 2018/7/3.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNetworkDetection : NSObject

/**
 单例

 @return 实例对象
 */
+ (instancetype)shareInstance;

/**
 检测网络是否可用

 @return YES：可用，NO:不可用
 */
- (BOOL)checkNetCanUse;

/**
 过滤html

 @param html HTML页面
 @return HTML字符串
 */
- (NSString *)filterHTML:(NSString *)html;
@end
