//
//  KProgressView.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/15.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KVideoProgressView : UIView

/**
 视频总时长
 */
@property (assign, nonatomic) NSInteger timeMax;


/**
 清除进度
 */
- (void)clearProgress;

@end
