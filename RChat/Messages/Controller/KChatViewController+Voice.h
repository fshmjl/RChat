//
//  KChatViewController+Voice.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/16.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KChatViewController.h"

@interface KChatViewController (Voice)

@property (nonatomic, strong) NSTimer         *timer;                    /**定时器*/
@property (nonatomic, assign) CGFloat         recordTime;                /**录音时长*/
@property (nonatomic, strong) NSString        *audioUrl;                 /**录音地址*/
@property (nonatomic, strong) NSDictionary    *recordSetting;            /**录音设置*/
@property (nonatomic, strong) AVAudioSession  *audioSession;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;            /**录音机*/
@property (nonatomic, assign) NSInteger       recordStatus;              /**录音状态*/
@property (nonatomic, assign) NSInteger       recordIndexPathRow;        /**当前正在录音的索引*/
@property (nonatomic, strong) KMessageModel   *prevMessage;              /**前一条消息*/
@property (nonatomic, strong) KInputBoxRecorderView *recordView;         /**录音提示框*/

/**
 录音部分初始化
 */
- (void)initVoiceData;

/**
 开始录音
 */
- (void)startRecording;

/**
 停止录音
 */
- (void)stopRecord;

/**
 绘制页面
 */
- (void)recordStartDrawView;


- (void)replaceVoiceMessage;

- (void)removeVoiceMessage;

/**
 点击消息播放语音
 
 @param tableViewCell cell
 @param messageModel 语音数据
 */
- (void)playAudioWithTableViewCell:(id)tableViewCell messageModel:(KMessageModel *)messageModel;

@end
