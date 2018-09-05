//
//  UIImage+KVideo.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/16.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "UIImage+KVideo.h"

#import <AVFoundation/AVFoundation.h>

@implementation UIImage (KVideo)


/**
 获取视频地址缩略图

 @param videoURL 视频地址
 @return 缩略图
 */
+ (UIImage *)imageWithVideo:(NSURL *)videoURL {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return thumb;
}



@end
