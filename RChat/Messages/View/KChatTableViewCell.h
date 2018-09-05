//
//  KChatTableViewCell.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/25.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KChatTableViewCellDelegate.h"

@class KMessageModel;
@class KConversationModel;

@interface KChatTableViewCell : UITableViewCell
// 发送或收到消息的时间
@property (nonatomic, strong) UILabel       *messageTime;
// 用户头像
@property (nonatomic, strong) UIImageView   *avatarImageView;
// 用户名
@property (nonatomic, strong) UILabel       *username;
// 消息背景
@property (nonatomic, strong) UIImageView   *messageBackgroundImageView;
// 消息发送状态背景
@property (nonatomic, strong) UIImageView   *messageSendStatusImageView;
// 消息数据
@property (nonatomic, strong) KMessageModel *messageModel;
// 所属会话
@property (nonatomic, strong) KConversationModel *conversation;

@property (nonatomic, strong) NSIndexPath   *indexPath;
// jsonStr消息未发送成功，需要读取此值
@property (nonatomic, strong) NSString *jsonStr;
// 消息重新发送成功需要读取此值，更新本地数据库的发送状态和消息id
@property (nonatomic, strong) NSString *localMessageId;

// cell代理事件
@property (nonatomic, assign) id<KChatTableViewCellDelegate> delegate;

// 点击消息背景 
- (void)clickMessageBackgroundImageView:(UITapGestureRecognizer *)gesture;

/**
 更新消息发送状态
 
 @param sendState 发送状态
 @param jsonStr 发送的json数据
 @param messageId 本地消息id
 */
- (void)updateMessageSendState:(KMessageSendStatus)sendState jsonStr:(NSString *)jsonStr localMessageId:(NSString *)messageId;

@end
