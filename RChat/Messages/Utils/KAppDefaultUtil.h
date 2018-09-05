//
//  KAppDefaultUtil.h
//  KXiniuCloud
//
//  Created by RPK on 2017/8/21.
//  Copyright © 2017年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KMailAccountInfoModel.h"

@interface KAppDefaultUtil : NSObject

+ (instancetype)sharedInstance;

/**
 设置邮箱信息

 @param model 邮箱信息
 */
- (void)setMailInfo:(KMailAccountInfoModel *)model;

// 获取邮箱信息

/**
 获取邮箱信息

 @return 邮箱信息
 */
- (KMailAccountInfoModel *)getMailInfo;

/**
 设置邮箱名称

 @param value 邮箱名称
 */
- (void)setMailName:(NSString *)value;

/**
 获取邮箱名称

 @return 邮箱名称
 */
- (NSString *)getMailName;

/**
 设置邮箱账号

 @param value 邮箱账号
 */
- (void)setMailAccount:(NSString *)value;

/**
 获取邮箱账号

 @return 邮箱账号
 */
- (NSString *)getMailAccount;

///**
// 设置邮箱密码
//
// @param value 邮箱密码
// */
//- (void)setMailPassword:(NSString *)value;
//
///**
// 获取邮箱密码
//
// @return 邮箱密码
// */
//- (NSString *)getMailPassword;

/**
 储存接收服务器

 @param value 接收服务器
 */
- (void)setMailRecevieServer:(NSString *)value;

/**
 获取接收服务器

 @return 接收服务器
 */
- (NSString *)getMailRecevieServer;

/**
 储存接收协议

 @param value 接收协议
 */
- (void)setMailRecevieProtocol:(NSString *)value;

/**
 获取接收协议

 @return 接收协议
 */
- (NSString *)getMailRecevieProtocol;

/**
 储存接收端口号

 @param value 接收端口号
 */
- (void)setMailReceviePort:(int)value;

/**
 获取接收端口号

 @return 接收端口号
 */
- (int)getMailReceviePort;

/**
 储存接收SSL

 @param value 接收SSL
 */
- (void)setMailIsReceiveSSL:(int)value;

/**
 获取接收SSL

 @return 接收SSL
 */
- (int)getMailIsReceiveSSL;

/**
 储存发送邮件服务器

 @param value 发送服务器
 */
- (void)setMailSendServer:(NSString *)value;

/**
 获取接收邮件服务器

 @return 接收邮件服务器
 */
- (NSString *)getMailSendServer;

/**
 存储发送协议

 @param value 发送协议
 */
- (void)setMailSendProtocol:(NSString *)value;

/**
 获取发送协议

 @return 发送协议
 */
- (NSString *)getMailSendProtocol;

/**
 存储发送端口号

 @param value 发送端口号
 */
- (void)setMailSendPort:(int)value;

/**
 获取发送端口号

 @return 发送端口号
 */
- (int)getMailSendPort;

/**
 存储邮箱发送SSL
 */
- (void)setMailIsSendSSL:(int)value;

/**
 获取邮箱发送SSL

 @return SSL（0:不开启  1:开启）
 */
- (int)getMailIsSendSSL;

/**
 设置邮箱签名

 @param value 邮箱签名
 */
- (void)setMailSignature:(NSString *)value;

/**
 获取邮箱签名

 @return 邮箱签名
 */
- (NSString *)getMailSignature;

/**
 邮箱当前选中文件夹

 @param value 文件夹名
 */
- (void)setMailFolder:(NSString *)value;

/**
 获取邮箱当前选中文件夹

 @return 文件夹名
 */
- (NSString *)getMailFolder;

/**
 缓存邮件历史搜索记录
 */
- (void)setCacheMailHistorySearchData:(NSArray *)value;

/**
 获取邮件历史搜索记录
 */
- (NSArray *)getCacheMailHistorySearchData;

/**
 缓存联系人历史搜索记录
 */
- (void)setCacheContactsHistorySearchData:(NSArray *)value;

/**
 获取联系人历史搜索记录
 */
- (NSArray *)getCacheContactsHistorySearchData;

/**
 缓存犀牛ID
 */
- (void)setXiniuID:(NSString *)value;

/**
 获取犀牛ID
 */
- (NSString *)getXiniuID;

// 缓存用户名
- (void)setUserName:(NSString *)value;

// 获取用户名
- (NSString *)getUserName;

/**
 缓存手机号
 */
- (void)setMobile:(NSString *)value;

/**
 获取手机号
 */
- (NSString *)getMobile;

/**
 缓存用户头像
 */
- (void)setUserAvatar:(NSString *)userAvatar;

/**
 获取用户头像
 */
- (NSString *)getUserAvatar;

// 上一次登录账号
- (void)setLastLoginAccount:(NSString *)value;

// 获取上一次登录账号
- (NSString *)getLastLoginAccount;

// 选择部门ID
- (void)setSelectDeparmentId:(NSString *)value;

// 获取选择部门ID
- (NSString *)getSelectDeparmentId;

// 储存发送邮件UID
- (void)setSendMailUID:(NSString *)value;

// 获取发送邮件UID
- (NSString *)getSendMailUID;

// 选择部门名称
- (void)setSelectDeparmentName:(NSString *)value;

// 获取部门名称
- (NSString *)getSelectDeparmentName;

// 设置网络状态
- (void)setNetworkStatus:(NSInteger)networkStatus;

// 获取网络状态
- (NSInteger)getNetworkStatus;

// 保存当前员工ID
- (void)setCurrentEmployeeId:(NSString *)employeeId;

// 获取当前员工ID
- (NSString *)getCurrentEmployeeId;

@end
