//
//  UIImage+Compression.m
//  KXiniuCloud
//
//  Created by RPK on 2018/6/26.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "UIImage+Compression.h"

@implementation UIImage (Compression)

/**
 压缩图片到指定大小
 @param maxLength 设置的最大字节数(以KB为单位)
 @return 返回图片
 */
- (NSData *)compressImageWithKilobyte:(NSInteger)maxLength
{
    CGFloat compression = 1;
    maxLength *= 1024;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    NSString *sizeStr = [NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile];
    
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
        
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    
    sizeStr = [NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile];
    
    return data;
}

/**
 *  压缩图片
 *
 *  @param fImageKBytes 希望压缩后的大小(以KB为单位)
 */
- (void)compressedWithImageKilobyte:(CGFloat)fImageKBytes
                      imageBlock:(void(^)(NSData *imageData))block {
    
    __block UIImage *imageCope = self;
    CGFloat fImageBytes = fImageKBytes * 1024;//需要压缩的字节Byte
    
    __block NSData *uploadImageData = nil;
    
    uploadImageData = UIImagePNGRepresentation(imageCope);
    NSLog(@"图片压前缩成 %fKB",uploadImageData.length/1024.0);
    CGSize size = imageCope.size;
    CGFloat imageWidth = size.width;
    CGFloat imageHeight = size.height;
    
    if (uploadImageData.length > fImageBytes && fImageBytes > 0) {
        
        dispatch_async(dispatch_queue_create("CompressedImage", DISPATCH_QUEUE_SERIAL), ^{
            
            /* 宽高的比例 **/
            // CGFloat ratioOfWH = 1;
            /* 压缩率 **/
            CGFloat compressionRatio = fImageBytes/uploadImageData.length;
            /* 宽度或者高度的压缩率 **/
            CGFloat widthOrHeightCompressionRatio = sqrt(compressionRatio);
            
            CGFloat dWidth   = imageWidth *widthOrHeightCompressionRatio;
            CGFloat dHeight  = imageHeight*widthOrHeightCompressionRatio;
            
            imageCope = [self drawWithNewImageSize:CGSizeMake(dWidth, dHeight)];
            uploadImageData = UIImagePNGRepresentation(imageCope);
            
            //微调
            NSInteger compressCount = 0;
            /* 控制在 1M 以内**/
            while (fabs(uploadImageData.length - fImageBytes) > 1024) {
                /* 再次压缩的比例**/
                CGFloat nextCompressionRatio = 0.9;
                
                if (uploadImageData.length > fImageBytes) {
                    dWidth = dWidth*nextCompressionRatio;
                    dHeight= dHeight*nextCompressionRatio;
                }else {
                    dWidth = dWidth/nextCompressionRatio;
                    dHeight= dHeight/nextCompressionRatio;
                }
                
                imageCope = [self drawWithNewImageSize:CGSizeMake(dWidth, dHeight)];
                uploadImageData = UIImagePNGRepresentation(imageCope);
                
                /*防止进入死循环**/
                compressCount ++;
                if (compressCount == 10) {
                    break;
                }
                
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                block(uploadImageData);
            });
        });
    }
    else
    {
        block(uploadImageData);
    }
}

- (NSData *)compressedWithImageKilobyte:(CGFloat)fImageKBytes
{
    __block UIImage *imageCope = self;
    CGFloat fImageBytes = fImageKBytes * 1024;  // 需要压缩的字节Byte
    
    __block NSData *uploadImageData = nil;
    
    uploadImageData = UIImagePNGRepresentation(imageCope);
    
    CGSize size = imageCope.size;
    CGFloat imageWidth = size.width;
    CGFloat imageHeight = size.height;
    
    if (uploadImageData.length > fImageBytes && fImageBytes > 0) {
        
        /* 宽高的比例 **/
        // CGFloat ratioOfWH = 1;
        /* 压缩率 **/
        CGFloat compressionRatio = fImageBytes/uploadImageData.length;
        /* 宽度或者高度的压缩率 **/
        CGFloat widthOrHeightCompressionRatio = sqrt(compressionRatio);
        
        CGFloat dWidth   = imageWidth *widthOrHeightCompressionRatio;
        CGFloat dHeight  = imageHeight*widthOrHeightCompressionRatio;
        
        imageCope = [self drawWithNewImageSize:CGSizeMake(dWidth, dHeight)];
        uploadImageData = UIImagePNGRepresentation(imageCope);
        
        //微调
        NSInteger compressCount = 0;
        /* 控制在 1M 以内**/
        while (fabs(uploadImageData.length - fImageBytes) > 1024) {
            /* 再次压缩的比例**/
            CGFloat nextCompressionRatio = 0.9;
            
            if (uploadImageData.length > fImageBytes) {
                dWidth = dWidth*nextCompressionRatio;
                dHeight= dHeight*nextCompressionRatio;
            }else {
                dWidth = dWidth/nextCompressionRatio;
                dHeight= dHeight/nextCompressionRatio;
            }
            
            imageCope = [self drawWithNewImageSize:CGSizeMake(dWidth, dHeight)];
            uploadImageData = UIImagePNGRepresentation(imageCope);
            
            /*防止进入死循环**/
            compressCount ++;
            if (compressCount == 10) {
                break;
            }
        }
        
        return uploadImageData;
    }
    else
    {
        return uploadImageData;
    }
}

/* 根据 dWidth dHeight 返回一个新的image**/
- (UIImage *)drawWithNewImageSize:(CGSize)imageSize {
    
    UIImage *imageCope = self;
    UIGraphicsBeginImageContext(imageSize);
    [imageCope drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    imageCope = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCope;
}


@end
