//
//  KPlayer.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/15.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPlayer : UIView

@property (copy, nonatomic) NSURL *videoUrl;

/**
 短视频预览视图

 @param frame 预览框大小
 @param bgView 需要把视图添加都bgView上
 @param url 视频的url
 @return 预览图层
 */
- (instancetype)initWithFrame:(CGRect)frame withShowInView:(UIView *)bgView url:(NSURL *)url;

/**
 停止播放
 */
- (void)stopPlayer;

@end
