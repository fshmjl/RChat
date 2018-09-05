//
//  KInputBoxMoreItemView.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/7.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KInputBoxMoreItemView : UIView

/**
 更多视图中的所有视图
 */
@property (nonatomic, strong) NSMutableArray *moreUnitViews;

/**
 显示视图

 @param fromIndex 开始位置
 @param count 结束位置
 */
- (void)showEmojiGroupDetailFromIndex:(NSInteger)fromIndex count:(NSInteger)count;

@end
