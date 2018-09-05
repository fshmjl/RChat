//
//  KChatVideoTableViewCell.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/16.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KChatTableViewCell.h"

@interface KChatVideoTableViewCell : KChatTableViewCell
// 录制时长
@property (nonatomic, strong) UILabel     *recordTime;
// 视频缩略图
@property (nonatomic, strong) UIImageView *videoImageView;
// 播放图片
@property (nonatomic, strong) UIImageView *playImageView;

@end
