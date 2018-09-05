//
//  KChatViewController+Image.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/11.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KChatViewController+Image.h"

#import <Photos/Photos.h>
#import "UIImage+KVideo.h"
#import "NSDate+KCategory.h"
#import "NSDictionary+Json.h"
#import "UIImage+Compression.h"

#import "KMessageModel.h"
#import "KFileManagement.h"
#import "KConversationModel.h"
#import "KVideoViewController.h"
#import "KSystemAuthorization.h"
#import "TZImagePickerController.h"

@implementation KChatViewController (Image)

// 相册选择照片
- (void)selectPhoto
{
    if ([[KSystemAuthorization shareInstance] checkPhotoAlbumAuthorization]) {
        [self selectPhotoAcation];
    }
}

- (void)selectPhotoAcation
{
    TZImagePickerController *pickerController = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    pickerController.allowPickingVideo = NO;
    pickerController.allowPickingGif   = YES;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

// 拍摄
- (void)takePhoto
{
    KSystemAuthorization *authorization = [KSystemAuthorization shareInstance];
    BOOL isAuthAudio = [authorization checkAudioAuthrization];
    BOOL isAuthCamera = [authorization checkCameraAuthorization];
    if (!isAuthAudio || !isAuthCamera) {
        BOOL isFirst = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstSetting"];
        if (isFirst) {
            [self settingAuthorizationWithTitle:@"权限设置" message:@"拍摄需要访问你的相机及麦克风权限" cancel:^(BOOL cancel) { }];
        }
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstSetting"];
        return;
    }
    [self takePhotoAction];
}

- (void)takePhotoAction
{
    KVideoViewController *takePhoto = [[KVideoViewController alloc] init];
    // 视频的最长时间限制
    takePhoto.maxDuration = 10;
    takePhoto.takeBlock = ^(id item, NSString *filePath) {
        
        if ([item isKindOfClass:[NSURL class]]) {
            
            [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"暂不支持视频功能"];

//            NSURL *videoURL = item;
//
//            NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
//            AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];  // 初始化视频媒体文件
//            int second = (int)urlAsset.duration.value / (int)urlAsset.duration.timescale; // 获取视频总时长,单位秒
//
//            // 视频url
//            KMessageModel *messageModel    = [[KMessageModel alloc] init];
//            messageModel.msgType           = KMessageTypeVideo;
//            messageModel.messageChatType   = KMessageChatTypeSingle;
//            messageModel.direction         = KMessageSenderTypeSender;
//            messageModel.messageReadStatus = KMessageReadStatusRead;
//
//            messageModel.content           = videoURL;
//            messageModel.duringTime        = second;
//            messageModel.toUserName           = @"小米";
//            messageModel.sendTime          = [NSDate getCurrentTimestamp];
//            messageModel.lastMessage       = [self lastMessage];
//            messageModel.fromUserId        = KXINIUID;
//
//            [self addMessage:messageModel];
            
        } else {
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                self.isEnterSend = NO;
                // 图片
                UIImage *takeImage             = item;
                NSData *originalImageData      = UIImagePNGRepresentation(takeImage);
                
                __block KMessageModel *messageModel    = [KMessageModel new];
                NSString *timeInterval = [NSDate getCurrentTimestamp];
                
                messageModel.msgType           = KMessageTypeImage;
                messageModel.messageChatType   = KMessageChatTypeSingle;
                messageModel.direction         = KMessageSenderTypeSender;
                messageModel.messageReadStatus = KMessageReadStatusRead;
                messageModel.sendTime          = timeInterval;
                messageModel.recvTime          = timeInterval;
                messageModel.lastMessage       = [self lastMessage];
                messageModel.messageId         = timeInterval;
                messageModel.fileData          = originalImageData;
                messageModel.fromUserId        = KXINIUID;
                messageModel.messageSendStatus = KMessageSendStatusSending;
                
                BOOL isShowTime                = [self isShowTimeWithNewMessageModel:messageModel previousMessage:[self lastMessage]];
                
                messageModel.showMessageTime   = isShowTime;
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count inSection:0];
                kWeakSelf;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{

                    [messageModel messageProcessingWithFinishedCalculate:^(CGFloat rowHeight, CGSize messageSize, BOOL complete) {
                        
                        [weakSelf addMessage:messageModel];
                        messageModel.content = filePath;
                        [weakSelf saveAndSendMessageWithMessageModel:messageModel filePath:filePath indexPath:indexPath cellHeight:rowHeight selectImage:takeImage];
                    }];
                });
                
            });
        }
    };
    
    [self presentViewController:takePhoto animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingPhotos:(NSArray<UIImage *> *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    dispatch_queue_t queue        = dispatch_queue_create("sendImage", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t drawQueue    = dispatch_queue_create("draw", DISPATCH_QUEUE_SERIAL);
    self.isEnterSend              = NO;
    
    NSMutableArray *messageModels = [NSMutableArray array];
    NSMutableArray *indexPaths    = [NSMutableArray array];
    NSMutableArray *cellHeights   = [NSMutableArray array];
    NSMutableArray *imagePaths    = [NSMutableArray array];
    
    NSInteger currentCount        = self.dataSource.count;
    
    dispatch_group_t group        =  dispatch_group_create();
    dispatch_group_async(group, drawQueue, ^{
        
        for (UIImage *selectImage in photos) {
        
            NSData *originalImageData = UIImagePNGRepresentation(selectImage);
            
            NSString *fileName = [NSString stringWithFormat:@"%@.png", [NSDate getCurrentTimestamp]];
            NSString *imagePath = [KAttachmentTempPath stringByAppendingPathComponent:fileName];
            [imagePaths addObject:imagePath];
            
            BOOL isWriteSuccess = [originalImageData writeToFile:imagePath atomically:YES];
            if (!isWriteSuccess) {
                NSLog(@"图片保存到临时文件失败 -> %@", imagePath);
            }
            
            __block CGFloat cellHeight = 0;
            __block KMessageModel *messageModel    = [[KMessageModel alloc] init];
            NSString *timeInterval = [NSDate getCurrentTimestamp];
            
            messageModel.msgType           = KMessageTypeImage;
            messageModel.fromUserId        = KXINIUID;
            messageModel.toUserName        = self.conversation.conversationName;
            messageModel.messageChatType   = KMessageChatTypeSingle;
            messageModel.messageSendStatus = KMessageSendStatusSending;
            messageModel.direction         = KMessageSenderTypeSender;
            messageModel.sendTime          = timeInterval;
            messageModel.lastMessage       = [self lastMessage];
            messageModel.messageId         = timeInterval;
            messageModel.recvTime          = timeInterval;
            messageModel.fileData          = originalImageData;
            
            BOOL isShowTime                = [self isShowTimeWithNewMessageModel:messageModel previousMessage:[self lastMessage]];
            
            messageModel.showMessageTime   = isShowTime;
            
            [messageModels addObject:messageModel];
            
            kWeakSelf;
            [messageModel messageProcessingWithFinishedCalculate:^(CGFloat rowHeight, CGSize messageSize, BOOL complete) {
                cellHeight = rowHeight;
                [indexPaths  addObject:@(self.dataSource.count)];
                [cellHeights addObject:@(cellHeight)];
                
                [weakSelf addMessage:messageModel];
            }];
        }
    });
    
    kWeakSelf
    dispatch_group_notify(group, queue, ^{
        
        while (currentCount + photos.count > weakSelf.dataSource.count) {
            [NSThread sleepForTimeInterval:0.001];
        }
        
        for (int i = 0; i < photos.count; i ++) {
            
            KMessageModel *messageModel = messageModels[i];
            messageModel.fileUrl   = imagePaths[i];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[indexPaths[i] integerValue] inSection:0];
            UIImage *selectImage = photos[i];
            CGFloat cellHeight = [cellHeights[i] floatValue];
            [weakSelf saveAndSendMessageWithMessageModel:messageModel filePath:messageModel.fileUrl indexPath:indexPath cellHeight:cellHeight selectImage:selectImage];
        }
    });
}

/**
 保存并发送消息

 @param messageModel 消息模块
 @param filePath 文件路径
 @param indexPath 列表索引
 @param cellHeight 行高
 @param selectImage 选择的图片
 */
- (void)saveAndSendMessageWithMessageModel:(KMessageModel *)messageModel
                                  filePath:(NSString *)filePath
                                 indexPath:(NSIndexPath *)indexPath
                                cellHeight:(CGFloat)cellHeight
                               selectImage:(UIImage *)selectImage
{
//    向服务端发消息
//    kWeakSelf
     // 保存并发送消息
//    [self saveMessageWithContent:filePath cellHeight:cellHeight messageSize:messageModel.messageSize messageType:KMessageTypeImage filePath:filePath messageModel:messageModel indexPath:indexPath saveResult:^(BOOL isSuccess, NSDictionary *jsonDic, NSString *localMsgId)
//    {
//        if (!isSuccess) {
//            NSLog(@"保存本地图片消息失败");
//            return ;
//        }
//
//        NSData *imgData = [selectImage compressImageWithKilobyte:100];
//
//        // 向文件服务器上传文件
////        [KInteractionWrapper uploadFileToFileServerWithData:imgData fileName:@"png" block:^(NSString *url, int errorCode, NSString *errorMsg)
////        {
////            if (!errorCode)
////            {
////                messageModel.messageSendStatus = KMessageSendStatusSending;
////                NSMutableDictionary *msgDic = [NSMutableDictionary dictionaryWithDictionary:jsonDic];
////                msgDic[@"msg"][@"content"] = url;
////                NSString *jsonStr = [msgDic dictionaryTurnJson];
////                [weakSelf sendMessageWithJsonStr:jsonStr localMessageId:localMsgId indexPath:indexPath];
////            }
////            else
////            {
////                // 更新cell视图中的发送状态
////                [weakSelf updateMessageSendStatus:KMessageSendStatusSendFailure
////                                        indexPath:indexPath
////                                   localMessageId:localMsgId
////                                     serversMsgId:localMsgId];
////
////                // 更新本地数据库中的消息发送状态
////                [weakSelf updateDatabaseMessageWithSrcId:localMsgId
////                                                  destId:localMsgId
////                                               sendState:KMessageSendStatusSendFailure];
////            }
////        }];
//    }];
    
    // 延时30ms执行一次
    [NSThread sleepForTimeInterval:0.03];
}

@end
