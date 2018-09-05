//
//  KMessagesListTableViewCell.m
//  KXiniuCloud
//
//  Created by RPK on 2018/4/17.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KMessagesListTableViewCell.h"


#import "KMessageModel.h"
#import "NSDate+KCategory.h"
#import "KConversationModel.h"
#import "UILabel+KAutoLabelHeightAndWidth.h"

@interface KMessagesListTableViewCell ()

@end

@implementation KMessagesListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    _avaterImageView                   = [UIImageView new];
    CGRect rect                        = CGRectMake(0, 0, 50, 50);
    // 贝塞尔曲线绘制圆角
    UIBezierPath *maskPath             = [UIBezierPath bezierPathWithRoundedRect:rect  byRoundingCorners:UIRectCornerAllCorners  cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer            = [CAShapeLayer layer];
    maskLayer.path                     = maskPath.CGPath;
    _avaterImageView.layer.mask        = maskLayer;
    [self addSubview:_avaterImageView];

    _avaterImageView.sd_layout.topSpaceToView(self, 10).leftSpaceToView(self, 10).widthIs(50).heightEqualToWidth();

    _updateTime                        = [UILabel new];
    _updateTime.textColor              = [UIColor lightGrayColor];
    _updateTime.font                   = [UIFont systemFontOfSize:12];
    _updateTime.textAlignment          = NSTextAlignmentRight;
    [self addSubview:_updateTime];

    _updateTime.sd_layout.topSpaceToView(self, 17).rightSpaceToView(self, 10).heightIs(14).widthIs(0);

    _titleLabel                        = [UILabel new];
    _titleLabel.font                   = [UIFont systemFontOfSize:16];
    _titleLabel.textColor              = [UIColor blackColor];
    [self addSubview:_titleLabel];

    _titleLabel.sd_layout.topSpaceToView(self, 14).leftSpaceToView(_avaterImageView, 10).rightSpaceToView(_updateTime, 10).heightIs(20);

    _badgeNumber                       = [UILabel new];
    _badgeNumber.layer.cornerRadius    = 9;
    _badgeNumber.layer.masksToBounds   = YES;
    _badgeNumber.layer.backgroundColor = [UIColor redColor].CGColor;
    _badgeNumber.textColor             = [UIColor whiteColor];
    _badgeNumber.textAlignment         = NSTextAlignmentCenter;
    _badgeNumber.font                  = [UIFont systemFontOfSize:12];
    [self addSubview:_badgeNumber];

    _badgeNumber.sd_layout.topSpaceToView(_titleLabel, 6).rightSpaceToView(self, 10).heightIs(18).widthIs(0);

    _messageLabel                      = [UILabel new];
    _messageLabel.font                 = [UIFont systemFontOfSize:14];
    _messageLabel.textColor            = [UIColor lightGrayColor];
    [self addSubview:_messageLabel];

    _messageLabel.sd_layout.topSpaceToView(_titleLabel, 6).leftSpaceToView(_avaterImageView, 10).rightSpaceToView(_badgeNumber, 20).heightIs(18);
    
}

- (void)setConversation:(KConversationModel *)conversation
{
    
    if (conversation.chatType == KMessageChatTypeFTP)
    {
        _avaterImageView.image = [UIImage imageNamed:@"helper"];
    }
    else
    {
        if (!conversation.headImage || conversation.headImage.length == 0)
        {
            _avaterImageView.image = kDefaultHeadPortrait;
        }
        else if ([conversation.headImage containsString:@"storage/headImage"]) {
            NSString *imagePath = [kDocDir stringByAppendingPathComponent:conversation.headImage];
            _avaterImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        }
        else if ([conversation.headImage containsString:@"http://"] || [conversation.headImage containsString:@"https://"])
        {
            [_avaterImageView sd_setImageWithURL:[NSURL URLWithString:conversation.headImage]];
        }
    }

    _titleLabel.text = conversation.conversationName;
    if ((!conversation.conversationName || conversation.conversationName.length == 0) && [conversation.toUserId isEqualToString:KXINIUID]) {
        _titleLabel.text = [[KAppDefaultUtil sharedInstance] getUserName];
    }
    
    _messageLabel.text = conversation.message.content;
    if (conversation.message.messageSendStatus == KMessageSendStatusSendFailure && conversation.message.recvTime.length) {
        _messageLabel.text = @"";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        
        NSTextAttachment *textAttach = [[NSTextAttachment alloc] init];
        textAttach.image = [UIImage imageNamed:@"icon_message_send_failure"];
        textAttach.bounds = CGRectMake(0, -2, 16, 16);
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttach];
        [attributedString appendAttributedString:imageStr];
        // 内容前面加两个空格
        NSString *content = [NSString stringWithFormat:@" %@",conversation.message.content];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:content]];
        _messageLabel.attributedText = attributedString;
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSInteger timeInterval = [conversation.message.recvTime integerValue];
    _updateTime.text   = [NSDate conversationTimeWithRecvTime:timeInterval];
    
    CGFloat timeWidth  = [UILabel getWidthWithTitle:_updateTime.text
                                               font:_updateTime.font];
    _updateTime.sd_layout.widthIs(timeWidth);
    
    if (conversation.badgeNumber == 0)
    {
        _badgeNumber.text = @"";
        _badgeNumber.sd_layout.widthIs(0);
    }
    else
    {
        NSString *unreadNum = @"";
        if (conversation.badgeNumber <= 99)
        {
            unreadNum = [NSString stringWithFormat:@"%d", conversation.badgeNumber];
        }
        else
        {
            unreadNum = @"...";
        }
        _badgeNumber.text  = unreadNum;
        CGFloat badgeWidth = [UILabel getWidthWithTitle:_badgeNumber.text font:_badgeNumber.font];
        badgeWidth = badgeWidth > 18 ? badgeWidth : 18;
        _badgeNumber.sd_layout.widthIs(badgeWidth);
    }
    [_badgeNumber updateLayout];

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
