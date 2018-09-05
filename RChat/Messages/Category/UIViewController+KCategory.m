
//
//  UIViewController+KCategory.m
//  KXiniuCloud
//
//  Created by RPK on 2018/6/30.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "UIViewController+KCategory.h"



@implementation UIViewController (KCategory)


//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

@end
