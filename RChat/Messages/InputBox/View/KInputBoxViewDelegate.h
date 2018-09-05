
//
//  KInputBoxViewDelegate.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/27.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#ifndef KInputBoxViewDelegate_h
#define KInputBoxViewDelegate_h



@class KEmojiModel;
@class KEmojiGroup;
@class KInputBoxView;
@class KInputBoxEmojiView;
@class KInputBoxEmojiMenuView;
@class KInputBoxEmojiItemView;


@protocol KInputBoxViewDelegate <NSObject>

@optional
#pragma mark - 表情页面（KInputBoxEmojiView）代理

/**
 点击选择表情
 
 @param emojiView 表情所在页面
 @param emojiDic 表情数据
 @param emojiType 表情类型
 */
- (void)emojiView:(KInputBoxEmojiView *)emojiView
   didSelectEmoji:(KEmojiModel *)emojiDic
        emojiType:(KEmojiType)emojiType;


/**
 删除光标前面的表情
 */
- (void)emojiViewDeleteEmoji;

/**
 点击发送按钮，发送表情
 
 @param emojiView 表情菜单
 @param emojiStr 发送按钮
 */
- (void)emojiView:(KInputBoxEmojiView *)emojiView
        sendEmoji:(NSString *)emojiStr;

#pragma mark - 表情菜单代理部分

/**
 点击添加表情按钮
 
 @param menuView 表情菜单
 @param addBut 点击按钮
 */
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView
      clickAddAction:(UIButton *)addBut;

/**
 选择表情组
 
 @param menuView 表情菜单页面
 @param emojiGroup 表情组
 */
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView
  didSelectEmojiGroup:(KEmojiGroup *)emojiGroup;

/**
 点击发送按钮，发送表情
 
 @param menuView 表情菜单
 @param sendBut 发送按钮
 */
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView
            sendEmoji:(UIButton *)sendBut;

#pragma mark - 输入框代理部分

/**
 通过输入的文字的变化，改变输入框的高度
 
 @param inputBox 输入框
 @param height 改变的高度
 */
- (void)inputBox:(KInputBoxView *)inputBox changeInputBoxHeight:(CGFloat)height;

/**
 发送消息
 
 @param inputBox 输入框
 @param textMessage 输入的文字内容
 */
- (void)inputBox:(KInputBoxView *)inputBox
 sendTextMessage:(NSString *)textMessage;

/**
 状态改变
 
 @param inputBox 输入框
 @param fromStatus 上一个状态
 @param toStatus 当前状态
 */
- (void)inputBox:(KInputBoxView *)inputBox
changeStatusForm:(KInputBoxStatus)fromStatus
              to:(KInputBoxStatus)toStatus;

/**
 点击输入框更多按钮事件
 
 @param inputBox 输入框
 @param inputStatus 当前状态
 */
- (void)inputBox:(KInputBoxView *)inputBox
  clickMoreInput:(KInputBoxStatus)inputStatus;

@end

#endif /* KInputBoxViewDelegate_h */
