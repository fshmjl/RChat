//
//  BAPhoto.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/17.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KPhoto : NSObject
// 默认图
@property (nonatomic, strong) UIImage  *defaultImage;
// 缩略图url
@property (nonatomic, strong) NSString *thumbUrl;
// 高清图片url
@property (nonatomic, strong) NSString *imageUrl;
// 视频url
@property (nonatomic, strong) NSString *videoUrl;

- (BOOL)isEmpty;
- (BOOL)isVideo;

@end
