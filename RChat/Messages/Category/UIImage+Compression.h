//
//  UIImage+Compression.h
//  KXiniuCloud
//
//  Created by RPK on 2018/6/26.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compression)

/**
 压缩图片到指定大小
 @param maxLength 设置的最大字节数(以KB为单位)
 @return 返回图片
 */
- (NSData *)compressImageWithKilobyte:(NSInteger)maxLength;
/**
 *  压缩图片
 *
 *  @param fImageKBytes 希望压缩后的大小(以KB为单位)
 */
- (void)compressedWithImageKilobyte:(CGFloat)fImageKBytes
                         imageBlock:(void(^)(NSData *imageData))block;

/**
 压缩图片

 @param fImageKBytes fImageKBytes 希望压缩后的大小(以KB为单位)
 @return 返回处理好的图片
 */
- (NSData *)compressedWithImageKilobyte:(CGFloat)fImageKBytes;

/* 根据 dWidth dHeight 返回一个新的image**/
- (UIImage *)drawWithNewImageSize:(CGSize)imageSize;
@end
