//
//  KChatTableViewCellDelegate.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/25.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#ifndef KChatTableViewCellDelegate_h
#define KChatTableViewCellDelegate_h

@class KMessageModel;
@class KChatTableViewCell;
@class KConversationModel;
@class KChatMailTableViewCell;
@class KChatVoiceTableViewCell;

@protocol KChatTableViewCellDelegate <NSObject>

/**
 点击cell中的头像

 @param tableViewCell 当前cell
 @param messageModel 当前cell的数据
 */
- (void)chatTableViewCell:(KChatTableViewCell *)tableViewCell clickAvatarImageViewMessageModel:(KMessageModel *)messageModel;

/**
 点击消息背景

 @param tableViewCell 当前cell
 @param messageModel 当前cell的数据
 */
- (void)chatTableViewCell:(KChatTableViewCell *)tableViewCell clickBackgroudImageViewMessageModel:(KMessageModel *)messageModel;

/**
 当发送失败时点击，发送状态展示视图

 @param tableViewCell 当前cell
 @param conversationModel 会话信息
 @param messageModel 消息
 */
- (void)chatTableViewCell:(KChatTableViewCell *)tableViewCell clickResendMessageWithConversationModel:(KConversationModel *)conversationModel messageModel:(KMessageModel *)messageModel;

/**
 点击回复邮件

 @param tableViewCell 当前cell
 @param messageModel 当前cell的数据
 */
- (void)chatTableViewCell:(KChatMailTableViewCell *)tableViewCell replyMailMessageModel:(KMessageModel *)messageModel;

/**
 点击回复全部

 @param tableViewCell 当前cell
 @param messageModel 当前cell的数据
 */
- (void)chatTableViewCell:(KChatMailTableViewCell *)tableViewCell
replyAllMaillMessageModel:(KMessageModel *)messageModel;

/**
 点击转发邮件

 @param tableViewCell 当前cell
 @param messageModel 当前cell的数据
 */
- (void)chatTableViewCell:(KChatMailTableViewCell *)tableViewCell
 transmitMailMessageModel:(KMessageModel *)messageModel;

/**
 点击语音消息

 @param tableViewCell 当前cell
 @param messageModel 当前数据
 */
- (void)chatTableViewCell:(KChatVoiceTableViewCell *)tableViewCell clickVoiceMessageMessageModel:(KMessageModel *)messageModel;

@end

#endif /* KChatTableViewCellDelegate_h */
