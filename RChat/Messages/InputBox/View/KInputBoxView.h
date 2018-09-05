//
//  KInputBoxView.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/24.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KInputBoxViewDelegate.h"

@class KRecordView;

@interface KInputBoxView : UIView
// 语音按钮
@property (nonatomic, strong) UIButton    *voiceBtn;
// 输入框
@property (nonatomic, strong) UITextView   *inputView;
// 表情按钮
@property (nonatomic, strong) UIButton    *emojiBtn;
// 更多按钮
@property (nonatomic, strong) UIButton    *moreBtn;
// 录音按钮
@property (nonatomic, strong) UIButton    *recordAudioBtn;
// 聊天键盘按钮
@property (nonatomic, strong) KRecordView *talkButton;
// 顶部的横线
@property (nonatomic, strong) UIView      *topLine;
// 输入框当前高度
@property (nonatomic, assign) CGFloat     curHeight;
// 输入框输入时的代理
@property (nonatomic, assign) id<KInputBoxViewDelegate> delegate;
// 输入框输入状态
@property (nonatomic, assign) KInputBoxStatus       inputBoxStatus;
// 录音状态
@property (nonatomic, assign) KInputBoxRecordStatus recordState;



/**
 输入框输入文字改变结束

 @param textView 输入框视图
 */
- (void)textViewDidChange:(UITextView *)textView;

// 删除表情
- (void)deleteEmoji;
// 收取键盘
- (BOOL)resignFirstResponder;
// 出现键盘
- (BOOL)becomeFirstResponder;
// 发送当前消息
- (void)sendCurrentMessage;

@end
