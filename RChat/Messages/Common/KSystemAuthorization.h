//
//  KSystemAuthorization.h
//  KXiniuCloud
//
//  Created by RPK on 2018/7/4.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface KSystemAuthorization : NSObject
// 单例实例
+ (instancetype)shareInstance;

/**
 获取相机权限
 
 @return 是否授权
 */
- (BOOL)checkCameraAuthorization;

/**
 获取语音权限

 @return 是否授权
 */
- (BOOL)checkAudioAuthrization;

/**
 获取访问相册权限
 
 @return 是否授权
 */
- (BOOL)checkPhotoAlbumAuthorization;

/**
 跳转到设置页面
 */
- (void)requetSettingForAuth;

@end
