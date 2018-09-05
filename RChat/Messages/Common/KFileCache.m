//
//  KFileCache.m
//  KXiniuCloud
//
//  Created by RPK on 2018/8/14.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KFileCache.h"

#import <AFNetworking.h>

static KFileCache *fileCache = nil;

#define fileCachePath [kDocDir stringByAppendingPathComponent:@"FileCache"]

@implementation KFileCache

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileCache = [[super allocWithZone:NULL] init];
    });
    return fileCache;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [KFileCache shareInstance];
}


/**
 文件缓存

 @param strURL 文件url
 @param type 类型
 @param saveComplete 保存完成
 */
-(void)fileUrl:(NSString *)strURL type:(NSString *)type saveComplete:(SaveComplete)saveComplete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//开个子线程处理图片保存
        [self filePath:strURL fileExists:^(NSString *filePath, BOOL exist) {
            if (!exist) {
                // 没有保存需要下载文件
                [self downloadFileWithURL:strURL
                                  success:^(NSString *requestUrl, NSString *filePath) {
                                    if (saveComplete) {
                                        saveComplete(filePath, [NSURL URLWithString:requestUrl], nil);
                                    }
                                  }
                                  failure:^(NSString *requestUrl, NSError *error) {
                                    if (saveComplete) {
                                        saveComplete(nil, [NSURL URLWithString:requestUrl], error);
                                    }
                                  }];
            }
            else {
                saveComplete(filePath, [NSURL URLWithString:strURL], nil);
            }
        }];
    });
}


/**
 根据文件url获取是否存在缓存

 @param url 文件url
 @param fileExists 回调
 */
-(void)filePath:(NSString *)url fileExists:(WhetherFileExists)fileExists
{
    NSString *fPath = nil;
    if (![url isKindOfClass:[NSNull class]])
    {
        if ([url hasPrefix:@"http"] || [url hasPrefix:@"https"])
        {
            NSArray *arr               = [url componentsSeparatedByString:@"/"];
            BOOL directory             = YES;
            BOOL fDirectory            = YES;
            NSString *fileName         = [arr lastObject];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:fileCachePath isDirectory:&directory])
            {
                [fileManager createDirectoryAtPath:fileCachePath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            fPath = [fileCachePath stringByAppendingPathComponent:fileName];
            if ([fileManager fileExistsAtPath:fPath isDirectory:&fDirectory]) {
                if (fileExists) {
                    // 已经保存或该文件
                    fileExists(fPath, YES);
                }
            }
            else {
                if (fileExists) {
                    // 没有保存过该文件
                    fileExists(fPath, NO);
                }
            }
        }
    }
}


/**
 文件下载

 @param url 文件url
 @param success 成功回调
 @param failure 失败回调
 */
- (void)downloadFileWithURL:(NSString *)url
                    success:(void (^)(NSString *requestUrl, NSString *filePath))success
                    failure:(void (^)(NSString *requestUrl, NSError *error))failure
{
    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    /* 下载地址 */
    NSURL *kUrl = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:kUrl];
    
    /* 下载路径 */
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *kFilePath = [fileCachePath stringByAppendingPathComponent:url.lastPathComponent];
    
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:kFilePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (!error) {
            success(url, kFilePath);
        }
        else {
            failure(url, error);
        }
        NSLog(@"下载完成");
        
    }];
    [downloadTask resume];
    
}




@end
