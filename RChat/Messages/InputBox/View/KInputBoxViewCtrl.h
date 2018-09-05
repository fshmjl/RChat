//
//  KInputBoxViewCtrl.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/27.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>



@class KEmojiGroup;
@class KInputBoxView;
@class KInputBoxMoreView;
@class KInputBoxEmojiView;

@protocol KInputBoxViewCtrlDelegate;

@interface KInputBoxViewCtrl : UIView

// 输入框
@property (nonatomic, strong) KInputBoxView *inputBox;
// 更多视图
@property (nonatomic, strong) KInputBoxMoreView *moreView;
// 表情页面
@property (nonatomic, strong) KInputBoxEmojiView *emojiView;

@property (nonatomic, assign) id<KInputBoxViewCtrlDelegate> delegate;

- (BOOL)resignFirstResponder;

@end

@protocol KInputBoxViewCtrlDelegate <NSObject>

@optional

/**
 输入框高度变化
 
 @param inputBoxCtrl 输入框控制器
 @param height 高度
 */
- (void)inputBoxCtrl:(KInputBoxViewCtrl *)inputBoxCtrl didChangeInputBoxHeight:(CGFloat)height;

/**
 点击添加表情按钮
 
 @param inputBoxCtrl 表情菜单
 @param addBut 点击按钮
 */
- (void)inputBoxCtrl:(KInputBoxViewCtrl *)inputBoxCtrl
     clickAddAction:(UIButton *)addBut;

/**
 选择表情组
 
 @param inputBoxCtrl 表情菜单页面
 @param emojiGroup 表情组
 */
- (void)inputBoxCtrl:(KInputBoxViewCtrl *)inputBoxCtrl
 didSelectEmojiGroup:(KEmojiGroup *)emojiGroup;

/**
 点击发送按钮，发送表情
 
 @param inputBoxCtrl 表情菜单
 @param emojiStr 表情字符串
 */
- (void)inputBoxCtrl:(KInputBoxViewCtrl *)inputBoxCtrl
           sendEmoji:(NSString *)emojiStr;

/**
 通过输入的文字的变化，改变输入框控的高度
 
 @param inputBoxCtrl 输入框控制器
 @param height 改变的高度
 @param inputStatus 输入状态
 */
- (void)inputBoxCtrl:(KInputBoxViewCtrl *)inputBoxCtrl
 changeChatBoxHeight:(CGFloat)height
         inputStatus:(KInputBoxStatus)inputStatus;

/**
 发送消息
 
 @param inputBoxCtrl 输入框控制器
 @param textMessage 输入的文字内容
 */
- (void)inputBoxCtrl:(KInputBoxViewCtrl *)inputBoxCtrl
     sendTextMessage:(NSString *)textMessage;

/**
 状态改变
 
 @param inputBoxCtrl 输入框控制器
 @param fromStatus 上一个状态
 @param toStatus 当前状态
 */
- (void)inputBoxCtrl:(KInputBoxViewCtrl *)inputBoxCtrl
    changeStatusForm:(KInputBoxStatus)fromStatus
                  to:(KInputBoxStatus)toStatus;


/**
 录音状态变化
 
 @param inputBoxCtrl 输入框控制器
 @param recordState 录音状态
 @param voiceUrl 语音url
 @param recordTime 录音时长
 */
- (void)inputBoxCtrl:(KInputBoxViewCtrl *)inputBoxCtrl
        recordStatus:(KInputBoxRecordStatus)recordState
           voicePath:(NSString *)voiceUrl
          recordTime:(CGFloat)recordTime;


/**
 点击更多视图里面的item（照片，拍摄，视频通话，云邮）
 
 @param inputBoxCtrl 输入框控制器
 @param inputBoxMoreStatus 当前状态
 */
- (void)inputBoxCtrl:(KInputBoxViewCtrl *)inputBoxCtrl
 didSelectedMoreView:(KInputBoxMoreStatus)inputBoxMoreStatus;

@end 




