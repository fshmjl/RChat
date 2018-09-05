//
//  KMessagesListTableViewCell.h
//  KXiniuCloud
//
//  Created by RPK on 2018/4/17.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KConversationModel;

@interface KMessagesListTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel       *titleLabel;        /**< 标题 */
@property (nonatomic, strong) UILabel       *messageLabel;      /**< 部分信息内容 */
@property (nonatomic, strong) UILabel       *updateTime;        /**< 消息更新时间 */
@property (nonatomic, strong) UILabel       *badgeNumber;       /**< 未读消息数 */
@property (nonatomic, strong) UIImageView   *avaterImageView;   /**< 用户头像 */
// 消息数据
@property (nonatomic, strong) KConversationModel *conversation;


@end
