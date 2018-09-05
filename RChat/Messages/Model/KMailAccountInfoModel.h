//
//  KMailAccountInfoModel.h
//  KXiniuCloud
//
//  Created by RPK on 2017/8/14.
//  Copyright © 2017年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMailAccountInfoModel : NSObject

@property (nonatomic, copy)     NSString *mailId;           /**< 邮箱ID */
@property (nonatomic, copy)     NSString *emailName;        /**< 名称 */
@property (nonatomic, copy)     NSString *emailAccount;     /**< 邮箱账号 */
@property (nonatomic, copy)     NSString *emailPassword;    /**< 邮箱密码 */

@property (nonatomic, copy)     NSString *sendServer;       /**< 发送服务器 */
@property (nonatomic, copy)     NSString *sendProtocol;     /**< 发送协议 */
@property (nonatomic, assign)   int sendPort;               /**< 发送端口 */
@property (nonatomic, assign)   int isSendSSL;              /**< 发送SSL */

@property (nonatomic, copy)     NSString *recevieServer;    /**< 收取服务器 */
@property (nonatomic, copy)     NSString *recevieProtocol;  /**< 接收协议 */
@property (nonatomic, assign)   int receviePort;            /**< 接收端口 */
@property (nonatomic, assign)   int isReceiveSSL;           /**< 接收SSL */

@property (nonatomic, copy)     NSString *signature;        /**< 签名 */
@property (nonatomic, assign)   int xiniuId;                /**< 犀牛ID */
@property (nonatomic, assign)   int companyId;              /**< 企业ID */
@property (nonatomic, assign)   int timestamp;              /**< 时间戳 */

@end
