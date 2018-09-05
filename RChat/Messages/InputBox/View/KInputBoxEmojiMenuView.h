//
//  KInputBoxEmojiMenuView.h
//  KXiniuCloud
//
//  Created by eims on 2018/4/28.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KInputBoxViewDelegate.h"

@interface KInputBoxEmojiMenuView : UIView
// 添加表情按钮
@property (nonatomic, strong) UIButton *addButton;
// 发送表情按钮
@property (nonatomic, strong) UIButton *sendButton;
// 输入框下面的菜单视图
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *lastSelectEemojiGroup;

@property (nonatomic, assign) id<KInputBoxViewDelegate> delegate;

@end
