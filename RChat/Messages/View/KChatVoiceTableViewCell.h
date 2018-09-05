//
//  KChatVoiceTableViewCell.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/7.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KChatTableViewCell.h"

@interface KChatVoiceTableViewCell : KChatTableViewCell
// 秒数
@property (nonatomic, strong) UILabel *second;
// 语音图标
@property (nonatomic, strong) UIImageView *voiceImageView;

@end
