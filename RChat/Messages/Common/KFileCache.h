//
//  KFileCache.h
//  KXiniuCloud
//
//  Created by RPK on 2018/8/14.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SaveComplete)(NSString *filePath, NSURL *url, NSError *error);
typedef void(^WhetherFileExists)(NSString *filePath, BOOL exist);

@interface KFileCache : NSObject

+ (instancetype)shareInstance;

/**
 文件缓存
 
 @param strURL 文件url
 @param type 类型
 @param saveComplete 保存完成
 */
-(void)fileUrl:(NSString *)strURL type:(NSString *)type saveComplete:(SaveComplete)saveComplete;

/**
 根据文件url获取是否存在缓存
 
 @param url 文件url
 @param fileExists 回调
 */
-(void)filePath:(NSString *)url fileExists:(WhetherFileExists)fileExists;


/**
 文件下载
 
 @param url 文件url
 @param success 成功回调
 @param failure 失败回调
 */
- (void)downloadFileWithURL:(NSString *)url
                    success:(void (^)(NSString *requestUrl, NSString *filePath))success
                    failure:(void (^)(NSString *requestUrl, NSError *error))failure;


@end
