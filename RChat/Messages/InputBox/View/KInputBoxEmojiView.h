//
//  KInputBoxEmojiView.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/10.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KInputBoxViewDelegate.h"
#import "KInputBoxEmojiMenuView.h"

@interface KInputBoxEmojiView : UIView

@property (nonatomic, assign) id<KInputBoxViewDelegate> delegate;
// 表情菜单
@property (nonatomic, strong) KInputBoxEmojiMenuView    *menuView;

@end
