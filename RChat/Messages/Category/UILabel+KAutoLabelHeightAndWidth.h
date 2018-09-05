//
//  UILabel+KAutoLabelHeightAndWidth.h
//  ShoveCrowdfunding
//
//  Created by RPK on 16/5/6.
//  Copyright © 2016年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (KAutoLabelHeightAndWidth)

/**
 *  自适应获取文本高度
 *
 *  @param width 文本宽度
 *  @param title 文本内容
 *  @param font  字体属性
 *
 *  @return 高度
 */
+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font;

/**
 *  自适应获取宽度
 *
 *  @param title 文本内容
 *  @param font  字体属性
 *
 *  @return 宽度
 */
+ (CGFloat)getWidthWithTitle:(NSString *)title font:(UIFont *)font;



/**
 设置行距、间距，动态获取字符串高度

 @param titleString 文本内容
 @param font 字体属性
 @param width 最大宽度
 @param lineSpace 行距
 @param wordSpace 间距
 @return 高度
 */
+ (CGFloat)getSpaceLabelHeight:(NSString *)titleString font:(UIFont *)font width:(CGFloat)width withLineSpace:(float)lineSpace WordSpace:(float)wordSpace;

/**
 *  改变行间距
 */
+ (void)changeLineSpaceForLabel:(UILabel *)label WithSpace:(float)space;

/**
 *  改变字间距
 */
+ (void)changeWordSpaceForLabel:(UILabel *)label WithSpace:(float)space;

/**
 *  改变行间距和字间距
 */
+ (void)changeSpaceForLabel:(UILabel *)label withLineSpace:(float)lineSpace WordSpace:(float)wordSpace;

@end
