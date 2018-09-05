//
//  KChatMailTableViewCell.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/25.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KChatTableViewCell.h"

@interface KChatMailTableViewCell : KChatTableViewCell
// 自己发的邮件是否显示“回复”、“回复全部”和“转发”  默认不显示
@property (nonatomic, assign) BOOL selfSenderMailShowReply;

@end
