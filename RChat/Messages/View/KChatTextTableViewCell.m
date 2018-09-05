//
//  KChatTextTableViewCell.m
//  KXiniuCloud
//
//  Created by eims on 2018/4/25.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KChatTextTableViewCell.h"


#import "KTextView.h"
#import "KMessageModel.h"


@interface KChatTextTableViewCell()<UITextViewDelegate, UITextDragDelegate>
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end

@implementation KChatTextTableViewCell

/// 文本聊天信息
- (KTextView *)textView
{
    if (!_textView)
    {
        _textView                  = [[KTextView alloc] init];
        _textView.backgroundColor  = [UIColor clearColor];
        _textView.font             = [UIFont systemFontOfSize:CHAT_MESSAGE_FONT];
        _textView.textColor        = CHAT_MESSAGE_TEXTCOLOR;
        _textView.editable         = NO;
        _textView.scrollEnabled    = NO;
        _textView.delegate         = self;
        _textView.isInputBox       = NO;
        NSString *version= [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 11) {
            _textView.textDragDelegate = self;
        }
        
    }
    
    return _textView;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.messageBackgroundImageView addSubview:self.textView];
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [self.messageBackgroundImageView addGestureRecognizer:self.longPress];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float x       = 0;
    float originY = 0;
    float width = MAX(self.textView.mj_w + MESSAGE_BACKGROUND_SPACE, 40);
    if (self.messageModel.direction == KMessageSenderTypeReceiver) {
        x = self.avatarImageView.kMax_x + MESSAGE_BACKGROUND_SPACE + MESSAGE_BACKGROUND_SPACE/2.;
        originY   = self.messageModel.showUsername ? self.username.mj_h + self.username.mj_y + 4 : self.username.mj_h + self.username.mj_y;
        self.messageSendStatusImageView.hidden = YES;
    }
    else
    {
        x = self.avatarImageView.mj_x - width - MESSAGE_BACKGROUND_SPACE ;
        originY   = self.username.mj_h + self.username.mj_y;
        self.messageSendStatusImageView.hidden = self.messageModel.messageSendStatus == KMessageSendStatusSendSuccess;
    }
    
    float height  = MAX(self.textView.mj_h, self.avatarImageView.mj_h);
    [self.messageBackgroundImageView setFrame:CGRectMake(x, originY, width, height)];
    
    CGFloat y = (self.messageBackgroundImageView.mj_h - self.textView.mj_h)/ 2.;
    [self.textView setOrigin:CGPointMake(5, y)];
    if (self.messageModel.direction == KMessageSenderTypeSender)
    {
        self.messageSendStatusImageView.frame = CGRectMake(self.messageBackgroundImageView.mj_x - MESSAGE_BACKGROUND_SPACE/2 - 20, self.messageBackgroundImageView.kMax_y - 20 - 5, 20, 20);
        self.messageSendStatusImageView.center = CGPointMake(self.messageBackgroundImageView.mj_x - MESSAGE_BACKGROUND_SPACE/2 - 10, self.messageBackgroundImageView.center.y);
    }
}


- (void)setMessageModel:(KMessageModel *)messageModel {
    [super setMessageModel:messageModel];
    
    [_textView setAttributedText:messageModel.messageAtt];
    _textView.size = [messageModel messageSize];
}

- (void)updateMessageSendState:(KMessageSendStatus)sendState jsonStr:(NSString *)jsonStr localMessageId:(NSString *)messageId {
    [super updateMessageSendState:sendState jsonStr:jsonStr localMessageId:messageId];
}

- (void)longPressAction:(id)longPress {
    [UIMenuController sharedMenuController].menuVisible = YES;
    //    [self.textView selectAll:nil];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    textView.selectedRange = characterRange;
    return NO;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (textView.selectedRange.length > 0)
    {
        // 选择了文字
        NSDictionary *dic = @{@"row":@(self.indexPath.row), @"change":@(YES)};
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"changeSelection"];
    }
}

// 解决附件可以拖拽的问题
- (NSArray<UIDragItem *> *)textDraggableView:(UIView<UITextDraggable> *)textDraggableView itemsForDrag:(id<UITextDragRequest>)dragRequest  API_AVAILABLE(ios(11.0)) {
    return @[];
}

@end
