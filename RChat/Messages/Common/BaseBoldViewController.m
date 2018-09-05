//
//  BaseBoldViewController.m
//  KXiniuCloud
//
//  Created by RPK on 2018/1/20.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "BaseBoldViewController.h"

@interface BaseBoldViewController ()

@end

@implementation BaseBoldViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear :animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.view.backgroundColor = KBGColor;
    // 设置导航栏颜色
    self.navigationController.navigationBar.barTintColor = KNavigationColor;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:KBoldSystemFontOfSize16],NSForegroundColorAttributeName:[UIColor blackColor]}];

    // 自定义替换系统的“<"图标
    [self.navigationController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"nav_back"]];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"nav_back"]];

    // 去掉返回按钮title UIOffsetMake(1, 0)
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(1, 0) forBarMetrics:UIBarMetricsDefault];

    // 设置导航按钮颜色
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    // 设置导航按钮字体
    UIBarButtonItem *barItem = [UIBarButtonItem appearance];
    [barItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
    [barItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} forState:UIControlStateHighlighted];
    //取消手势返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//
//    return UIStatusBarStyleLightContent;
//}

@end
