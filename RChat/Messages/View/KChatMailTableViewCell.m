//
//  KChatMailTableViewCell.m
//  KXiniuCloud
//
//  Created by eims on 2018/4/25.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KChatMailTableViewCell.h"

#import "KMessageModel.h"

@interface KChatMailTableViewCell()
// 云邮
@property (nonatomic, strong) UILabel  *mailTips;
// 邮件标题
@property (nonatomic, strong) UILabel  *mailTitle;
// 邮件详情
@property (nonatomic, strong) UILabel  *mailDetail;
// 邮件附件
@property (nonatomic, strong) UILabel  *attachment;
// 回复
@property (nonatomic, strong) UIButton *reply;
// 回复全部
@property (nonatomic, strong) UIButton *replyAll;
// 转发邮件
@property (nonatomic, strong) UIButton *transmit;
// 消息高度
@property (nonatomic, assign) CGSize messageSize;
// 横线
@property (nonatomic, strong) UIView *horizontalLine;
// 第一条竖线
@property (nonatomic, strong) UIView *firstLine;
// 第二条竖线
@property (nonatomic, strong) UIView *secondeLine;

@end

@implementation KChatMailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.messageBackgroundImageView addSubview:self.mailTips];
        [self.messageBackgroundImageView addSubview:self.mailTitle];
        [self.messageBackgroundImageView addSubview:self.mailDetail];
        [self.messageBackgroundImageView addSubview:self.attachment];
        [self.messageBackgroundImageView addSubview:self.reply];
        [self.messageBackgroundImageView addSubview:self.replyAll];
        [self.messageBackgroundImageView addSubview:self.transmit];
        [self initView];
    }
    return self;
}

- (void)initView {
    _horizontalLine = [UIView new];
    _horizontalLine.backgroundColor = [ColorTools colorWithHexString:@"0xececec"];
    [self.messageBackgroundImageView addSubview:_horizontalLine];
    
    for (int i = 0; i < 2; i ++) {
        UIView *line = [UIView new];
        line.backgroundColor = [ColorTools colorWithHexString:@"0xececec"];
        [self.messageBackgroundImageView addSubview:line];
        if (i == 0) {
            _firstLine   = line;
        }
        else {
            _secondeLine = line;
        }
    }
    [_horizontalLine setHidden:YES];
    [_firstLine      setHidden:YES];
    [_secondeLine    setHidden:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 背景高度
    if (self.messageModel.direction == KMessageSenderTypeReceiver)
    {
        self.messageSendStatusImageView.hidden = YES;
        CGFloat height = 0;
        if (self.messageModel.showMessageTime )
        {
            height = self.messageModel.showUsername ? self.mj_h - 2*AVATAR_SCREEN_SPACE - USERNAME_HEIGHT - SHOW_MESSAGE_TIME_HEIGHT : self.mj_h - 2*MESSAGE_BACKGROUND_SPACE - SHOW_MESSAGE_TIME_HEIGHT;
        }
        else
        {
            height = self.messageModel.showUsername ? self.mj_h - 2*AVATAR_SCREEN_SPACE - USERNAME_HEIGHT  : self.mj_h - 2*MESSAGE_BACKGROUND_SPACE;
        }
        CGFloat originY = self.messageModel.showUsername ? self.username.mj_y + self.username.mj_h + 2 : self.avatarImageView.mj_y;
        [self.messageBackgroundImageView setFrame:CGRectMake(self.avatarImageView.mj_x + AVATAR_SCREEN_SPACE + AVATAR_WIDTH, originY, MESSAGE_MAX_WIDTH, height)];
        [self showBottomView];
        self.messageSendStatusImageView.frame = CGRectMake(self.messageBackgroundImageView.kMax_x + MESSAGE_BACKGROUND_SPACE, self.messageBackgroundImageView.kMax_y - 20, 20, 20);
    }
    else
    {
        self.messageSendStatusImageView.hidden = self.messageModel.messageSendStatus == KMessageSendStatusSendSuccess;
        CGFloat height = self.messageModel.showMessageTime ? self.mj_h - SHOW_MESSAGE_TIME_HEIGHT - 2*MESSAGE_BACKGROUND_SPACE : self.mj_h - 2*MESSAGE_BACKGROUND_SPACE;
        [self.messageBackgroundImageView setFrame:CGRectMake(self.avatarImageView.mj_x - AVATAR_SCREEN_SPACE - MESSAGE_MAX_WIDTH, self.avatarImageView.mj_y, MESSAGE_MAX_WIDTH, height)];
        // 判断自己发的邮件是否需要隐藏 回复 等底部按钮
        if (SELF_SENDER_MAIL_SHOW_REPLY || self.selfSenderMailShowReply)
        {
            [self showBottomView];
        }
        else
        {
            [self dismissBottomView];
        }
        self.messageSendStatusImageView.frame = CGRectMake(self.messageBackgroundImageView.mj_x - MESSAGE_BACKGROUND_SPACE - 20, self.messageBackgroundImageView.kMax_y - 20, 20, 20);
    }
    
    // 顶部 云邮提示位置
    self.mailTips.frame              = CGRectMake(MESSAGE_BACKGROUND_SPACE, MESSAGE_BACKGROUND_SPACE, MESSAGE_MAX_WIDTH - 2*MESSAGE_BACKGROUND_SPACE - 5, 16);
    // maxY = 10 + 10 + 16
    // 收到邮件时 右对齐，发送邮件时 左对齐
    self.mailTips.textAlignment      = self.messageModel.direction == KMessageSenderTypeReceiver ? NSTextAlignmentRight : NSTextAlignmentLeft;
    CGSize mailTitleSize             = [self.mailTitle sizeThatFits:CGSizeMake(MESSAGE_MAX_WIDTH - 2*MESSAGE_BACKGROUND_SPACE, MAIL_TITLE_MAX_HEIGHT)];
    CGFloat mailTitleHeight          = mailTitleSize.height > MAIL_TITLE_MAX_HEIGHT ? MAIL_TITLE_MAX_HEIGHT : mailTitleSize.height;
    // 邮件标题要到底的最大位置
    CGFloat mailTitleMaxY            = mailTitleHeight + self.mailTips.mj_h + self.mailTips.mj_y + 4;
    // 邮件标题的高度不能大于最大高度
    mailTitleMaxY                    = mailTitleMaxY > MAIL_TITLE_MAX_HEIGHT + MESSAGE_BACKGROUND_SPACE + 16 + 4 ? MAIL_TITLE_MAX_HEIGHT + MESSAGE_BACKGROUND_SPACE + 16 + 4 : mailTitleMaxY;

    // 邮件标题位置
    self.mailTitle.frame             = CGRectMake(MESSAGE_BACKGROUND_SPACE, self.mailTips.mj_h + self.mailTips.mj_y + 4, mailTitleSize.width, mailTitleHeight);

    // 附件的高度 + 附件与邮件详情的间隔
    CGFloat mailAttachHeightAddSpace = self.messageModel.attach == 0 ? 0 : MAIL_ATTACHMENT_HEIGHT;
    CGFloat mailDetailMaxY           = 0;
    if (self.messageModel.direction == KMessageSenderTypeReceiver) {
        // 邮件详情要到达的最大位置 及底部Y
        mailDetailMaxY               = self.messageBackgroundImageView.mj_h - (40 + 8 + mailAttachHeightAddSpace);
    }
    else
    {
        CGFloat bottomHeight         = self.selfSenderMailShowReply ? 40+5 : 0;
        mailDetailMaxY               = self.messageBackgroundImageView.mj_h - mailAttachHeightAddSpace - bottomHeight - 15;
    }
    // 显示邮箱标题、邮件提示（云邮）、附件、和底部试图后 剩余的高度
    CGFloat residueHeight            = mailDetailMaxY - mailTitleMaxY - 4;

    CGSize mailDetailSize            = [self.mailDetail sizeThatFits:CGSizeMake(MESSAGE_MAX_WIDTH - 2*MESSAGE_BACKGROUND_SPACE, MAXFLOAT)];
    // 邮件详情的高度会随着邮件标题的长短而被压缩，所以当压缩有至少有20的高度显示邮件详情简介，如果mailTitle的高度比较小，则邮件详情放大
    CGFloat mailDetailHeight         = mailDetailSize.height > residueHeight ? residueHeight : mailDetailSize.height;
    mailDetailHeight                 = mailDetailHeight <= 20 ? 20 : mailDetailHeight;

    self.mailDetail.frame            = CGRectMake(MESSAGE_BACKGROUND_SPACE, self.mailTitle.mj_y + self.mailTitle.mj_h + 5, mailDetailSize.width, mailDetailHeight);
    
    // 附件Y距离底部的距离
    CGFloat attachmenYSpaceBottom    = 0;
    if (self.messageModel.attach == 0) {
        [self.attachment setHidden:YES];
        // 附件Y距离底部的距离
        attachmenYSpaceBottom        = MAIL_ATTACHMENT_HEIGHT + 5;
    }
    else
    {
        [self.attachment setHidden:NO];
        
        if (self.messageModel.direction == KMessageSenderTypeReceiver) {
            // 附件Y距离底部的距离
            attachmenYSpaceBottom    = MAIL_ATTACHMENT_HEIGHT + 40 + 5;
        }
        else
        {
            attachmenYSpaceBottom    = (SELF_SENDER_MAIL_SHOW_REPLY || self.selfSenderMailShowReply) ? MAIL_ATTACHMENT_HEIGHT + 40 + 5 : MAIL_ATTACHMENT_HEIGHT + 5;
        }
    }

    // 附件位置
    self.attachment.frame            = CGRectMake(MESSAGE_BACKGROUND_SPACE, self.messageBackgroundImageView.mj_h - attachmenYSpaceBottom, self.mailDetail.mj_w, MAIL_ATTACHMENT_HEIGHT);

    // 底部横线
    self.horizontalLine.frame    = CGRectMake(0, self.messageBackgroundImageView.mj_h - 40, self.messageBackgroundImageView.mj_w, 1);
    // 回复按钮位置
    self.reply.frame             = CGRectMake(MESSAGE_BACKGROUND_SPACE/2., self.horizontalLine.mj_y + self.horizontalLine.mj_h + MESSAGE_BACKGROUND_SPACE/2., MESSAGE_MAX_WIDTH/3. - 2*MESSAGE_BACKGROUND_SPACE, 30);
    // 回复全部按钮位置
    self.replyAll.frame          = CGRectMake(self.reply.mj_x + self.reply.mj_w + 10 + 1, self.reply.mj_y, MESSAGE_MAX_WIDTH/3. + 20 - 2 * MESSAGE_BACKGROUND_SPACE/2., 30);
    // 转发按钮位置
    self.transmit.frame          = CGRectMake(self.replyAll.mj_x + self.replyAll.mj_w + 10, self.replyAll.mj_y, MESSAGE_MAX_WIDTH/3. - 2*MESSAGE_BACKGROUND_SPACE, 30);

    // 第一根竖线位置
    self.firstLine.frame         = CGRectMake(MESSAGE_MAX_WIDTH/3 - 0.5 - 10, self.horizontalLine.mj_y + self.horizontalLine.mj_h + 5, 1, 30);
    // 第二根竖线
    self.secondeLine.frame       = CGRectMake(2*MESSAGE_MAX_WIDTH/3 - 0.5 + 10, self.firstLine.mj_y, 1, 30);
}

- (void)showBottomView {
    [_firstLine      setHidden:NO];
    [_horizontalLine setHidden:NO];
    [_secondeLine    setHidden:NO];
    [_reply          setHidden:NO];
    [_replyAll       setHidden:NO];
    [_transmit       setHidden:NO];
    [_attachment     setHidden:NO];
}

- (void)dismissBottomView {
    [_firstLine      setHidden:YES];
    [_horizontalLine setHidden:YES];
    [_secondeLine    setHidden:YES];
    [_reply          setHidden:YES];
    [_replyAll       setHidden:YES];
    [_transmit       setHidden:YES];
}

- (void)setBottomButtonColor
{
    if (self.selfSenderMailShowReply || SELF_SENDER_MAIL_SHOW_REPLY)
    {
        [self.reply    setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.replyAll setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.transmit setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.reply    setTitleColor:MAIL_DETAIL_TEXTCOLOR forState:UIControlStateNormal];
        [self.replyAll setTitleColor:MAIL_DETAIL_TEXTCOLOR forState:UIControlStateNormal];
        [self.transmit setTitleColor:MAIL_DETAIL_TEXTCOLOR forState:UIControlStateNormal];
        
    }
}

- (void)updateMessageSendState:(KMessageSendStatus)sendState jsonStr:(NSString *)jsonStr localMessageId:(NSString *)messageId {
    [super updateMessageSendState:sendState jsonStr:jsonStr localMessageId:messageId];
}

- (void)setMessageModel:(KMessageModel *)messageModel
{
    [super setMessageModel:messageModel];
    self.selfSenderMailShowReply             = messageModel.selfSenderMailShowReply;
    [self setBottomButtonColor];
    self.mailTips.text                       = @"云邮";
    self.mailTitle.attributedText            = [[NSAttributedString alloc] initWithString:messageModel.subject];
    NSString *contentSynopsis                = messageModel.contentSynopsis ? messageModel.contentSynopsis  : @"";
    self.mailDetail.attributedText           = [[NSAttributedString alloc] initWithString:contentSynopsis];
    self.messageSize                         = messageModel.messageSize;
    
    if (messageModel.direction == KMessageSenderTypeSender) {
        self.mailTips.textColor              = MAIL_DETAIL_TEXTCOLOR_SENDER;
        self.mailDetail.textColor            = MAIL_DETAIL_TEXTCOLOR_SENDER;
        self.mailTitle.textColor             = MAIL_TITLE_TEXTCOLOR;
        self.horizontalLine.backgroundColor  = [UIColor lightGrayColor];
        self.firstLine.backgroundColor       = [UIColor lightGrayColor];
        self.secondeLine.backgroundColor     = [UIColor lightGrayColor];
    }
    else
    {
        self.mailTips.textColor              = MAIL_DETAIL_TEXTCOLOR;
        self.mailDetail.textColor            = MAIL_DETAIL_TEXTCOLOR;
        self.mailTitle.textColor             = MAIL_TITLE_TEXTCOLOR;
        self.horizontalLine.backgroundColor  = [ColorTools colorWithHexString:@"0xececec"];
        self.firstLine.backgroundColor       = [ColorTools colorWithHexString:@"0xececec"];
        self.secondeLine.backgroundColor     = [ColorTools colorWithHexString:@"0xececec"];
    }

    // 显示的图片
    UIImage *image                           = [UIImage imageNamed:@"icon_message_attachments"];
    NSTextAttachment *textAttach             = [NSTextAttachment new];
    textAttach.image                         = image;
    NSAttributedString *attachment           = [NSAttributedString attributedStringWithAttachment:textAttach];
    // 数字长度
    NSString *attachCount                    = [NSString stringWithFormat:@"%lu", (unsigned long)messageModel.attach];
    // 需要先的文字
    NSString *attch                          = [NSString stringWithFormat:@" 附件( %@ )个", attachCount];
    NSMutableAttributedString *attachmentAtt = [[NSMutableAttributedString alloc] initWithString:attch];
    // 设置"(数字)"颜色
    UIColor *color = messageModel.direction == KMessageSenderTypeSender ? MAIL_DETAIL_TEXTCOLOR_SENDER : MAIL_DETAIL_TEXTCOLOR;
    [attachmentAtt addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attch.length)];
    [attachmentAtt addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3, attachCount.length + 4)];
    
    [attachmentAtt insertAttributedString:attachment atIndex:0];
    [self.attachment setAttributedText:attachmentAtt];
}

// 回复邮件
- (void)replyAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:replyMailMessageModel:)]) {
        [self.delegate chatTableViewCell:self replyMailMessageModel:self.messageModel];
    }
}

// 回复全部
- (void)replyAllAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:replyAllMaillMessageModel:)]) {
        [self.delegate chatTableViewCell:self replyAllMaillMessageModel:self.messageModel];
    }
}

// 转发邮件 
- (void)transmitAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTableViewCell:transmitMailMessageModel:)]) {
        [self.delegate chatTableViewCell:self transmitMailMessageModel:self.messageModel];
    }
}

// 云邮标签
- (UILabel *)mailTips {
    if (!_mailTips) {
        _mailTips           = [UILabel new];
        _mailTips.textColor = MAIL_DETAIL_TEXTCOLOR;
        _mailTips.font      = [UIFont systemFontOfSize:12];
    }
    return _mailTips;
}

// 邮件标题
- (UILabel *)mailTitle {
    if (!_mailTitle) {
        _mailTitle               = [UILabel new];
        _mailTitle.textColor     = MAIL_TITLE_TEXTCOLOR;
        _mailTitle.font          = [UIFont systemFontOfSize:CHAT_MESSAGE_FONT];
        _mailTitle.numberOfLines = 0;
    }
    return _mailTitle;
}

// 邮件详情
- (UILabel *)mailDetail {
    if (!_mailDetail) {
        _mailDetail               = [UILabel new];
        _mailDetail.textColor     = MAIL_DETAIL_TEXTCOLOR;
        _mailDetail.font          = [UIFont systemFontOfSize:MAIL_DETAIL_FONT];
        _mailDetail.numberOfLines = 0;
    }
    return _mailDetail;
}

// 附件
- (UILabel *)attachment {
    if (!_attachment) {
        _attachment           = [UILabel new];
        _attachment.textColor = MAIL_DETAIL_TEXTCOLOR;
        _attachment.font      = [UIFont systemFontOfSize:MAIL_DETAIL_FONT];
        [_attachment setHidden:YES];
    }
    return _attachment;
}

// 回复按钮
- (UIButton *)reply {
    if (!_reply) {
        _reply                 = [UIButton new];
        [_reply setTitle:@"回复" forState:UIControlStateNormal];
        [_reply setTitleColor:MAIL_DETAIL_TEXTCOLOR forState:UIControlStateNormal];
        _reply.titleLabel.font = [UIFont systemFontOfSize:MAIL_DETAIL_FONT];
        [_reply setHidden:YES];

        [_reply addTarget:self action:@selector(replyAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reply;
}

// 回复全部按钮
- (UIButton *)replyAll {
    if (!_replyAll) {
        _replyAll                 = [UIButton new];
        [_replyAll setTitle:@"回复全部" forState:UIControlStateNormal];
        [_replyAll setTitleColor:MAIL_DETAIL_TEXTCOLOR forState:UIControlStateNormal];
        _replyAll.titleLabel.font = [UIFont systemFontOfSize:MAIL_DETAIL_FONT];
        [_replyAll setHidden:YES];

        [_replyAll addTarget:self action:@selector(replyAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _replyAll;
}

// 转发按钮
- (UIButton *)transmit {
    if (!_transmit) {
        _transmit                 = [UIButton new];
        [_transmit setTitle:@"转发" forState:UIControlStateNormal];
        [_transmit setTitleColor:MAIL_DETAIL_TEXTCOLOR forState:UIControlStateNormal];
        _transmit.titleLabel.font = [UIFont systemFontOfSize:MAIL_DETAIL_FONT];
        [_transmit setHidden:YES];

        [_transmit addTarget:self action:@selector(transmitAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _transmit;
}

@end
