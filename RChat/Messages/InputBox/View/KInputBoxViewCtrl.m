//
//  KInputBoxViewCtrl.m
//  KXiniuCloud
//
//  Created by eims on 2018/4/27.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KInputBoxViewCtrl.h"

#import <SDWebImage/UIImage+GIF.h>
#import <AVFoundation/AVFoundation.h>

#import "KTextView.h"
#import "KEmojiModel.h"
#import "KInputBoxView.h"
#import "NSDate+KCategory.h"
#import "KInputBoxMoreView.h"
#import "KInputBoxEmojiView.h"
#import "NSTextAttachment+Emoji.h"


@interface KInputBoxViewCtrl () <KInputBoxViewDelegate>

// 文本消息
@property (nonatomic, strong) NSString *textMessage;

@property (nonatomic, assign) CGFloat  inputBoxHeight;

@property (nonatomic, assign) CGRect   keyboardFrame;

@end

@implementation KInputBoxViewCtrl

#pragma mark 懒加载
- (KInputBoxEmojiView *)emojiView {
    if (!_emojiView) {
        _emojiView = [[KInputBoxEmojiView alloc] initWithFrame:CGRectMake(0, self.inputBox.kMax_y, MSWIDTH, INPUT_BOX_EMOJI_VIEW_HEIGHT)];
        _emojiView.delegate = self;
    }
    return _emojiView;
}

- (KInputBoxMoreView *)moreView {
    if (!_moreView) {
        _moreView = [[KInputBoxMoreView alloc] initWithFrame:CGRectMake(0, self.inputBox.kMax_y, MSWIDTH, INPUT_BOX_MORE_VIEW_HEIGHT)];
    }
    return _moreView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    self.backgroundColor = [ColorTools colorWithHexString:@"0xeeeeee"];
    
    self.inputBox = [[KInputBoxView alloc] initWithFrame:CGRectMake(0, 0, MSWIDTH, 50)];
    self.inputBox.delegate = self;
    [self addSubview:self.inputBox];
    [self moreView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 键盘的Frame值即将发生变化的时候创建的额监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedMoreView:) name:@"KInputBoxDidSelectedMoreView" object:nil];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.inputBox.mj_h = self.inputBox.curHeight;
    if (self.inputBox.inputBoxStatus == KInputBoxStatusShowEmoji) {
        self.emojiView.mj_y = self.inputBox.curHeight;
    }
    else if (self.inputBox.inputBoxStatus == KInputBoxStatusShowMore) {
        self.moreView.mj_y = self.inputBox.curHeight;
    }
}

- (BOOL)resignFirstResponder {

    if (self.inputBox.inputBoxStatus != KInputBoxStatusShowVoice) {
        self.inputBox.inputBoxStatus = KInputBoxStatusNone;
    }
    
    [self.inputBox resignFirstResponder];
    [self.emojiView removeFromSuperview];
    [self.moreView removeFromSuperview];
    
    return [super resignFirstResponder];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    self.keyboardFrame = CGRectZero;
    if (self.inputBox.inputBoxStatus == KInputBoxStatusShowEmoji || self.inputBox.inputBoxStatus == KInputBoxStatusShowMore) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(inputBoxCtrl:didChangeInputBoxHeight:)]) {
        [self.delegate inputBoxCtrl:self didChangeInputBoxHeight:self.inputBox.curHeight];
    }
}

- (void)keyboardFrameWillChange:(NSNotification *)notification{
    
    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (self.inputBox.inputBoxStatus == KInputBoxStatusShowKeyboard && self.keyboardFrame.size.height <= INPUT_BOX_MORE_VIEW_HEIGHT) {
        return;
    }
    else if ((self.inputBox.inputBoxStatus == KInputBoxStatusShowEmoji || self.inputBox.inputBoxStatus == KInputBoxStatusShowMore) && self.keyboardFrame.size.height <= INPUT_BOX_MORE_VIEW_HEIGHT) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBoxCtrl:didChangeInputBoxHeight:)]) {
        // 改变控制器.View 的高度 键盘的高度 + 当前的 49
        [self.delegate inputBoxCtrl:self didChangeInputBoxHeight:self.keyboardFrame.size.height + self.inputBox.curHeight];
    }
}

- (void)didSelectedMoreView:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    KInputBoxMoreStatus inputBoxMoreStatus = [userInfo[@"status"] unsignedIntegerValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBoxCtrl:didSelectedMoreView:)]) {
        [self.delegate inputBoxCtrl:self didSelectedMoreView:inputBoxMoreStatus];
    }
}

- (void)inputBox:(KInputBoxView *)inputBox changeStatusForm:(KInputBoxStatus)fromStatus to:(KInputBoxStatus)toStatus {
    switch (toStatus) {
        case KInputBoxStatusNone:
            
            break;
        case KInputBoxStatusShowKeyboard:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.emojiView removeFromSuperview];
                [self.moreView removeFromSuperview];
                
            });
        }
            break;
        case KInputBoxStatusShowVoice:
        {
            if (fromStatus == KInputBoxStatusShowMore || fromStatus == KInputBoxStatusShowEmoji) {
                [self.emojiView removeFromSuperview];
                [self.moreView removeFromSuperview];
                [UIView animateWithDuration:0.15 animations:^{
                    if (_delegate && [_delegate respondsToSelector:@selector(inputBoxCtrl:didChangeInputBoxHeight:)]) {
                        [_delegate inputBoxCtrl:self didChangeInputBoxHeight:kTabbarHeight];
                    }
                }];
            }
            else {
                [UIView animateWithDuration:0.15 animations:^{
                    if (_delegate && [_delegate respondsToSelector:@selector(inputBoxCtrl:didChangeInputBoxHeight:)]) {
                        [_delegate inputBoxCtrl:self didChangeInputBoxHeight:kTabbarHeight];
                    }
                }];
            }
        }
            break;
        case KInputBoxStatusShowEmoji:
        {
            if (fromStatus == KInputBoxStatusShowVoice || fromStatus == KInputBoxStatusNone) {
                
                [self.emojiView setMj_y:self.inputBox.curHeight - kTabbarSafeBottomMargin];
                // 添加表情View
                BOOL noEmpty = self.inputBox.inputView.text.length > 0;
                [self addSubview:self.emojiView];
                if (noEmpty) {
                    [self.emojiView.menuView.sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                    [self.emojiView.menuView.sendButton setBackgroundColor:[ColorTools colorWithHexString:@"0x0657b6"]];
                }
                
                if (_delegate && [_delegate respondsToSelector:@selector(inputBoxCtrl:didChangeInputBoxHeight:)]) {
                    [self.delegate inputBoxCtrl:self didChangeInputBoxHeight:self.inputBox.curHeight + INPUT_BOX_EMOJI_VIEW_HEIGHT + kTabbarSafeBottomMargin];
                }
            }
            else {
                // 表情高度变化
                self.emojiView.mj_h = self.inputBox.curHeight + INPUT_BOX_EMOJI_VIEW_HEIGHT;
                BOOL noEmpty = self.inputBox.inputView.text.length > 0;
                if (noEmpty) {
                    [self.emojiView.menuView.sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                    [self.emojiView.menuView.sendButton setBackgroundColor:[ColorTools colorWithHexString:@"0x0657b6"]];
                }
                [self addSubview:self.emojiView];
                
                [UIView animateWithDuration:0.15 animations:^{
                    
                    self.emojiView.mj_y = self.inputBox.curHeight;
                    
                } completion:^(BOOL finished) {
                    
                    [self.moreView removeFromSuperview];
                    
                }];
                
                // 整个界面高度变化
                if (fromStatus != KInputBoxStatusShowMore) {
                    if (_delegate && [_delegate respondsToSelector:@selector(inputBoxCtrl:didChangeInputBoxHeight:)]) {
                        [self.delegate inputBoxCtrl:self didChangeInputBoxHeight:self.inputBox.curHeight + INPUT_BOX_EMOJI_VIEW_HEIGHT + kTabbarSafeBottomMargin];
                    }
                }
            }
        }
            break;
        case KInputBoxStatusShowMore:
        {
            if (fromStatus == KInputBoxStatusShowVoice || fromStatus == KInputBoxStatusNone) {
                [self.moreView setMj_y:self.inputBox.curHeight - kTabbarSafeBottomMargin];
                
                [self addSubview:self.moreView];
                
                [UIView animateWithDuration:0.15 animations:^{
                    if (_delegate && [_delegate respondsToSelector:@selector(inputBoxCtrl:didChangeInputBoxHeight:)]) {
                        [self.delegate inputBoxCtrl:self didChangeInputBoxHeight:self.inputBox.curHeight + INPUT_BOX_EMOJI_VIEW_HEIGHT + kTabbarSafeBottomMargin];
                    }
                }];
            }
            else {
                
                self.moreView.mj_y = self.inputBox.curHeight + INPUT_BOX_EMOJI_HEIGHT;
                [self.emojiView removeFromSuperview];
                
                [self addSubview:self.moreView];
                [UIView animateWithDuration:0.15 animations:^{
                    self.moreView.mj_y = self.inputBox.curHeight;
                } completion:nil];
                
                if (fromStatus != KInputBoxStatusShowMore) {
                    
                    [UIView animateWithDuration:0.15 animations:^{
                        if (_delegate && [_delegate respondsToSelector:@selector(inputBoxCtrl:didChangeInputBoxHeight:)]) {
                            [self.delegate inputBoxCtrl:self didChangeInputBoxHeight:self.inputBox.curHeight + INPUT_BOX_EMOJI_VIEW_HEIGHT + kTabbarSafeBottomMargin];
                        }
                    }];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)inputBox:(KInputBoxView *)inputBox changeInputBoxHeight:(CGFloat)height {
    
    self.emojiView.mj_y = height;
    self.moreView.mj_y = height;
    if (_delegate && [_delegate respondsToSelector:@selector(inputBoxCtrl:didChangeInputBoxHeight:)]) {
        // 除了输入框之外的高度
        CGFloat extraHeight = 0;
        if (inputBox.inputBoxStatus == KInputBoxStatusShowMore) {
            extraHeight = INPUT_BOX_MORE_VIEW_HEIGHT + kTabbarSafeBottomMargin;
        }
        else if (inputBox.inputBoxStatus == KInputBoxStatusShowEmoji) {
            extraHeight = INPUT_BOX_EMOJI_VIEW_HEIGHT + kTabbarSafeBottomMargin;
        }
        else if (inputBox.inputBoxStatus == KInputBoxStatusShowKeyboard) {
            extraHeight = self.keyboardFrame.size.height;
        }
        else {
            extraHeight = 0;
        }
        [self.delegate inputBoxCtrl:self didChangeInputBoxHeight:self.inputBox.curHeight + extraHeight];
    }
}

- (void)inputBox:(KInputBoxView *)inputBox sendTextMessage:(NSString *)textMessage {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBoxCtrl:sendTextMessage:)]) {
        [self.delegate inputBoxCtrl:self sendTextMessage:textMessage];
    }
}

- (void)inputBox:(KInputBoxView *)inputBox recordStatus:(KInputBoxRecordStatus)recordState voicePath:(NSString *)voiceUrl recordTime:(CGFloat)recordTime {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBoxCtrl:recordStatus:voicePath:recordTime:)]) {
        [self.delegate inputBoxCtrl:self recordStatus:recordState voicePath:voiceUrl recordTime:recordTime];
    }
}


// 选择表情
- (void)emojiView:(KInputBoxEmojiView *)emojiView didSelectEmoji:(KEmojiModel *)emojiDic emojiType:(KEmojiType)emojiType {

    NSRange range = self.inputBox.inputView.selectedRange;
    
    NSString *prefix = [self.inputBox.inputView.text substringToIndex:range.location];

    NSString *suffix = [self.inputBox.inputView.text substringFromIndex:range.length + range.location];
    self.inputBox.inputView.text = [NSString stringWithFormat:@"%@%@%@",prefix, emojiDic.emojiName, suffix];
    /********************需要在输入框直接显示表情***********************/
//    // 光标被多选
//    if (range.length > 0) {
//        [self.inputBox.inputView.textStorage deleteCharactersInRange:range];
//    }
//
//    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
//    //给附件添加图片
//    textAttachment.image = [UIImage sd_animatedGIFNamed:emojiDic[@"name"]];
//
//    textAttachment.emojiName = emojiDic[@"face_name"];
//    textAttachment.bounds = CGRectMake(0, -5, 20, 20);
//    NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
//
//    [self.inputBox.inputView.textStorage insertAttributedString:imageStr atIndex:self.inputBox.inputView.selectedRange.location];
//
//    [self.inputBox.inputView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:INPUT_BOX_TEXT_FONT] range:NSMakeRange(0, self.inputBox.inputView.textStorage.length)];
//    [self.inputBox.inputView.textStorage addAttribute:NSForegroundColorAttributeName value:INPUT_BOX_TEXTCOLOR range:NSMakeRange(0, self.inputBox.inputView.textStorage.length)];
//    self.inputBox.inputView.selectedRange = NSMakeRange(self.inputBox.inputView.selectedRange.location + 1, 0);
//    [self.inputBox textViewDidChange:self.inputBox.inputView];
//
    
}

- (void)emojiViewDeleteEmoji {
    [self.inputBox deleteEmoji];
}

// 点击添加表情
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView clickAddAction:(UIButton *)addBut {
    
}

// 选择表情组
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView didSelectEmojiGroup:(KEmojiGroup *)emojiGroup {
    
}

- (void)emojiView:(KInputBoxEmojiView *)emojiView sendEmoji:(NSString *)emojiStr {
    
    [self.inputBox sendCurrentMessage];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.inputBox removeFromSuperview];
    self.inputBox = nil;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
