//
//  KChatViewController+Voice.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/16.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KChatViewController+Voice.h"


#import "KFileCache.h"
#import "KInputBoxView.h"
#import "KMessageModel.h"
#import "KFileManagement.h"
#import "NSDate+KCategory.h"
#import "NSDictionary+Json.h"
#import "KInputBoxViewCtrl.h"
#import "KInputBoxRecorderView.h"
#import "KChatVoiceTableViewCell.h"


BOOL recordFinished;

@implementation KChatViewController (Voice)

static char *timerKey           = "timer";
static char *audioUrlKey        = "audioUrl";
static char *recordViewKey      = "recordView";
static char *recordTimeKey      = "recordTime";
static char *prevMessageKey     = "prevMessage";
static char *audioSessionKey    = "audioSession";
static char *recordStatusKey    = "recordStatus";
static char *audioRecorderKey   = "audioRecorder";
static char *recordSettingKey   = "recordSetting";
static char *recordIndexPathRowKey = "recordIndexPathRow";

- (void)setRecordTime:(CGFloat)recordTime {
    NSNumber *number = [NSNumber numberWithFloat:recordTime];
    objc_setAssociatedObject(self, recordTimeKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)recordTime {
    NSNumber *number = objc_getAssociatedObject(self, recordTimeKey);
    return [number floatValue];
}

- (void)setTimer:(NSTimer *)timer {
    objc_setAssociatedObject(self, timerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimer *)timer {
    return objc_getAssociatedObject(self, timerKey);
}

- (void)setAudioSession:(AVAudioSession *)audioSession {
    objc_setAssociatedObject(self, audioSessionKey, audioSession, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AVAudioSession *)audioSession {
    return objc_getAssociatedObject(self, audioSessionKey);
}

- (void)setAudioRecorder:(AVAudioRecorder *)audioRecorder {
    objc_setAssociatedObject(self, audioRecorderKey, audioRecorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AVAudioRecorder *)audioRecorder {
    return objc_getAssociatedObject(self, audioRecorderKey);
}

- (void)setRecordSetting:(NSDictionary *)recordSetting {
    objc_setAssociatedObject(self, recordSettingKey, recordSetting, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)recordSetting {
    return objc_getAssociatedObject(self, recordSettingKey);
}

- (void)setAudioUrl:(NSString *)audioUrl {
    objc_setAssociatedObject(self, audioUrlKey, audioUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)audioUrl {
    return objc_getAssociatedObject(self, audioUrlKey);
}

- (void)setRecordStatus:(NSInteger)recordStatus {
    objc_setAssociatedObject(self, recordStatusKey, @(recordStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)recordStatus {
    NSNumber *number = objc_getAssociatedObject(self, recordStatusKey);
    return [number integerValue];
}

- (void)setRecordIndexPathRow:(NSInteger )recordIndexPathRow {
    NSNumber *number = [NSNumber numberWithInteger:recordIndexPathRow];
    objc_setAssociatedObject(self, recordIndexPathRowKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)recordIndexPathRow {
    NSNumber *number = objc_getAssociatedObject(self, recordIndexPathRowKey);
    return [number integerValue];
}

- (void)setPrevMessage:(KMessageModel *)prevMessage {
    objc_setAssociatedObject(self, prevMessageKey, prevMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KMessageModel *)prevMessage {
    return objc_getAssociatedObject(self, prevMessageKey);
}

- (void)setRecordView:(KInputBoxRecorderView *)recordView {
    objc_setAssociatedObject(self, recordViewKey, recordView, OBJC_ASSOCIATION_RETAIN);
}

- (KInputBoxRecorderView *)recordView {
    KInputBoxRecorderView *recordView = objc_getAssociatedObject(self, recordViewKey);
    if (!recordView) {
        recordView = [KInputBoxRecorderView shareInstance];
    }
    return recordView;
}

// KVO 监听录音状态变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (self.recordStatus == [change[NSKeyValueChangeNewKey] integerValue]) {
        return;
    }
    
    self.recordStatus = [change[NSKeyValueChangeNewKey] integerValue];
    if (self.recordStatus == KInputBoxRecordStatusRecording) {
        
        self.recordView.recallImageView.hidden = YES;
        self.recordView.hidden = NO;
        self.recordView.leftImageView.hidden  = NO;
        self.recordView.rightImageView.hidden = NO;
        
        // 开始录音
        [self startRecording];
        [self recordStartDrawView];
        
    }
    else if (self.recordStatus == KInputBoxRecordStatusEnd)
    {
        [self.recordView updateState:self.recordStatus];
        // 停止录音
        [self stopRecord];
        if (self.recordTime < 1000) {
            
            [self.recordView updateState:KInputBoxRecordStatusTooShort];
            [self removeVoiceMessage];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.recordStatus == KInputBoxRecordStatusTooShort) {
                    self.recordView.hidden = YES;
                    [self.recordView updateState:KInputBoxRecordStatusNone];
                }
            });
            return;
        }
        
        self.recordView.hidden = YES;
        
        [self replaceVoiceMessage];
    }
    else if (self.recordStatus == KInputBoxRecordStatusCancel) {
        // 停止录音
        [self stopRecord];
        self.recordView.hidden = YES;
        [self removeVoiceMessage];
        
    }
    else {
        // 移进或移除
        [self.recordView updateState:self.recordStatus];
    }
}

/**
 录音部分初始化
 */
- (void)initVoiceData {
    self.recordView = [KInputBoxRecorderView shareInstance];
    self.recordSetting = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         [NSNumber numberWithFloat: 44100.0],AVSampleRateKey,
                         [NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                         [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                         [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                         [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                         [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,nil];
}

/**
 开始录音
 */
- (void)startRecording {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recordView setHidden:NO];
        [self.recordView.rightImageView setHidden:NO];
        [self.recordView.leftImageView setHidden:NO];
        [self.recordView.recallImageView setHidden:YES];
        // 先停止语音播放
        [self.audioPlayer stop];
        [self.voiceImageView stopAnimating];
        self.lastPlayVoiceIndex = -1;
    });
    
    kWeakSelf;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        weakSelf.recordTime = 0;
        [weakSelf.timer invalidate];
        weakSelf.timer = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateRecordTime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [self.timer fire];
        });
        
        weakSelf.audioSession = [AVAudioSession sharedInstance];
        [weakSelf.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        // 不存在就去请求加载
        NSString *recorderTime = [NSDate getCurrentTimestamp];
        NSString *foldName = [NSString stringWithFormat:@"%@.aac", recorderTime];
        
        weakSelf.audioUrl = [KAttachmentTempPath stringByAppendingPathComponent:foldName];
        
        NSError *error = nil;
        weakSelf.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:weakSelf.audioUrl] settings:weakSelf.recordSetting error:&error];
        [weakSelf.audioRecorder prepareToRecord];
        
        weakSelf.audioRecorder.meteringEnabled = YES;
        if ([weakSelf.audioRecorder prepareToRecord] == YES) {
            weakSelf.audioRecorder.meteringEnabled = YES;
            [weakSelf.audioRecorder record];
        }
    });
}

/**
 停止录音
 */
- (void)stopRecord {
    
    [self.audioRecorder stop];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"停止录音");
        [self.timer invalidate];
        self.timer = nil;
    });
    
}

/**
 更新录音时间，并获取输入分贝大小
 */
- (void)updateRecordTime {
    self.recordTime += 100;
    [self.recordView updateSecond:self.recordTime];
    
    if (self.recordTime == MAX_VOICE_LENGTH) {
        [self stopRecord];
        [self replaceVoiceMessage];
        [self.recordView updateState:KInputBoxRecordStatusNone];
        self.recordView.hidden = YES;
    }
    [self.audioRecorder updateMeters];
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels    = [self.audioRecorder averagePowerForChannel:0];
    
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    level = level * 120;
    /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger value = (int)(self.recordTime * 10)%200;
        if (value == 0) {
            int index = (int)ceil(level/20.);
            //NSLog(@"声音分贝：%d, level：%f", index, level);
            NSString *imageName = [NSString stringWithFormat:@"icon_inputBox_recorder_prompt%d", index];
            self.recordView.rightImageView.image = [UIImage imageNamed:imageName];
        }
    });
}


/**
 点击消息播放语音
 
 @param tableViewCell cell
 @param messageModel 语音数据
 */
- (void)playAudioWithTableViewCell:(id)tableViewCell messageModel:(KMessageModel *)messageModel {
    
    KChatVoiceTableViewCell *cell = tableViewCell;
    UIImageView *voiceImageView = cell.voiceImageView;
    if (self.voiceImageView) {
        [self.voiceImageView stopAnimating];
    }
    self.voiceImageView = voiceImageView;
    // 播放音频文件
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    if (messageModel.fileData) {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:messageModel.fileData error:nil];
        [self audioPlayerSetting];
    }
    else if (messageModel.content != nil) {
        
        NSString *voicePath = messageModel.content;
        if ([voicePath containsString:@"/storage/msgs/"]) {
            NSString *voicePath1 = [kDocDir stringByAppendingPathComponent:voicePath];
            NSData *audioData = [[NSData alloc] initWithContentsOfFile:voicePath1];
            self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
            [self audioPlayerSetting];
        }
        else {
            kWeakSelf;
            [[KFileCache shareInstance] fileUrl:messageModel.content type:@"aac" saveComplete:^(NSString *filePath, NSURL *url, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSData *audioData = [[NSData alloc] initWithContentsOfFile:filePath];
                    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
                    [weakSelf audioPlayerSetting];
                });
            }];
        }
    }
}

- (void)audioPlayerSetting {
    self.audioPlayer.delegate = self;
    
    self.audioPlayer.numberOfLoops = 0;
    self.audioPlayer.volume = 1;
    
    [self.voiceImageView startAnimating];
    
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

#pragma mark AVAudioPlayerDelegate
// 播放完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.voiceImageView stopAnimating];
    self.lastPlayVoiceIndex = -1;
}

/**
 绘制页面
 */
- (void)recordStartDrawView {
    kWeakSelf;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        recordFinished                 = NO;
        weakSelf.recordIndexPathRow    = weakSelf.dataSource.count;
        
        KMessageModel *audioMessage    = [[KMessageModel alloc] init];
        audioMessage.msgType           = KMessageTypeVoice;
        audioMessage.messageChatType   = KMessageChatTypeSingle;
        audioMessage.direction         = KMessageSenderTypeSender;
        audioMessage.messageReadStatus = KMessageReadStatusRead;
        audioMessage.messageSendStatus = KMessageSendStatusSendSuccess;
        audioMessage.duringTime        = 0;
        audioMessage.sendTime          = [NSDate getCurrentTimestamp];
        audioMessage.recvTime          = [NSDate getCurrentTimestamp];
        audioMessage.fromUserId        = KXINIUID;
        
        weakSelf.prevMessage               = [weakSelf lastMessage];
        BOOL isShowTime = [weakSelf isShowTimeWithNewMessageModel:audioMessage previousMessage:weakSelf.prevMessage];
        audioMessage.showMessageTime   = isShowTime;
        audioMessage.cellHeight        = isShowTime ? 90 : 60;
        
        [weakSelf addMessage:audioMessage];
    });
}

- (void)replaceVoiceMessage
{
    if (!recordFinished)
    {
        recordFinished = YES;
        [self.recordView updateState:KInputBoxRecordStatusNone];
        
        kWeakSelf
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            if (weakSelf.recordTime < 1000) {
                [weakSelf stopRecord];
                [weakSelf removeVoiceMessage];
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                KChatVoiceTableViewCell *cell = [self.listView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.recordIndexPathRow inSection:0]];
                cell.second.text = [NSString stringWithFormat:@"%d\"",(int)ceil(self.recordTime) / 1000];
                cell.voiceImageView.hidden = NO;
            
            });
            
            NSData *audioData = [[NSData alloc] initWithContentsOfFile:weakSelf.audioUrl];
            
            NSString *timestamp = [NSDate getCurrentTimestamp];
            KMessageModel *audioMessage    = weakSelf.dataSource[weakSelf.recordIndexPathRow];
            audioMessage.messageSendStatus = KMessageSendStatusSending;
            audioMessage.duringTime        = (int)ceil(weakSelf.recordTime);
            audioMessage.fileData          = audioData;
            audioMessage.sendTime          = timestamp;
            audioMessage.recvTime          = timestamp;
            audioMessage.messageId         = timestamp;
            audioMessage.fromUserId        = KXINIUID;
            
            __block CGSize msgSize;
            [audioMessage messageProcessingWithFinishedCalculate:^(CGFloat rowHeight, CGSize messageSize, BOOL complete) {
                msgSize = messageSize;
            }];
            
            weakSelf.isEnterSend = NO;
            
            [weakSelf.dataSource replaceObjectAtIndex:weakSelf.recordIndexPathRow withObject:audioMessage];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.listView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.recordIndexPathRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf scrollTableViewBottom];
            
            });
            
//            向服务端发消息
        });
    }
}

- (void)removeVoiceMessage {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recordView updateState:KInputBoxRecordStatusNone];
        if (self.recordIndexPathRow < self.dataSource.count) {
            KMessageModel *messageModel = self.dataSource[self.recordIndexPathRow];
            self.recordIndexPathRow = -1;
            [self removeLastMessage:messageModel];
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.recordIndexPathRow < self.dataSource.count) {
                    KMessageModel *messageModel = self.dataSource[self.recordIndexPathRow];
                    [self removeLastMessage:messageModel];
                }
                else {
                    NSInteger maxCount = self.dataSource.count > 2 ? self.dataSource.count - 2 : 0;
                    for (NSInteger i = self.dataSource.count - 1; i > maxCount; i --) {
                        KMessageModel *messageModel = self.dataSource[i];
                        if (messageModel.msgType == KMessageTypeVoice) {
                            if (messageModel.duringTime == 0) {
                                [self removeLastMessage:messageModel];
                            }
                        }
                        else {
                            break;
                        }
                    }
                }
                self.recordIndexPathRow = -1;
            });
        }
    });
}

@end
