//
//  KInputBoxRecorderView.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/7.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface KInputBoxRecorderView : UIView

@property (nonatomic, strong) UIImageView *leftImageView;

@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) UIImageView *recallImageView;

@property (nonatomic, strong) UILabel     *secondLabel;      /**显示10秒倒计时*/
// 提示
@property (nonatomic, strong) UILabel     *prompt;

@property (nonatomic, strong) NSTimer     *timer;            /**定时器*/


/**
 语音录音按钮提示框
 */
+ (instancetype)shareInstance;

/**
 通过录音时手势的状态更新提示消息

 @param state 手势状态
 */
- (void)updateState:(KInputBoxRecordStatus)state;

- (void)updateSecond:(NSInteger)second;

@end
