//
//  KMessageModel.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/24.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FinishedRowHeightCalculate)(CGFloat rowHeight, CGSize messageSize, BOOL complete);

@interface KMessageModel : NSObject
// 消息类型
@property (nonatomic, assign) KMessageType       msgType;
// 聊天类型
@property (nonatomic, assign) KMessageChatType   messageChatType;
// 消息发送方向
@property (nonatomic, assign) KMessageSenderType direction;
// 消息发送状态
@property (nonatomic, assign) KMessageSendStatus messageSendStatus;
// 消息读取状态
@property (nonatomic, assign) KMessageReadStatus messageReadStatus;
// 消息接收方
@property (nonatomic, copy) NSString *toUserName;
// 消息接收方id
@property (nonatomic, copy) NSString *toUserId;
// 消息接发送方
@property (nonatomic, copy) NSString *fromUserName;
// 消息接收方id
@property (nonatomic, copy) NSString *fromUserId;
// 消息id
@property (nonatomic, copy) NSString *messageId;
// 对方头像
@property (nonatomic, copy) NSString *toUserAvatar;
// 消息内容, 可能是文本、图片、视频、语音、邮件
@property (nonatomic, strong) id content;
// 发送时间
@property (nonatomic, copy) NSString *sendTime;
// 接收时间
@property (nonatomic, copy) NSString *recvTime;
// 语音时长
@property (nonatomic, copy) NSString *voiceTime;
// 图片类型
@property (nonatomic, assign) NSInteger pictureType;
// 附件数量
@property (nonatomic, assign) NSInteger attach;
// 内容简介
@property (nonatomic, copy) NSString *contentSynopsis;
// 邮件标题
@property (nonatomic, copy) NSString *subject;
// 邮件uid
@property (nonatomic, copy) NSString *uid;
// 邮件ID
@property (nonatomic, copy) NSString *emailId;
// 邮件发送时间
@property (nonatomic, assign) NSTimeInterval mailSendTime;
/**文件url*/
@property (nonatomic, copy) NSString *fileUrl;

@property (nonatomic, assign) BOOL aotoResend;      /**自动重发*/

/***********************只读属性或需要自己处理的属性*************************/
// 消息格式化
@property (nonatomic, strong, readonly) NSAttributedString *messageAtt;

/*
 是否显示小时的时间
 */
@property (nonatomic, assign) BOOL showMessageTime;

@property (nonatomic, strong) KMessageModel *lastMessage;

@property (nonatomic, assign) CGFloat estimateHeight;      /**估计高度*/

@property (nonatomic, assign) CGSize estimateSize;      /**预估Size*/

/*
 音频时间
 */
@property (nonatomic, assign) int duringTime;

/*
 图片文件/视频第一帧图片
 */
@property (nonatomic, retain) NSData *fileData;

/**
 视频第一帧图片
 */
@property (nonatomic, retain) UIImage *videoImage;

// 消息文本大小
@property (nonatomic, assign) CGSize messageSize;
// cell 的高度
@property (nonatomic, assign) CGFloat cellHeight;
// Cell的idendtifier
@property (nonatomic, strong, readonly) NSString *cellIdendtifier;
// 显示昵称或备注
@property (nonatomic, assign) BOOL  showUsername;
// 自己发的邮件是否显示“回复”、“回复全部”和“转发”  默认不显示
@property (nonatomic, assign) BOOL selfSenderMailShowReply;
// 记录是否对需要显示的行高进行了更改
@property (nonatomic, assign) BOOL updatedRowHeight;
// 是否需要延时显示（反逻辑，YES的时候，不需要再延时显示）
@property (nonatomic, assign) BOOL isDelayShowSendStatus;
// 消息已经发送失败
@property (nonatomic, assign) BOOL isFailed;

/**
 消息处理
 主要是计算视图高度，
 优化重复计算高度问题，
 把高度计算从加载时提前到赋值时
 */
- (void)messageProcessingWithFinishedCalculate:(FinishedRowHeightCalculate)finishedCalculate;

/**
 辅助计算网络图片消息行高

 @param imageWidth 图片宽
 @param imageHeight 图片高
 @param complete 高度计算完成回调
 */
- (void)photoHeightWithImageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight complete:(FinishedRowHeightCalculate)complete;

@end

