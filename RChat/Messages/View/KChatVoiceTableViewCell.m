//
//  KChatVoiceTableViewCell.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/7.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KChatVoiceTableViewCell.h"


#import "KMessageModel.h"

@implementation KChatVoiceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    self.voiceImageView = [[UIImageView alloc] init];
    self.voiceImageView.animationRepeatCount = 0;
    self.voiceImageView.animationDuration    = 2;
    [self.messageBackgroundImageView addSubview:self.voiceImageView];
    
    self.second = [[UILabel alloc] init];
    self.second.textColor = [UIColor lightGrayColor];
    self.second.font      = [UIFont systemFontOfSize:15];
    [self addSubview:self.second];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = [self voiceLength:self.messageModel.duringTime];
    if (self.messageModel.direction == KMessageSenderTypeSender)
    {
        self.messageSendStatusImageView.hidden = self.messageModel.messageSendStatus == KMessageSendStatusSendSuccess;
        self.messageBackgroundImageView.frame = CGRectMake(self.avatarImageView.mj_x - 3 * MESSAGE_BACKGROUND_SPACE - width, self.username.mj_y + self.username.mj_h, width + 2 * MESSAGE_BACKGROUND_SPACE, AVATAR_WIDTH);
        self.voiceImageView.frame = CGRectMake(self.messageBackgroundImageView.mj_w - MESSAGE_BACKGROUND_SPACE - (AVATAR_WIDTH - 20), MESSAGE_BACKGROUND_SPACE, AVATAR_WIDTH - 25, AVATAR_WIDTH - 20);
        self.second.frame = CGRectMake(self.messageBackgroundImageView.mj_x - MESSAGE_BACKGROUND_SPACE - 30, self.messageBackgroundImageView.kMax_y - 20 - 5, 30, 20);
        self.second.textAlignment = NSTextAlignmentRight;
        self.messageSendStatusImageView.frame = CGRectMake(self.second.mj_x - MESSAGE_BACKGROUND_SPACE - 20, 0 , 20, 20);
        self.messageSendStatusImageView.center = CGPointMake(self.second.mj_x - MESSAGE_BACKGROUND_SPACE - 10, self.messageBackgroundImageView.center.y);
    }
    else
    {
        self.messageSendStatusImageView.hidden = YES;
        self.messageBackgroundImageView.frame = CGRectMake(self.avatarImageView.kMax_x + MESSAGE_BACKGROUND_SPACE, self.username.mj_y + self.username.mj_h, width + 2 * MESSAGE_BACKGROUND_SPACE, AVATAR_WIDTH);
        self.voiceImageView.frame = CGRectMake(MESSAGE_BACKGROUND_SPACE, MESSAGE_BACKGROUND_SPACE, AVATAR_WIDTH - 25, AVATAR_WIDTH - 20);
        self.second.frame = CGRectMake(self.messageBackgroundImageView.kMax_x + MESSAGE_BACKGROUND_SPACE, self.messageBackgroundImageView.kMax_y - 20 - 5, 30, 20);
        self.second.textAlignment = NSTextAlignmentLeft;
        self.messageSendStatusImageView.frame = CGRectMake(self.second.kMax_x + MESSAGE_BACKGROUND_SPACE, self.second.kMax_y - 20, 20, 20);
    }
}

- (void)updateMessageSendState:(KMessageSendStatus)sendState jsonStr:(NSString *)jsonStr localMessageId:(NSString *)messageId {
    [super updateMessageSendState:sendState jsonStr:jsonStr localMessageId:messageId];
}

- (void)setMessageModel:(KMessageModel *)messageModel
{
    [super setMessageModel:messageModel];
    
    if (messageModel.duringTime != 0) {
        self.voiceImageView.hidden = NO;
        self.second.text = [NSString stringWithFormat:@"%d\"",messageModel.duringTime/1000];
    }
    else {
        self.voiceImageView.hidden = YES;
        self.second.text = @"";
    }
    
    if (messageModel.direction == KMessageSenderTypeSender) {
        self.voiceImageView.image = [UIImage imageNamed:@"icon_message_voice_send_2"];
        self.voiceImageView.animationImages = [NSArray arrayWithObjects:
                                               [UIImage imageNamed:@"icon_message_voice_send_2"],
                                               [UIImage imageNamed:@"icon_message_voice_send_1"],
                                               [UIImage imageNamed:@"icon_message_voice_send_0"],
                                               [UIImage imageNamed:@"icon_message_voice_send_1"],
                                               [UIImage imageNamed:@"icon_message_voice_send_2"],
                                               nil];
        
    }
    else
    {
        self.voiceImageView.image = [UIImage imageNamed:@"icon_message_voice_receive_2"];
        self.voiceImageView.animationImages = [NSArray arrayWithObjects:
                                               [UIImage imageNamed:@"icon_message_voice_receive_2"],
                                               [UIImage imageNamed:@"icon_message_voice_receive_1"],
                                               [UIImage imageNamed:@"icon_message_voice_receive_0"],
                                               [UIImage imageNamed:@"icon_message_voice_receive_1"],
                                               [UIImage imageNamed:@"icon_message_voice_receive_2"],
                                               nil]; 
    }
    
}

-(CGFloat)voiceLength:(NSInteger)millisecond
{
    NSInteger second = millisecond / 1000;
    if (second == 0) {
        return 55;
    }
    
    CGFloat max = MSWIDTH > 375 ? 230 : 197;

    return 55 + (second - 1) * (max - 55) * 1.0/60;
}

@end
