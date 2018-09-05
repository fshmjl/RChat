//
//  BaseViewController.h
//  ShoveCrowdfunding
//
//  Created by RPK on 16/4/28.
//  Copyright © 2015年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

/**
 权限设置

 @param title 提示标题
 @param message 提示内容
 @param block 回调
 */
- (void)settingAuthorizationWithTitle:(NSString *)title message:(NSString *)message cancel:(void (^)(BOOL))block;

@end
