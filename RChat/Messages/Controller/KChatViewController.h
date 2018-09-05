//
//  KChatViewController.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/8.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "BaseViewController.h"

#import <AVFoundation/AVFoundation.h>



@class KMessageModel;
@class KInputBoxViewCtrl;
@class KConversationModel;
@class KInputBoxRecorderView;

@interface KChatViewController : BaseViewController<AVAudioPlayerDelegate>
// 进入聊天页面需要发送正处于发送状态的消息
@property (nonatomic, assign) BOOL                    isEnterSend;
@property (nonatomic, assign) BOOL                    canceled;
// 需要移动的高度
@property (nonatomic, assign) CGFloat                 moveHeight;
// 消息列表
@property (nonatomic, strong) UITableView             *listView;
// 记录图片和视频数据
@property (nonatomic, strong) NSMutableArray          *allImageDatas;
// 数据源
@property (nonatomic, strong) NSMutableArray          *dataSource;
// 输入框控制器
@property (nonatomic, strong) KInputBoxViewCtrl       *inputBoxCtrl;
// 自己发送的最后一条语音的URL
@property (nonatomic, strong) NSURL                   *lastAudioUrl;

@property (nonatomic, strong) NSArray                 *imageDatas;
// 会话
@property (nonatomic, strong) KConversationModel      *conversation;
// 最后一条消息的消息id
@property (nonatomic, copy) NSString                  *lastMsgId;
// 接收者的犀牛id
@property (nonatomic, copy) NSString                  *toUserId;
// 未读消息数
@property (nonatomic, copy) NSString                  *badgeNumber;

// 是否是从会话页面进入
@property (nonatomic, assign) BOOL                    isConversationInto;
// 语音图片
@property (nonatomic, strong) UIImageView            *voiceImageView;
// 音频播放器
@property (nonatomic, strong) AVAudioPlayer          *audioPlayer;
// 最后播放的语音URL的Index
@property (nonatomic, assign) NSInteger              lastPlayVoiceIndex;
// 语音消息id
@property (nonatomic, copy) NSString                 *voiceMessageId;

// 重新刷新数据
- (void)reloadData;
// 移动到底部
- (void)scrollTableViewBottom ;
// 添加一条消息
- (void)addMessage:(KMessageModel *)model;
// 最后一条消息
- (KMessageModel *)lastMessage;

/**
 移除一条消息

 @param message 消息
 */
- (void)removeLastMessage:(KMessageModel *)message;

/**
 最新消息是否显示时间
 
 @param messageModel 最新的消息
 @return YES：显示 NO:不显示
 */
- (BOOL)isShowTimeWithNewMessageModel:(KMessageModel *)messageModel previousMessage:(KMessageModel *)previousMessage;

/**
 发送消息
 
 @param content 消息内容 文本消息content为文字，图片、语音content为NSData转成的字符串
 @param cellHeight 行高
 @param messageSize 消息控件大小
 @param messageType 消息类型
 @param filePath 图片、视频、音频路径,其他消息传nil
 @param messageModel 当前的消息model
 @param saveResult 保存消息回调
 */
- (void)saveMessageWithContent:(NSString *)content
                    cellHeight:(CGFloat)cellHeight
                   messageSize:(CGSize)messageSize
                   messageType:(KMessageType)messageType
                      filePath:(NSString *)filePath
                  messageModel:(KMessageModel *)messageModel
                     indexPath:(NSIndexPath *)indexPath
                    saveResult:(void(^)(BOOL isSuccess, NSDictionary *jsonDic, NSString *localMsgId))saveResult;
/**
 发送消息
 
 @param jsonStr 消息json字符串
 @param localMessageId 本地消息id
 @param indexPath 当条消息所在行数据
 */
- (void)sendMessageWithJsonStr:(NSString *)jsonStr
                localMessageId:(NSString *)localMessageId
                     indexPath:(NSIndexPath *)indexPath;

/**
 更新Cell视图消息发送状态
 
 @param sendState 发送状态
 @param indexPath 列表索引
 @param localMessageId 本地消息id
 @param serversMsgId 服务端消息id
 */
- (void)updateMessageSendStatus:(KMessageSendStatus)sendState
                      indexPath:(NSIndexPath *)indexPath
                 localMessageId:(NSString *)localMessageId
                   serversMsgId:(NSString *)serversMsgId;


/**
 更新本地消息发送状态
 
 @param srcId 本地消息id
 @param destId 服务器返回消息id
 @param sendState 消息状态，0：失败，1：成功 2:发送中
 */
- (void)updateDatabaseMessageWithSrcId:(NSString *)srcId
                                destId:(NSString *)destId
                             sendState:(int)sendState;

@end
