//
//  KProgressView.h
//  KXiniuCloud
//
//  Created by RPK on 2018/2/6.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KProgressView : UIView

+ (instancetype)shareInstance;

- (void)setupProgressUI;

- (void)setPressSlider:(float)value;

@end
