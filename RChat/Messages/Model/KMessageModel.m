//
//  KMessageModel.m
//  KXiniuCloud
//
//  Created by eims on 2018/4/24.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KMessageModel.h"

#import "UIImage+KVideo.h"
#import "NSDate+KCategory.h"
#import "NSString+Size.h"
#import <SDWebImageManager.h>

#import "KChatMessageHelper.h"

@implementation KMessageModel

- (instancetype)init {
    
    _cellHeight  = -1;
    _messageSize = CGSizeMake(-1, -1);
    
    return [super init];
    
}

- (void)setMessageAtt:(NSAttributedString *)messageAtt {
    _messageAtt = [KChatMessageHelper formatMessageAtt:messageAtt];
}

- (void)setContent:(id)content {
    _content = content;
    if ([content isKindOfClass:[NSString class]]) {
        _messageAtt = [KChatMessageHelper formatMessageString:content];
    }
}

- (void)setmsgType:(KMessageType)msgType
{
    _msgType = msgType;
    if (msgType == KMessageTypeVoice && self.recvTime == 0) {
        _cellHeight = 60;
    }
}

- (void)setSelfSenderMailShowReply:(BOOL)selfSenderMailShowReply
{
    _selfSenderMailShowReply = selfSenderMailShowReply;
    
    if (selfSenderMailShowReply) {
        _messageSize = CGSizeMake(_messageSize.width, _messageSize.height + 40);
        _cellHeight = _cellHeight + 40;
    }
}

- (NSString *)contentSynopsis {
    if (!_contentSynopsis) {
        return @"";
    }
    return _contentSynopsis;
}

- (NSString *)cellIdendtifier
{
    switch (_msgType) {
        case KMessageTypeNone:
            return @"";
            break;
        case KMessageTypeText:
            return @"KChatTextTableViewCell";
            break;
        case KMessageTypeMail:
            return @"KChatMailTableViewCell";
            break;
        case KMessageTypeVoice:
            return @"KChatVoiceTableViewCell";
            break;
        case KMessageTypeImage:
            return @"KChatImageTableViewCell";
            break;
        case KMessageTypeVideo:
            return @"KChatVideoTableViewCell";
            break;
        case KMessageTypeFile:
            return @"";
            break;
        case KMessageTypeLocation:
            return @"";
            break;
        case KMessageTypeCard:
            return @"";
            break;
            
        default:
            break;
    }
}


/**
 消息处理
 主要是计算视图高度，
 优化重复计算高度问题，
 把高度计算从加载时提前到赋值时
 */
- (void)messageProcessingWithFinishedCalculate:(FinishedRowHeightCalculate)finishedCalculate
{
    if (_cellHeight == -1 || _messageSize.width == -1 || _messageSize.height == -1)
    {
        _cellHeight = 0;
        if (_msgType != KMessageTypeNone)
        {
            kWeakSelf;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                __block CGSize messageSize = CGSizeZero;
                
                switch (self.msgType)
                {
                    case KMessageTypeText:
                    {
                        if ((!weakSelf.messageAtt || weakSelf.messageAtt.length == 0) && weakSelf.content) {
                            weakSelf.messageAtt = [KChatMessageHelper formatMessageString:weakSelf.content];
                        }
                        
                        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin;
                        messageSize = [weakSelf.messageAtt boundingRectWithSize:CGSizeMake(ceil(MESSAGE_MAX_WIDTH)-10, MAXFLOAT) options:options context:nil].size;
                        weakSelf.messageSize = CGSizeMake(ceil(messageSize.width) + 10, ceil(messageSize.height) + 16);
                        
                        weakSelf.cellHeight = MAX(weakSelf.messageSize.height, 40) + weakSelf.cellHeight;
                        weakSelf.cellHeight = weakSelf.cellHeight + MESSAGE_BACKGROUND_SPACE * 2;
                        if (weakSelf.direction == KMessageSenderTypeReceiver && weakSelf.showUsername) {
                            weakSelf.cellHeight = weakSelf.cellHeight + USERNAME_HEIGHT;
                        }
                        
                        [weakSelf updateDatabaseMessageHeightAndWidthWithRowHeight:weakSelf.cellHeight];
                    }
                        break;
                    case KMessageTypeMail:
                    {
                        [weakSelf mailHeight];
                    }
                        break;
                    case KMessageTypeVoice:
                    {
                        CGFloat rowHeight = AVATAR_WIDTH + 2 * AVATAR_SCREEN_SPACE;
                        if (weakSelf.direction == KMessageSenderTypeReceiver && weakSelf.showUsername)
                        {
                            rowHeight = rowHeight + USERNAME_HEIGHT;
                        }
                        
                        weakSelf.cellHeight = rowHeight;
                        [weakSelf updateDatabaseMessageHeightAndWidthWithRowHeight:rowHeight];
                    }
                        break;
                        
                    case KMessageTypeImage:
                    {
                        __block UIImage *image;
                        if (weakSelf.fileData) {
                            image = [UIImage imageWithData:weakSelf.fileData];
                            [weakSelf photoHeightWithImageWidth:image.size.width imageHeight:image.size.height complete:finishedCalculate];
                            return;
                        }
                        NSString *path = _content;
                        if ([path containsString:@"storage/msgs"]) {
                            NSString *imagePath = [kDocDir stringByAppendingPathComponent:path];
                            image               = [UIImage imageWithContentsOfFile:imagePath];
                            weakSelf.fileData   = UIImagePNGRepresentation(image);
                            [weakSelf photoHeightWithImageWidth:image.size.width imageHeight:image.size.height complete:finishedCalculate];
                            return;
                        }
                        else {
                            if ([path containsString:@"http://"] || [path containsString:@"https://"]) {
                                
//                                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_content] options:0 progress:nil completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                    if (!error) {
//                                        [weakSelf photoHeightWithImageWidth:image1.size.width imageHeight:image1.size.height complete:finishedCalculate];
//                                    }
//                                }];
                                return;
                            }
                        }
                    }
                        break;
                    case KMessageTypeVideo:
                    {
                        NSURL *url = [NSURL URLWithString:weakSelf.content];
                        weakSelf.fileData = UIImagePNGRepresentation([UIImage imageWithVideo:url]);
                        
                        UIImage *image = [UIImage imageWithData:weakSelf.fileData];
                        CGFloat imageWidth  = image.size.width;
                        CGFloat imageHeight = image.size.height;
                        if (imageWidth > imageHeight) {
                            // H : W = 16 : 9;
                            CGFloat width  = 180;
                            CGFloat height = width * 9 / 16.f;
                            messageSize = CGSizeMake(width, height);
                        }
                        else {
                            // H : W = 16 : 9
                            CGFloat height = 180;
                            CGFloat width  = height * 9 / 16.f;
                            messageSize = CGSizeMake(width, height);
                        }
                        weakSelf.messageSize = messageSize;
                        CGFloat rowHeight = messageSize.height + MESSAGE_BACKGROUND_SPACE * 2;
                        if (weakSelf.direction == KMessageSenderTypeReceiver && weakSelf.showUsername) {
                            rowHeight = rowHeight + USERNAME_HEIGHT;
                        }
                        weakSelf.cellHeight = rowHeight;
                        
                        [weakSelf updateDatabaseMessageHeightAndWidthWithRowHeight:rowHeight];
                    }
                        break;
                        
                    default:
                    {
                        weakSelf.messageSize = CGSizeZero;
                        weakSelf.cellHeight  = 0;
                    }
                        break;
                }
                
                CGFloat height = weakSelf.cellHeight;
                if (finishedCalculate) {
                    if (weakSelf.showMessageTime) {
                        weakSelf.cellHeight += SHOW_MESSAGE_TIME_HEIGHT;
                    }
                    finishedCalculate(weakSelf.cellHeight, weakSelf.messageSize, YES);
                }
                
                if (weakSelf.messageId) {
                    // 通知聊天界面刷新这个消息
                    if (weakSelf.showMessageTime) {
                        height += SHOW_MESSAGE_TIME_HEIGHT;
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRowHeight" object:nil userInfo:@{@"messageId":weakSelf.messageId, @"cellHeight":@(height), @"messageSize":@(_messageSize)}];
                }
                
            });
        }
    }
    else {
        if (finishedCalculate) {
            if (_showMessageTime && !_updatedRowHeight) {
                _cellHeight += SHOW_MESSAGE_TIME_HEIGHT;
            }
            finishedCalculate(_cellHeight, _messageSize, YES);
        }
    }
}

- (void)updateDatabaseMessageHeightAndWidthWithRowHeight:(CGFloat)rowHeight
{
    if (_messageId)
    {
//        NSLog(@"content:%@   rowHeight:%@", _content,rowHeight);
//        [KInteractionWrapper updateMessageWithMessageId:_messageId cellHeight:rowHeight messageWidth:_messageSize.width messageHeight:_messageSize.height block:^(id obj, int errorCode, NSString *errorMsg) {
//            if (errorCode) {
//                NSLog(@"更新行高失败");
//            }
//        }];
    }
}

- (void)mailHeight
{
    CGSize messageSize;
    
    if (_subject || _contentSynopsis.length > 0) {
        // 最顶部的16 + 4 + mailTitle高度 + 4 + mailDetail高度 + 5 + 附件高度(MAIL_ATTACHMENT_HEIGHT) + 5 +底部高度（40）
        CGFloat mailHeight    = 16 + 4 + 0 + 4 + 0 + 5 + MAIL_ATTACHMENT_HEIGHT + 5 + 40;
        CGFloat mailWidth     = MESSAGE_MAX_WIDTH - 2*MESSAGE_BACKGROUND_SPACE;
        CGSize mailTitleSize  = [self.subject kSizeWithFont:[UIFont systemFontOfSize:CHAT_MESSAGE_FONT] constrainedToSize:CGSizeMake(mailWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        // + 内容和标题之间的间隙
        mailHeight            = mailHeight + ceil(mailTitleSize.height) + 10;
        
        CGSize mailDetailSize = [self.contentSynopsis kSizeWithFont:[UIFont systemFontOfSize:MAIL_DETAIL_FONT] constrainedToSize:CGSizeMake(MESSAGE_MAX_WIDTH - 2*MESSAGE_BACKGROUND_SPACE, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        mailHeight = mailHeight + mailDetailSize.height;
        // 加上顶部间隔（10）+ 顶部消息与消息背景的间隔（10）+ 加上底部间隔（10）+ 底部消息与消息背景的间隔（10）
        mailHeight = mailHeight + MESSAGE_BACKGROUND_SPACE * 4;
        if (self.attach == 0) {
            // 没有附件 则mailHeight = mailHeight - 附件高度（MAIL_ATTACHMENT_HEIGHT）- 附件与邮件详情简介的间隔（10）
            mailHeight = mailHeight - MAIL_ATTACHMENT_HEIGHT - 8;
        }
        
        if (self.direction == KMessageSenderTypeReceiver) {
            mailHeight -= 10;
            mailHeight = mailHeight > RECEIVE_MAIL_MAX_ROW_HEIGHT ? RECEIVE_MAIL_MAX_ROW_HEIGHT : mailHeight;
        }
        else
        {
            // 去掉底部“回复”、“回复全部”和“转发”试图的高度
            mailHeight = self.selfSenderMailShowReply ? mailHeight : mailHeight - 40;
            CGFloat thresholdValue = self.selfSenderMailShowReply ? RECEIVE_MAIL_MAX_ROW_HEIGHT : SENDER_MAIL_MAX_ROW_HEIGHT;
            mailHeight = mailHeight > thresholdValue ? thresholdValue : mailHeight;
        }
        
        if (self.showUsername && self.direction == KMessageSenderTypeReceiver) {
            mailHeight = mailHeight + USERNAME_HEIGHT;
        }
        messageSize  = CGSizeMake(mailWidth, mailHeight);
        _messageSize = messageSize;
        _cellHeight  = messageSize.height;
        
        [self updateDatabaseMessageHeightAndWidthWithRowHeight:messageSize.height];
    }
    
}

/**
 辅助计算网络图片消息行高
 
 @param imageWidth 图片宽
 @param imageHeight 图片高
 @param complete 高度计算完成回调
 */
- (void)photoHeightWithImageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight complete:(FinishedRowHeightCalculate)complete {
    
    CGSize messageSize;
    if (imageWidth > imageHeight)
    {
        if (imageWidth/2. > 180) {
            CGFloat width  = 180;
            CGFloat height = width * 9 / 16.f;
            messageSize    = CGSizeMake(width, height);
        }
        else {
            messageSize = CGSizeMake(imageWidth/2., imageHeight/2.);
        }
    }
    else
    {
        if (imageHeight/2. > 180) {
            CGFloat height = 180;
            CGFloat width  = height * 9 / 16.f;
            messageSize    = CGSizeMake(width, height);
        }
        else {
            messageSize = CGSizeMake(imageWidth/2., imageHeight/2.);
        }
    }
    
    _messageSize = messageSize;
    CGFloat rowHeight = messageSize.height + MESSAGE_BACKGROUND_SPACE * 2;
    if (self.direction == KMessageSenderTypeReceiver && self.showUsername) {
        rowHeight = rowHeight + USERNAME_HEIGHT;
    }
    
    _cellHeight = rowHeight;

    [self updateDatabaseMessageHeightAndWidthWithRowHeight:rowHeight];
    CGFloat height = _cellHeight;
    if (_showMessageTime) {
        height += SHOW_MESSAGE_TIME_HEIGHT;
    }
    // 通知聊天界面刷新这个消息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRowHeight" object:nil userInfo:@{@"messageId":self.messageId, @"cellHeight":@(height), @"messageSize":@(_messageSize)}];
    
    if (complete) {
        
        if (_showMessageTime && !_updatedRowHeight) {
            _cellHeight += SHOW_MESSAGE_TIME_HEIGHT;
        }
        complete(_cellHeight, messageSize, YES);
    }
}

@end
