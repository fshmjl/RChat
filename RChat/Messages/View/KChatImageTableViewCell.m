//
//  KChatImageTableViewCell.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/11.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KChatImageTableViewCell.h"


#import "KMessageModel.h"

@implementation KChatImageTableViewCell
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.messageImageView];
        [self.messageImageView addGestureRecognizer:self.tapImageView];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    float y = self.username.kMax_y;
    if (self.messageModel.direction == KMessageSenderTypeSender) {
        float x = self.avatarImageView.mj_x - self.messageImageView.mj_w - MESSAGE_BACKGROUND_SPACE;
        [self.messageImageView setOrigin:CGPointMake(x, y)];
        [self.messageBackgroundImageView setFrame:CGRectMake(0, 0, 0, 0)];
        self.messageSendStatusImageView.hidden = self.messageModel.messageSendStatus == KMessageSendStatusSendSuccess;
        self.messageSendStatusImageView.frame = CGRectMake(self.messageImageView.mj_x - MESSAGE_BACKGROUND_SPACE - 20, self.messageImageView.center.y - 20/2, 20, 20);
    }
    else if (self.messageModel.direction == KMessageSenderTypeReceiver) {
        float x = self.avatarImageView.mj_x + self.avatarImageView.mj_w + MESSAGE_BACKGROUND_SPACE;
        [self.messageImageView setOrigin:CGPointMake(x, y)];
        [self.messageBackgroundImageView setFrame:CGRectMake(0, 0, 0, 0)];
        self.messageSendStatusImageView.hidden = YES;
        self.messageSendStatusImageView.frame = CGRectMake(self.messageImageView.kMax_x + MESSAGE_BACKGROUND_SPACE, self.messageImageView.kMax_y - 20, 20, 20);
    }
}

- (void)updateMessageSendState:(KMessageSendStatus)sendState jsonStr:(NSString *)jsonStr localMessageId:(NSString *)messageId {
    [super updateMessageSendState:sendState jsonStr:jsonStr localMessageId:messageId];
}

#pragma mark - Getter and Setter
-(void)setMessageModel:(KMessageModel *)messageModel
{
    [super setMessageModel:messageModel];
    
    if (messageModel.fileData) {
        [self.messageImageView setSize:CGSizeMake(messageModel.messageSize.width, messageModel.messageSize.height)];
        self.messageImageView.image = [UIImage imageWithData:messageModel.fileData];
    }
    else if(messageModel.content)
    {
        if ([messageModel.content isKindOfClass:[NSData class]]) {
            self.messageImageView.image = [UIImage imageWithData:messageModel.content];
        }
        else {
            NSString *filePath = messageModel.content;
            NSString *placeholderPath = [[NSBundle mainBundle] pathForResource:@"message_photo_default" ofType:@"png"];
            UIImage *placeholderImage = [UIImage imageWithContentsOfFile:placeholderPath];
            if ([filePath rangeOfString:@"http://"].location != NSNotFound || [filePath rangeOfString:@"https://"].location != NSNotFound)
            {
                [self.messageImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.content] placeholderImage:placeholderImage];
            }
            else
            {
                if ([filePath rangeOfString:@"storage/msgs/"].location != NSNotFound)
                {
                    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", kDocDir, filePath];
                    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                    self.messageImageView.image = image;
                }
            }
        }
        if (messageModel.messageSize.width == -1 || messageModel.messageSize.height == -1 || messageModel.messageSize.width == 0 || messageModel.messageSize.height == 0) {
            [self.messageImageView setSize:CGSizeMake(messageModel.estimateSize.width, messageModel.estimateSize.height)];
        }
        else {
            [self.messageImageView setSize:CGSizeMake(messageModel.messageSize.width, messageModel.messageSize.height)];
        }
    }
}

- (void)clickImageView:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:clickBackgroudImageViewMessageModel:)]) {
        [self.delegate chatTableViewCell:self clickBackgroudImageViewMessageModel:self.messageModel];
    }
}

- (UIImageView *) messageImageView
{
    if (_messageImageView == nil) {
        _messageImageView = [[UIImageView alloc] init];
        [_messageImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_messageImageView setClipsToBounds:YES];
        _messageImageView.layer.cornerRadius = 5;
        _messageImageView.layer.masksToBounds = YES;
        _messageImageView.userInteractionEnabled = YES;
    }
    return _messageImageView;
}

- (UITapGestureRecognizer *)tapImageView {
    if (!_tapImageView) {
        _tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
    }
    return _tapImageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
