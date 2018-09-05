//
//  KChatVideoTableViewCell.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/16.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KChatVideoTableViewCell.h"

#import "KMessageModel.h"
#import "UIImage+KVideo.h"

@implementation KChatVideoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.videoImageView];
        [self.videoImageView addSubview:self.playImageView];
        [self.videoImageView addSubview:self.recordTime];
        self.videoImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [self.videoImageView addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat y = self.username.kMax_y;
    CGFloat x = 0;
    if (self.messageModel.direction == KMessageSenderTypeSender) {
        self.messageSendStatusImageView.hidden = self.messageModel.messageSendStatus == KMessageSendStatusSendSuccess;
        x = self.avatarImageView.mj_x - self.videoImageView.mj_w - MESSAGE_BACKGROUND_SPACE;
        [self.videoImageView setOrigin:CGPointMake(x, y)];
        [self.messageBackgroundImageView setFrame:CGRectMake(0, 0, 0, 0)];
        self.messageSendStatusImageView.frame = CGRectMake(self.videoImageView.mj_x - MESSAGE_BACKGROUND_SPACE - 20, self.videoImageView.kMax_y - 20, 20, 20);
    }
    else {
        self.messageSendStatusImageView.hidden = YES;
        x = self.avatarImageView.mj_x + self.avatarImageView.mj_w + MESSAGE_BACKGROUND_SPACE;
        [self.videoImageView setOrigin:CGPointMake(x, y)];
        [self.messageBackgroundImageView setFrame:CGRectMake(0, 0, 0, 0)];
        self.messageSendStatusImageView.frame = CGRectMake(self.videoImageView.kMax_x + MESSAGE_BACKGROUND_SPACE, self.videoImageView.kMax_y - 20, 20, 20);
    }
    self.playImageView.center = CGPointMake(self.videoImageView.mj_w/2., self.videoImageView.mj_h/2.);
    [self.recordTime setOrigin:CGPointMake(self.videoImageView.mj_w - 60 - 5, self.videoImageView.mj_h - 20)];
    
}

- (void)tapGestureAction:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:clickBackgroudImageViewMessageModel:)]) {
        [self.delegate chatTableViewCell:self clickBackgroudImageViewMessageModel:self.messageModel];
    }
}

- (void)updateMessageSendState:(KMessageSendStatus)sendState jsonStr:(NSString *)jsonStr localMessageId:(NSString *)messageId {
    [super updateMessageSendState:sendState jsonStr:jsonStr localMessageId:messageId];
}

- (void)setMessageModel:(KMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    
    self.recordTime.text = [NSString stringWithFormat:@"0:%02d",messageModel.duringTime];
    if (messageModel.fileData) {
        self.videoImageView.image = [UIImage imageWithData:messageModel.fileData];
        [self.videoImageView setSize:messageModel.messageSize];
        return;
    }
    
    if (!messageModel.fileData && messageModel.content) {
        UIImage *image = [UIImage imageWithVideo:messageModel.content];
        self.videoImageView.image = image;
        [self.videoImageView setSize:messageModel.messageSize];
        return;
    }
    
}

- (UIImageView *)videoImageView {
    if (!_videoImageView) {
        _videoImageView = [[UIImageView alloc] init];
        _videoImageView.userInteractionEnabled = YES;
        _videoImageView.layer.cornerRadius = 5;
        _videoImageView.layer.masksToBounds = YES;
    }
    return _videoImageView;
}

- (UIImageView *)playImageView {
    if (!_playImageView) {
        _playImageView = [[UIImageView alloc] init];
        [_playImageView setSize:CGSizeMake(40, 40)];
        _playImageView.userInteractionEnabled = YES;
        _playImageView.image = [UIImage imageNamed:@"icon_inputBox_video_play"];
    }
    return _playImageView;
}

- (UILabel *)recordTime {
    if (!_recordTime) {
        _recordTime = [[UILabel alloc] init];
        [_recordTime setSize:CGSizeMake(60, 20)];
        _recordTime.textColor = [UIColor whiteColor];
        _recordTime.font = [UIFont systemFontOfSize:12];
        _recordTime.textAlignment = NSTextAlignmentRight;
    }
    return _recordTime;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
