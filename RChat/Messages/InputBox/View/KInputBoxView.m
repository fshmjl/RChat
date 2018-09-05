//
//  KInputBoxView.m
//  KXiniuCloud
//
//  Created by eims on 2018/4/24.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KInputBoxView.h"

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKitDefines.h>

//#import "UITextView+KCategory.h"
#import "UIViewController+KCategory.h"
//#import "NSAttributedString+Addition.h"


#import "KRecordView.h"
#import "UIImage+Color.h"
#import "KFileManagement.h"
#import "NSDate+KCategory.h"
#import "KChatMessageHelper.h"
#import "KSystemAuthorization.h"
#import "KInputBoxRecorderView.h"

// 底部间距
#define bottomSpace (IS_iPhoneX ? 44 + 10 : 10)

@interface KInputBoxView()<UITextViewDelegate> {
    BOOL isAuthorized;
}

@property (nonatomic, assign) NSRange lastRange;

@property (nonatomic, assign) BOOL canceled;

@property (nonatomic, assign) CGRect talkFrame;

@end

@implementation KInputBoxView


#pragma mark - 懒加载
// 语音和键盘切换按钮
- (UIButton *)voiceBtn {
    if (!_voiceBtn) {
        _voiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, INPUT_BOX_HEIGHT - 10, INPUT_BOX_HEIGHT)];
        [_voiceBtn setImage:INPUT_BOX_VOICE_IMAGE forState:UIControlStateNormal];
        _voiceBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5);
        [_voiceBtn addTarget:self action:@selector(clickSwitchVoiceAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceBtn;
}

// 输入框
- (UITextView *)inputView {
    if (!_inputView) {
        _inputView = [[UITextView alloc] initWithFrame:CGRectMake(self.voiceBtn.kMax_x, INPUT_BOX_BACKGROUND_SPACE, MSWIDTH - 3 * (INPUT_BOX_HEIGHT - 10), INPUT_BOX_HEIGHT - 2 * INPUT_BOX_BACKGROUND_SPACE)];
        _inputView.delegate            = self;
        _inputView.textColor           = INPUT_BOX_TEXTCOLOR;
        _inputView.font                = [UIFont systemFontOfSize:INPUT_BOX_TEXT_FONT];
        _inputView.backgroundColor     = [UIColor whiteColor];
//        _inputView.isInputBox          = YES;

        _inputView.bounces             = NO;
        _inputView.returnKeyType       = UIReturnKeySend;
        _inputView.layer.cornerRadius  = 4;
        _inputView.layer.masksToBounds = YES;
        _inputView.allowsEditingTextAttributes = YES;
        _inputView.layoutManager.allowsNonContiguousLayout = NO;
    }
    return _inputView;
}

// 表情按钮
- (UIButton *)emojiBtn {
    if (!_emojiBtn) {
        _emojiBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.inputView.kMax_x, 0, INPUT_BOX_HEIGHT - 10, INPUT_BOX_HEIGHT)];
        [_emojiBtn setImage:INPUT_BOX_FACE_IMAGE forState:UIControlStateNormal];
        _emojiBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 5);
        [_emojiBtn addTarget:self action:@selector(clickSelecteEmoji:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiBtn;
}

// 更多按钮
- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.emojiBtn.kMax_x, 0, INPUT_BOX_HEIGHT - 10, INPUT_BOX_HEIGHT)];
        [_moreBtn setImage:INPUT_BOX_MORE_IMAGE forState:UIControlStateNormal];
        _moreBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 10);
        [_moreBtn addTarget:self action:@selector(clickMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (KRecordView *)talkButton
{
    if (!_talkButton) {
        _talkButton = [[KRecordView alloc] initWithFrame:CGRectMake(self.voiceBtn.kMax_x, INPUT_BOX_BACKGROUND_SPACE, MSWIDTH - 3 * (INPUT_BOX_HEIGHT - 10), INPUT_BOX_HEIGHT - 2 * INPUT_BOX_BACKGROUND_SPACE)];
        _talkFrame = _talkButton.frame;
        [_talkButton setBackgroundColor:[UIColor clearColor]];
        [_talkButton.layer setMasksToBounds:YES];
        [_talkButton.layer setCornerRadius:4.0f];
        [_talkButton.layer setBorderWidth:0.5f];
        [_talkButton.layer setBorderColor:[UIColor grayColor].CGColor];
        [_talkButton setHidden:YES];
        _talkButton.userInteractionEnabled = NO;
    }
    return _talkButton;
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MSWIDTH, 1)];
        _topLine.backgroundColor = [ColorTools colorWithHexString:@"0xe2e2e2"];
    }
    return _topLine;
}


#pragma mark - 初始化
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
    self.inputBoxStatus = KInputBoxStatusNone;
    
    [self addSubview:self.topLine];
    [self addSubview:self.voiceBtn];
    [self addSubview:self.moreBtn];
    [self addSubview:self.emojiBtn];
    [self addSubview:self.inputView];
    [self addSubview:self.talkButton];
    
    self.userInteractionEnabled = YES;
    self.curHeight = INPUT_BOX_HEIGHT;
    
    [self.inputView addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew || NSKeyValueChangeOldKey context:nil];
}

-(void)setFrame:(CGRect)frame
{
    // 6 的初始化 0.0.375.49
    [super setFrame:frame];
    [self.topLine setMj_w:self.mj_w];
    
    float y = self.mj_h - INPUT_BOX_HEIGHT;
    if (self.inputBoxStatus == KInputBoxStatusShowVoice) {
        y = self.mj_h - INPUT_BOX_HEIGHT - kTabbarSafeBottomMargin;
    }
    if (self.voiceBtn.mj_y != y) {
        
        [self.inputView setMj_h:self.mj_h - 2*INPUT_BOX_BACKGROUND_SPACE];
        [self.voiceBtn  setMj_y:y];
        [self.emojiBtn  setMj_y:self.voiceBtn.mj_y];
        [self.moreBtn   setMj_y:self.voiceBtn.mj_y];
    }
}

#pragma mark - 响应事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"text"]) {
        [self textViewDidChange:self.inputView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.inputView scrollRangeToVisible:NSMakeRange(self.inputView.text.length, 1)];
}

- (BOOL)resignFirstResponder {
    
    if (self.inputBoxStatus == KInputBoxStatusShowVoice) {
        [self.emojiBtn setImage:INPUT_BOX_FACE_IMAGE forState:UIControlStateNormal];
        [self.voiceBtn setImage:INPUT_BOX_KEYBOARD_IMAGE forState:UIControlStateNormal];
    }
    else {
        [self.emojiBtn setImage:INPUT_BOX_FACE_IMAGE forState:UIControlStateNormal];
        [self.voiceBtn setImage:INPUT_BOX_VOICE_IMAGE forState:UIControlStateNormal];
    }
    [self.inputView resignFirstResponder];
    
    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    [self.inputView becomeFirstResponder];
    return [super becomeFirstResponder];
}

#pragma mark - 点击事件
// 点击切换语音或键盘
- (void)clickSwitchVoiceAction:(UIButton *)sender {
    
    KInputBoxStatus lastStatus = self.inputBoxStatus;
    if (self.inputBoxStatus != KInputBoxStatusShowVoice) {
        isAuthorized = [[KSystemAuthorization shareInstance] checkAudioAuthrization];
        if (!isAuthorized) {
            [self settingAuthorizationWithTitle:@"权限设置" message:@"录音需要访问你的麦克风权限" cancel:^(BOOL isCancel) {
                isAuthorized = !isCancel;
            }];
        }
        
        self.inputBoxStatus = KInputBoxStatusShowVoice;
        self.curHeight = kTabbarHeight;
        [self setMj_h:self.curHeight];
        
        [self.inputView resignFirstResponder];
        // 判断最后的状态是不是显示的表情
        if (lastStatus == KInputBoxStatusShowEmoji) {
            [self.emojiBtn setImage:INPUT_BOX_FACE_IMAGE forState:UIControlStateNormal];
        }
        
        [_voiceBtn setImage:INPUT_BOX_KEYBOARD_IMAGE forState:UIControlStateNormal];
        
        [self.inputView setHidden:YES];
        [self.talkButton setHidden:NO];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBox:changeStatusForm:to:)]) {
            [self.delegate inputBox:self changeStatusForm:lastStatus to:KInputBoxStatusShowVoice];
        }
    }
    else {
        
        self.inputBoxStatus = KInputBoxStatusShowKeyboard;
        [self.inputView becomeFirstResponder];
        
        [self.inputView setHidden:NO];
        [self.talkButton setHidden:YES];
        self.talkButton.userInteractionEnabled = NO;
        
        [_voiceBtn setImage:INPUT_BOX_VOICE_IMAGE forState:UIControlStateNormal];
        [self.emojiBtn setImage:INPUT_BOX_FACE_IMAGE forState:UIControlStateNormal];
        
        [self textViewDidChange:self.inputView];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBox:changeStatusForm:to:)]) {
            [self.delegate inputBox:self changeStatusForm:lastStatus to:KInputBoxStatusShowKeyboard];
        }
        
    }
}

// 输入表情
- (void)clickSelecteEmoji:(UIButton *)sender {
    
    KInputBoxStatus lastStatus = self.inputBoxStatus;
    if (lastStatus != KInputBoxStatusShowEmoji) {
        self.inputBoxStatus = KInputBoxStatusShowEmoji;
        
        if (lastStatus == KInputBoxStatusShowKeyboard) {
            [self.inputView resignFirstResponder];
        }
        // 显示键盘图标
        [self.emojiBtn setImage:INPUT_BOX_KEYBOARD_IMAGE forState:UIControlStateNormal];
        [_voiceBtn setImage:INPUT_BOX_VOICE_IMAGE forState:UIControlStateNormal];
        
        if (self.inputView.hidden) {
            self.inputView.hidden = NO;
            self.talkButton.hidden = YES;
        }
        
        [self textViewDidChange:self.inputView];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBox:changeStatusForm:to:)]) {
            [self.delegate inputBox:self changeStatusForm:lastStatus to:KInputBoxStatusShowEmoji];
            // 最后的状态是显示键盘，需要先收起键盘
        }
    }
    else {
        self.inputBoxStatus = KInputBoxStatusShowKeyboard;
        
        [self.inputView becomeFirstResponder];
        
        [self.emojiBtn setImage:INPUT_BOX_FACE_IMAGE forState:UIControlStateNormal];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBox:changeStatusForm:to:)]) {
            [self.delegate inputBox:self changeStatusForm:lastStatus to:KInputBoxStatusShowKeyboard];
        }
    }
}


/**
 点击更多按钮
 */
- (void)clickMoreAction:(UIButton *)sender {
    
    KInputBoxStatus lastStatus = self.inputBoxStatus;
    
    if (self.inputBoxStatus != KInputBoxStatusShowMore) {
        self.inputBoxStatus = KInputBoxStatusShowMore;
        [self.emojiBtn setImage:INPUT_BOX_FACE_IMAGE forState:UIControlStateNormal];
        [self.voiceBtn setImage:INPUT_BOX_VOICE_IMAGE forState:UIControlStateNormal];
        [self.talkButton setHidden:YES];
        [self.inputView setHidden:NO];
        self.talkButton.userInteractionEnabled = NO;
        
        [self.inputView resignFirstResponder];
        [self textViewDidChange:self.inputView];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBox:changeStatusForm:to:)]) {
            [self.delegate inputBox:self changeStatusForm:lastStatus to:KInputBoxStatusShowMore];
        }
    }
}

#pragma mark - 录音部分
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.inputBoxStatus != KInputBoxStatusShowVoice) {
        return;
    }
    if (!isAuthorized) {
        [self settingAuthorizationWithTitle:@"权限设置" message:@"录音需要访问你的麦克风权限" cancel:^(BOOL isCancel) {
            isAuthorized = !isCancel;
        }];
        return;
    }
    else {
        
        CGPoint touchPoint = [[touches anyObject] locationInView:self];
        
        if (CGRectContainsPoint(_talkFrame, touchPoint))
        {
            _canceled = NO;
            self.recordState = KInputBoxRecordStatusRecording;
            self.talkButton.titleLabel.text = @"松开 发送";
        }
        else {
            _canceled = YES;
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_canceled || !isAuthorized || self.inputBoxStatus != KInputBoxStatusShowVoice) {
        return;
    }
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_talkFrame, touchPoint)) {
        self.recordState = KInputBoxRecordStatusMoveInside;
        _talkButton.titleLabel.text = @"松开 发送";
    }
    else
    {
        self.recordState = KInputBoxRecordStatusMoveOutside;
        _talkButton.titleLabel.text = @"松开 取消";
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_canceled || !isAuthorized || self.inputBoxStatus != KInputBoxStatusShowVoice) {
        return;
    }
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    self.recordState = CGRectContainsPoint(_talkFrame, touchPoint) ? KInputBoxRecordStatusEnd : KInputBoxRecordStatusCancel;
    self.talkButton.titleLabel.text = @"按住 说话";
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_canceled || !isAuthorized || self.inputBoxStatus != KInputBoxStatusShowVoice) {
        return;
    }
    self.recordState = KInputBoxRecordStatusCancel;
    self.talkButton.titleLabel.text = @"按住 说话";
}

/**
 发送当前消息
 */
- (void)sendCurrentMessage {
    if (self.inputView.text.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBox:sendTextMessage:)]) {
            [self.delegate inputBox:self sendTextMessage:self.inputView.text];
        }
        self.inputView.text = @"";
    }
}

/**
 删除表情
 */
- (void)deleteEmoji {
    if (((int)self.inputView.text.length - 1) >= 0) {
        [self textView:self.inputView shouldChangeTextInRange:NSMakeRange(self.inputView.text.length - 1, 1) replacementText:@""];
        [self textViewDidChange:self.inputView];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    KInputBoxStatus lastStatus = self.inputBoxStatus;
    self.inputBoxStatus = KInputBoxStatusShowKeyboard;
    if (lastStatus == KInputBoxStatusShowEmoji) {
        
        [_emojiBtn setImage:INPUT_BOX_FACE_IMAGE forState:UIControlStateNormal];
        
    }
    else if (lastStatus == KInputBoxStatusShowMore) {
        
        [_moreBtn setImage:INPUT_BOX_MORE_IMAGE forState:UIControlStateNormal];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(inputBox:changeStatusForm:to:)]) {
    }
}

/**
 *  TextView 的输入内容一改变就调用这个方法，
 */
- (void)textViewDidChange:(UITextView *)textView {
    
    CGFloat height = [self.inputView sizeThatFits:CGSizeMake(textView.mj_w, MAXFLOAT)].height;
    // 当高度大于最小高度时
    height = height > INPUT_BOX_TEXT_MIN_HEIGHT ? height : INPUT_BOX_TEXT_MIN_HEIGHT;
    if (height <= INPUT_BOX_TEXT_MAX_HEIGHT) {
        self.inputView.showsVerticalScrollIndicator = NO;
    }
    else {
        self.inputView.showsVerticalScrollIndicator = YES;
    }
    height = height < INPUT_BOX_TEXT_MAX_HEIGHT ? height : INPUT_BOX_TEXT_MAX_HEIGHT;
    self.curHeight = height + INPUT_BOX_BACKGROUND_SPACE*2;
    
    [self.inputView scrollRangeToVisible:NSMakeRange(self.inputView.text.length, 1)];
    
    if (self.mj_h != self.curHeight) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBox:changeInputBoxHeight:)]) {
            [self.delegate inputBox:self changeInputBoxHeight:self.curHeight];
        }
    }
    
    if (height != textView.mj_h) {
        [UIView animateWithDuration:0.05 animations:^{
            [textView setMj_h:height];
        }];
    }
    
    if ([textView.text isEqualToString:@""] || textView.text.length == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteEmojiToEmpty" object:nil];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    self.lastRange = range;
    if ([text isEqualToString:@"\n"]) {
        [self sendCurrentMessage];
        self.curHeight = INPUT_BOX_HEIGHT;
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBox:changeInputBoxHeight:)]) {
            [self.delegate inputBox:self changeInputBoxHeight:INPUT_BOX_HEIGHT];
        }
        return NO;
    }
    else if (textView.text.length > 0 && [text isEqualToString:@""]) {
        // delete
        if ([textView.text characterAtIndex:range.location] == ']') {
            NSUInteger location = range.location;
            NSUInteger length = range.length;
            while (location != 0) {
                location -- ;
                length ++ ;
                char c = [textView.text characterAtIndex:location];
                if (c == '[') {
                    
                    textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                    [self textViewDidChange:textView];
                    return NO;
                    
                }
                else if (c == ']') {
                    
                    return YES;
                }
            }
            
        }
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

/**
 权限设置
 
 @param title 提示标题
 @param message 提示内容
 @param block 回调
 */
- (void)settingAuthorizationWithTitle:(NSString *)title message:(NSString *)message cancel:(void (^)(BOOL))block
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        block(YES);
    }];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        block(NO);
        [[KSystemAuthorization shareInstance] requetSettingForAuth];
        return;
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:setting];
    
    UIViewController *viewController = [[UIViewController new] getCurrentVC];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)dealloc {
    [self.inputView removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
