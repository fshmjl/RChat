//
//  KFileManagement.m
//  KXiniuCloud
//
//  Created by RPK on 2017/10/16.
//  Copyright © 2017年 EIMS. All rights reserved.
//

#import "KFileManagement.h"

//#import <MailCore/MCOAbstractPart.h>
#import "NSDate+KCategory.h"

@implementation KFileManagement

/**
 在 Cache 沙盒中创建附件文件夹
 */
+ (void)createDirectoryAtPath:(NSString *)folderPath {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
}

+ (void)saveImageFile:(NSArray *)imagesData {
    
//    // 判断文件夹是否存在
//    if(![[NSFileManager defaultManager] fileExistsAtPath:KAttachmentPath]) {
//        [self createDirectoryAtPath:KAttachmentPath];
//    }
//
//    [imagesData enumerateObjectsUsingBlock:^(MCOAttachment *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *filePath = [KAttachmentPath stringByAppendingPathComponent:obj.filename];
//        [obj.data writeToFile:filePath atomically:YES];
//    }];
}

+ (NSString *)saveImageFileAndGetImages:(NSArray *)imagesData
                                emailId:(NSString *)emailId {
    
//    NSMutableString *resultString = [NSMutableString string];
//    // 判断文件夹是否存在
//    if(![[NSFileManager defaultManager] fileExistsAtPath:KAttachmentTempPath]) {
//        [self createDirectoryAtPath:KAttachmentTempPath];
//    }
//
//    [imagesData enumerateObjectsUsingBlock:^(MCOAttachment *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//        NSString *attachCid = [NSString stringWithFormat:@"%lu", idx + 1];
//
//        NSString *tempPath = [KAttachmentTempPath stringByAppendingPathComponent:obj.filename];
//        [obj.data writeToFile:tempPath atomically:YES];
//        NSString *attachSize = [NSString stringWithFormat:@"%lu", (unsigned long)obj.data.length];
//
//        [KInteractionWrapper saveMailAttachIntroductionWithEmailId:emailId attachCid:attachCid attachSize:attachSize attachName:obj.filename isAttach:YES isDownload:YES block:^(id obj, int errorCode, NSString *errorMsg) {
//
//            if (!errorCode) {
//
//                [KInteractionWrapper saveAttacmentWithEmailId:emailId attachCid:attachCid attachmentJson:tempPath isAttach:YES isPath:YES block:^(id obj, int errorCode, NSString *errorMsg) {
//
//                    if (!errorCode) {
//                        [resultString appendString:obj];
//                    }
//
//                }];
//
//            }else {
//                NSLog(@"保存附件简介失败");
//            }
//
//        }];
//
//        if (idx < imagesData.count - 1) {
//            [resultString appendFormat:@","];
//        }
//
//    }];
    
//    return resultString;
    return @"";
}

/**
 图片的存到本地之后的读取
 */
+ (UIImage *)getImageFile:(NSString *)imageString {
    
    NSString *path      = [kDocDir stringByAppendingPathComponent:imageString];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *picData = [NSData dataWithContentsOfFile:path];
        return [UIImage imageWithData:picData];
    }
    
    return nil;
}

/**
 删除缓存文件
 */
+ (void)deleteCacheAttachments {
//    // 如果存在缓存文件的配置文件
//    if([[NSFileManager defaultManager] fileExistsAtPath:KAttachmentFolderPath])
//    {
//        [[NSFileManager defaultManager] removeItemAtPath:KAttachmentFolderPath error:nil];
//    }
}

/**
 拷贝文件
 
 @param fileName 沙盒路径
 @param sourcesPath 资源路径
 */
+ (BOOL)copyFilePath:(NSString *)fileName sourcesPath:(NSString *)sourcesPath {
    
    // 复制本地数据到沙盒中
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fileName]) {
        
        NSError *error ;
        BOOL isSuccess = [fileManager copyItemAtPath:sourcesPath toPath:fileName error:&error];
        if (isSuccess) {
            return YES;
        }else {
//            NSLog(@"数据拷贝失败");
            return NO;
        }
    }
    
    return YES;
}


@end
