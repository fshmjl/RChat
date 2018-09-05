//
//  KFileManagement.h
//  KXiniuCloud
//
//  Created by RPK on 2017/10/16.
//  Copyright © 2017年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFileManagement : NSObject

/**
 在 Cache 沙盒中创建文件夹

 @param folderPath 文件夹名称
 */
+ (void)createDirectoryAtPath:(NSString *)folderPath;

/**
 将图片存储到本地
 */
+ (void)saveImageFile:(NSArray *)imagesData;

/**
 储存本地图片附件，并获取存储后的相对路径（,分割）

 @param imagesData  图片数组
 @param emailId     邮件ID
 @return 储存后的相对路径
 */
+ (NSString *)saveImageFileAndGetImages:(NSArray *)imagesData
                                emailId:(NSString *)emailId;

/**
 图片的存到本地之后的读取
 */
+ (UIImage *)getImageFile:(NSString *)imageString;

/**
 删除缓存图片
 */
+ (void)deleteCacheAttachments;

/**
 拷贝文件
 
 @param fileName 沙盒路径
 @param sourcesPath 资源路径
 */
+ (BOOL)copyFilePath:(NSString *)fileName sourcesPath:(NSString *)sourcesPath;

@end
