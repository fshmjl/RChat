//
//  KAppDefaultUtil.m
//  KXiniuCloud
//
//  Created by RPK on 2017/8/21.
//  Copyright © 2017年 EIMS. All rights reserved.
//

#import "KAppDefaultUtil.h"


#define KEY_MAIL_ID                 @"MailID"               // 邮箱ID
#define KEY_MAIL_NAME               @"MailName"             // 邮箱名称
#define KEY_MAIL_ACCOUNT            @"MailAccount"          // 邮箱账号
#define KEY_MAIL_PASSWORD           @"MailPassword"         // 邮箱密码

#define KEY_MAIL_SENDPORT           @"SendPort"             // 接收端口号
#define KEY_MAIL_ISSENDSSL          @"IsSendSSL"            // 接收SSL
#define KEY_MAIL_SENDSERVER         @"SendServer"           // 接收服务器
#define KEY_MAIL_SENDPROTOCOL       @"SendProtocol"         // 接收协议

#define KEY_MAIL_RECEVIEPORT        @"ReceviePort"          // 接收端口号
#define KEY_MAIL_ISRECEIVESSL       @"IsReceiveSSL"         // 接收SSL
#define KEY_MAIL_RECEVIESERVER      @"RecevieServer"        // 接收服务器
#define KEY_MAIL_RECEVIEPROTOCOL    @"RecevieProtocol"      // 接收协议

#define KEY_MAIL_SIGNATURE          @"Signature"            // 邮箱签名

#define KEY_MAIL_COMPANYID          @"CompanyID"            // 企业ID
#define KEY_XINIUID                 @"XiniuID"              // 犀牛ID
#define KEY_USERNAME                @"UserName"             // 用户昵称
#define KEY_MOBILE                  @"MobileID"             // 手机号
#define KEY_LASTLOGINACCOUNT        @"LastLoginAccount"     // 上一次登录账号

#define KEY_SELECT_DEPARMENTID      @"SelectDeparmentID"    // 选中部门ID
#define KEY_SELECT_DEPARMENTNAME    @"SelectDeparmentName"  // 选中部门名称

#define KEY_MAIL_FOLDER             @"Folder"               // 邮箱文件夹
#define KEY_SEND_MAILUID            @"SendMailUID"          // 发送邮件UID
#define KEY_USER_AVATAR             @"userAvatar"           // 用户头像

#define KEY_NETWORK_STATUS          @"NetworkStatus"        // 当前网络状态
#define KEY_CURRENT_EMPLOYEEID      @"CurrentEmployeeId"    // 当前员工ID

#define KEY_ISCOMPANYMAIL           @"isCompanyMail"        // 是否企业邮箱账号

// 缓存邮件历史搜索记录
#define KCacheMailHistorySearchData         @"cacheMailHistorySearchData"
// 缓存联系人历史搜索记录
#define KCacheContactsHistorySearchData     @"cacheContactsHistorySearchData"

#define defaults  [NSUserDefaults standardUserDefaults]

@implementation KAppDefaultUtil

+ (instancetype)sharedInstance {
    
    static KAppDefaultUtil *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [super allocWithZone:NULL];
        
    });
    
    return _sharedClient;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [KAppDefaultUtil sharedInstance];
}

// 设置邮箱信息
- (void)setMailInfo:(KMailAccountInfoModel *)model {
    
    if (model != nil) {
       // [KMailConfig savePasswordWithMail:model.emailAccount password:model.emailPassword];
    }
    
    [defaults setObject:model.mailId forKey:KEY_MAIL_ID];
    [defaults setObject:model.emailName forKey:KEY_MAIL_NAME];
    [defaults setObject:model.emailAccount forKey:KEY_MAIL_ACCOUNT];
    
    [defaults setInteger:model.receviePort forKey:KEY_MAIL_RECEVIEPORT];
    [defaults setInteger:model.isReceiveSSL forKey:KEY_MAIL_ISRECEIVESSL];
    [defaults setObject:model.recevieServer forKey:KEY_MAIL_RECEVIESERVER];
    [defaults setObject:model.recevieProtocol forKey:KEY_MAIL_RECEVIEPROTOCOL];
    
    [defaults setInteger:model.sendPort forKey:KEY_MAIL_SENDPORT];
    [defaults setInteger:model.isSendSSL forKey:KEY_MAIL_ISSENDSSL];
    [defaults setObject:model.sendServer forKey:KEY_MAIL_SENDSERVER];
    [defaults setObject:model.sendProtocol forKey:KEY_MAIL_SENDPROTOCOL];
    
    [defaults setObject:model.signature forKey:KEY_MAIL_SIGNATURE];
    
    [defaults setInteger:model.companyId forKey:KEY_MAIL_COMPANYID];
    
    [defaults synchronize];
    
}

// 获取邮箱信息
- (KMailAccountInfoModel *)getMailInfo {
    
    KMailAccountInfoModel *mailModel = [KMailAccountInfoModel new];
    mailModel.mailId            = [defaults stringForKey:KEY_MAIL_ID];
    mailModel.emailName         = [defaults stringForKey:KEY_MAIL_NAME];
    mailModel.emailAccount      = [defaults stringForKey:KEY_MAIL_ACCOUNT];
    if (mailModel.emailAccount != nil) {
        //mailModel.emailPassword = [KMailConfig getMailPassword:mailModel.emailAccount];
    }
    mailModel.receviePort       = (int)[defaults integerForKey:KEY_MAIL_RECEVIEPORT];
    mailModel.isReceiveSSL      = (int)[defaults integerForKey:KEY_MAIL_ISRECEIVESSL];
    mailModel.recevieServer     = [defaults stringForKey:KEY_MAIL_RECEVIESERVER];
    mailModel.recevieProtocol   = [defaults stringForKey:KEY_MAIL_RECEVIEPROTOCOL];
    
    mailModel.sendPort          = (int)[defaults integerForKey:KEY_MAIL_SENDPORT];
    mailModel.isSendSSL         = (int)[defaults integerForKey:KEY_MAIL_ISSENDSSL];
    mailModel.sendServer        = [defaults stringForKey:KEY_MAIL_SENDSERVER];
    mailModel.sendProtocol      = [defaults stringForKey:KEY_MAIL_SENDPROTOCOL];
    
    mailModel.signature         = [defaults stringForKey:KEY_MAIL_SIGNATURE];
    
    mailModel.xiniuId           = (int)[defaults integerForKey:KEY_XINIUID];
    mailModel.companyId         = (int)[defaults integerForKey:KEY_MAIL_COMPANYID];
    
    return mailModel;
    
}

// 邮箱名称
- (void)setMailName:(NSString *)value
{
    [defaults setObject:value forKey:KEY_MAIL_NAME];
    [defaults synchronize];
}

// 获取邮箱名称
- (NSString *)getMailName
{
    return [defaults stringForKey:KEY_MAIL_NAME];
}

// 邮箱账号
- (void)setMailAccount:(NSString *)value
{
    [defaults setObject:value forKey:KEY_MAIL_ACCOUNT];
    [defaults synchronize];
}

// 获取邮箱账号
- (NSString *)getMailAccount
{
    return [defaults stringForKey:KEY_MAIL_ACCOUNT];
}

// 邮箱密码
- (void)setMailPassword:(NSString *)value
{
    [defaults setObject:value forKey:KEY_MAIL_PASSWORD];
    [defaults synchronize];
}

// 获取邮箱密码
- (NSString *)getMailPassword
{
    return [defaults stringForKey:KEY_MAIL_PASSWORD];
}

// 邮箱 -> 接收服务器
- (void)setMailRecevieServer:(NSString *)value
{
    [defaults setObject:value forKey:KEY_MAIL_RECEVIESERVER];
    [defaults synchronize];
}

// 获取邮箱 -> 接收服务器
- (NSString *)getMailRecevieServer
{
    return [defaults stringForKey:KEY_MAIL_RECEVIESERVER];
}

// 邮箱 -> 接收协议
- (void)setMailRecevieProtocol:(NSString *)value
{
    [defaults setObject:value forKey:KEY_MAIL_RECEVIEPROTOCOL];
    [defaults synchronize];
}

// 获取邮箱 -> 接收协议
- (NSString *)getMailRecevieProtocol
{
    return [defaults stringForKey:KEY_MAIL_RECEVIEPROTOCOL];
}

// 邮箱 -> 接收端口号
- (void)setMailReceviePort:(int)value
{
    [defaults setInteger:value forKey:KEY_MAIL_RECEVIEPORT];
    [defaults synchronize];
}

// 获取邮箱 -> 接收端口号
- (int)getMailReceviePort
{
    return (int)[defaults integerForKey:KEY_MAIL_RECEVIEPORT];
}

// 邮箱 -> 接收SSL
- (void)setMailIsReceiveSSL:(int)value
{
    [defaults setInteger:value forKey:KEY_MAIL_ISRECEIVESSL];
    [defaults synchronize];
}

// 获取邮箱 -> 接收SSL
- (int)getMailIsReceiveSSL
{
    return (int)[defaults integerForKey:KEY_MAIL_ISRECEIVESSL];
}

// 邮箱 -> 发送服务器
- (void)setMailSendServer:(NSString *)value
{
    [defaults setObject:value forKey:KEY_MAIL_SENDSERVER];
    [defaults synchronize];
}

// 获取邮箱 -> 接收服务器
- (NSString *)getMailSendServer
{
    return [defaults stringForKey:KEY_MAIL_SENDSERVER];
}

// 邮箱 -> 发送协议
- (void)setMailSendProtocol:(NSString *)value
{
    [defaults setObject:value forKey:KEY_MAIL_SENDPROTOCOL];
    [defaults synchronize];
}

// 获取邮箱 -> 发送协议
- (NSString *)getMailSendProtocol
{
    return [defaults stringForKey:KEY_MAIL_SENDPROTOCOL];
}

// 邮箱 -> 发送端口号
- (void)setMailSendPort:(int)value
{
    
    [defaults setInteger:value forKey:KEY_MAIL_SENDPORT];
    [defaults synchronize];
}

// 获取邮箱 -> 发送端口号
- (int)getMailSendPort
{
    
    return (int)[defaults integerForKey:KEY_MAIL_SENDPORT];
}

// 邮箱 -> 发送SSL
- (void)setMailIsSendSSL:(int)value
{
    
    [defaults setInteger:value forKey:KEY_MAIL_ISSENDSSL];
    [defaults synchronize];
}

// 获取邮箱 -> 发送SSL
- (int)getMailIsSendSSL
{
    
    return (int)[defaults integerForKey:KEY_MAIL_ISSENDSSL];
}

// 邮箱签名
- (void)setMailSignature:(NSString *)value
{
    
    [defaults setObject:value forKey:KEY_MAIL_SIGNATURE];
    [defaults synchronize];
}

// 获取邮箱签名
- (NSString *)getMailSignature
{
    
    return [defaults stringForKey:KEY_MAIL_SIGNATURE];
}

// 邮箱当前选中文件夹
- (void)setMailFolder:(NSString *)value
{
    
    [defaults setObject:value forKey:KEY_MAIL_FOLDER];
    [defaults synchronize];
}

// 获取邮箱当前选中文件夹
- (NSString *)getMailFolder
{
    
    return [defaults stringForKey:KEY_MAIL_FOLDER];
}

// 缓存邮件历史搜索记录
- (void)setCacheMailHistorySearchData:(NSArray *)value
{
    
    [defaults setObject:value forKey:KCacheMailHistorySearchData];
    [defaults synchronize];
}

// 获取邮件历史搜索记录
- (NSArray *)getCacheMailHistorySearchData
{
    
    return [defaults arrayForKey:KCacheMailHistorySearchData];
}

// 缓存联系人历史搜索记录
- (void)setCacheContactsHistorySearchData:(NSArray *)value
{
    
    [defaults setObject:value forKey:KCacheContactsHistorySearchData];
    [defaults synchronize];
}

// 获取联系人历史搜索记录
- (NSArray *)getCacheContactsHistorySearchData
{
    
    return [defaults arrayForKey:KCacheContactsHistorySearchData];
}

// 缓存犀牛ID
- (void)setXiniuID:(NSString *)value {
    [defaults setObject:value forKey:KEY_XINIUID];
    [defaults synchronize];
}

// 获取犀牛ID
- (NSString *)getXiniuID {
    return [defaults stringForKey:KEY_XINIUID];
}

// 缓存用户名
- (void)setUserName:(NSString *)value {
    [defaults setObject:value forKey:KEY_USERNAME];
    [defaults synchronize];
}

// 获取用户名
- (NSString *)getUserName {
    return [defaults stringForKey:KEY_USERNAME];
}

// 缓存手机号
- (void)setMobile:(NSString *)value {
    [defaults setObject:value forKey:KEY_MOBILE];
    [defaults synchronize];
}

// 获取手机号
- (NSString *)getMobile
{
    return [defaults stringForKey:KEY_MOBILE];
}

/**
 缓存用户头像
 */
- (void)setUserAvatar:(NSString *)userAvatar
{
    [defaults setObject:userAvatar forKey:KEY_USER_AVATAR];
    [defaults synchronize];
}

/**
 获取用户头像
 */
- (NSString *)getUserAvatar
{
    return [defaults stringForKey:KEY_USER_AVATAR];
}

// 上一次登录账号
- (void)setLastLoginAccount:(NSString *)value
{
    [defaults setObject:value forKey:KEY_LASTLOGINACCOUNT];
    [defaults synchronize];
}

// 获取上一次登录账号
- (NSString *)getLastLoginAccount
{
    return [defaults stringForKey:KEY_LASTLOGINACCOUNT];
}

// 选择部门ID
- (void)setSelectDeparmentId:(NSString *)value
{
    [defaults setObject:value forKey:KEY_SELECT_DEPARMENTID];
    [defaults synchronize];
}

// 获取选择部门ID
- (NSString *)getSelectDeparmentId
{
    return [defaults stringForKey:KEY_SELECT_DEPARMENTID];
}

// 选择部门名称
- (void)setSelectDeparmentName:(NSString *)value
{
    [defaults setObject:value forKey:KEY_SELECT_DEPARMENTNAME];
    [defaults synchronize];
}

// 获取部门名称
- (NSString *)getSelectDeparmentName
{
    return [defaults stringForKey:KEY_SELECT_DEPARMENTNAME];
}

// 储存发送邮件UID
- (void)setSendMailUID:(NSString *)value
{
    [defaults setObject:value forKey:KEY_SEND_MAILUID];
    [defaults synchronize];
}

// 获取发送邮件UID
- (NSString *)getSendMailUID
{
    return [defaults stringForKey:KEY_SEND_MAILUID];
}

// 设置网络状态
- (void)setNetworkStatus:(NSInteger)networkStatus
{
    [defaults setObject:@(networkStatus) forKey:KEY_NETWORK_STATUS];
    [defaults synchronize];
}

// 获取网络状态
- (NSInteger)getNetworkStatus {
    return [defaults integerForKey:KEY_NETWORK_STATUS];
}

// 保存当前员工id
- (void)setCurrentEmployeeId:(NSString *)employeeId {
    [defaults setObject:employeeId forKey:KEY_CURRENT_EMPLOYEEID];
    [defaults synchronize];
}

// 获取当前员工id
- (NSString *)getCurrentEmployeeId {
    return [defaults objectForKey:KEY_CURRENT_EMPLOYEEID];
}

@end
