//
//  KChatTextTableViewCell.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/25.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KChatTableViewCell.h"

@class KTextView;

@interface KChatTextTableViewCell : KChatTableViewCell

// 消息文本框
@property (nonatomic, strong) KTextView *textView;

@end
