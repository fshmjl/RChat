//
//  KConversationModel.h
//  KXiniuCloud
//
//  Created by RPK on 2018/6/11.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KMessageModel;
@interface KConversationModel : NSObject
// 会话名
@property (nonatomic, strong) NSString            *conversationName;
// 会话id
@property (nonatomic, strong) NSString            *conversationId;
// 会话类型
@property (nonatomic, assign) KMessageChatType    chatType;
// 会话头像
@property (nonatomic, strong) NSString            *headImage;
// 最后一条消息
@property (nonatomic, strong) KMessageModel       *message;
// 未读消息
@property (nonatomic, assign) int                 badgeNumber;
// 犀牛id
@property (nonatomic, strong) NSString            *toUserId;
// 员工id
@property (nonatomic, strong) NSString            *toEmployeeId;

@end
