//
//  UIImage+KVideo.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/16.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (KVideo)

/**
 获取视频地址缩略图
 
 @param videoURL 视频地址
 @return 缩略图
 */
+ (UIImage *)imageWithVideo:(NSURL *)videoURL;

@end
