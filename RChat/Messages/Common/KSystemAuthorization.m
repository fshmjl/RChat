//
//  KSystemAuthorization.m
//  KXiniuCloud
//
//  Created by RPK on 2018/7/4.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+KCategory.h"

#import "KSystemAuthorization.h"

static KSystemAuthorization *systemAuth = nil;

@implementation KSystemAuthorization

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemAuth = [super allocWithZone:NULL];
    });
    return systemAuth;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [KSystemAuthorization shareInstance];
}

/**
 获取相机

 @return 是否授权
 */
- (BOOL)checkCameraAuthorization {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL isAuthorization = NO;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined || authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        isAuthorization = NO;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            isAuthorization = granted;
            dispatch_semaphore_signal(semaphore);
        }];
    }
    else {
        isAuthorization = YES;
        dispatch_semaphore_signal(semaphore);
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return isAuthorization;
}

/**
 获取语音授权

 @return 是否授权
 */
- (BOOL)checkAudioAuthrization {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL isAuthorization = YES;
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (audioAuthStatus == AVAuthorizationStatusRestricted || audioAuthStatus == AVAuthorizationStatusNotDetermined || audioAuthStatus == AVAuthorizationStatusDenied)
    {
        isAuthorization = NO;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            isAuthorization = granted;
            dispatch_semaphore_signal(semaphore);
        }];
    }
    else {
        isAuthorization = YES;
        dispatch_semaphore_signal(semaphore);
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return isAuthorization;
}

/**
 获取访问相册权限

 @return 是否授权
 */
- (BOOL)checkPhotoAlbumAuthorization {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL isAuthorization = NO;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
         {
             if (status == PHAuthorizationStatusAuthorized)
             {
                 // 授权成功或已授权
                 isAuthorization = YES;
                 dispatch_semaphore_signal(semaphore);
             }else{
                 isAuthorization = NO;
                 NSLog(@"Denied or Restricted");
                 //----为什么没有在这个里面进行权限判断，因为会项目会蹦。。。
                 dispatch_semaphore_signal(semaphore);
                 return;
             }
         }];
    }
    else if (status == PHAuthorizationStatusDenied)
    {
    
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"权限选择" message:@"拍摄需要访问你的相册权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
        
        UIAlertAction *setting = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requetSettingForAuth];
            });
        }];
        
        [alertController addAction:cancel];
        [alertController addAction:setting];
        UIViewController *currentVC = [[UIViewController new] getCurrentVC];
        [currentVC presentViewController:alertController animated:YES completion:nil];
        isAuthorization = NO;
        dispatch_semaphore_signal(semaphore);
        //return;
    }
    else {
        isAuthorization = YES;
        dispatch_semaphore_signal(semaphore);
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return isAuthorization;
}

/**
 跳转到设置页面
 */
- (void)requetSettingForAuth {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
