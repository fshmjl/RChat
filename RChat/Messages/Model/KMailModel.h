//
//  KMailModel.h
//  KXiniuCloud
//
//  Created by RPK on 2017/8/17.
//  Copyright © 2017年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMailModel : NSObject

@property (nonatomic, copy) NSString *Id;               /**< 数据库ID */
@property (nonatomic, copy) NSString *uid;              /**< 邮件ID */
@property (nonatomic, copy) NSString *mailId;           /**< 邮箱ID */
@property (nonatomic, copy) NSString *senderEmail;      /**< 发件人邮箱 */
@property (nonatomic, copy) NSString *senderName;       /**< 发件人昵称 */
@property (nonatomic, copy) NSString *nativeFromsName;  /**< 本地备注发件人昵称 */
@property (nonatomic, copy) NSString *subject;          /**< 标题 */
@property (nonatomic, copy) NSString *to;               /**< 收件人 ( RPK<liuke@eims.com.cn> 多个用","隔开) */
@property (nonatomic, copy) NSString *cc;               /**< 抄送 (多个用","隔开)*/
@property (nonatomic, copy) NSString *bcc;              /**< 密送 (多个用","隔开)*/
@property (nonatomic, copy) NSArray *addresseeMailboxs; /**< 收件人 */
@property (nonatomic, copy) NSArray *ccMailboxs;        /**< 抄送 */
@property (nonatomic, copy) NSArray *bccMailboxs;       /**< 密送 */
@property (nonatomic, copy) NSDate  *sendTime;          /**< 发送时间 */
@property (nonatomic, copy) NSString *contentSynopsis;  /**< 内容简介 - 用于列表展示 */
@property (nonatomic, copy) NSString *content;          /**< 内容详情 */
@property (nonatomic, copy) NSString *image;            /**< 邮箱图标 */

@property (nonatomic, assign) int readStatus;           /**< 状态：0：已读    1：未读*/
@property (nonatomic, assign) int folderType;           /**< 状态：0：收件    1：草稿箱   2：发件箱       3、已发送   4：已删除   5：垃圾箱*/

@property (nonatomic, assign) NSUInteger attach;            /**< 附件个数 */
@property (nonatomic, copy) NSArray *attachments;           /**< 附件 */
@property (nonatomic, copy) NSArray *htmlInlineAttachments; /**< 正文附件 */

@property (nonatomic, copy) NSString *attachmentsURL;           /**< 附件URL拼接字符串( , 分割)*/

@end
