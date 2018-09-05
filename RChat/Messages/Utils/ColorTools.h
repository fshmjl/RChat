//
//  ColorTools.h
//  ShoveSAS
//
//  Created by RPK on 16/5/16.
//  Copyright © 2016年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIColor;

//设置RGB颜色值
#define SETCOLOR(R,G,B,A)	[UIColor colorWithRed:(CGFloat)R/255 green:(CGFloat)G/255 blue:(CGFloat)B/255 alpha:A]

#define KColor                      SETCOLOR(58,164,249,1.0)
#define KBGColor                    SETCOLOR(238,238,240,1.0)
#define KBGColor1                   SETCOLOR(245,246,248,1.0)
#define KNavigationColor            SETCOLOR(250,250,250,1.0)
#define KNavigationRedColor         SETCOLOR(251,59,67,1.0)

#define KLineColor                  SETCOLOR(230,230,230,1.0)
#define KSheetViewBGColor           SETCOLOR(244,244,244,1.0)
// 分段控制器选中颜色
#define kSegmentItemColor           SETCOLOR(251, 25, 8, 1)

// UITabbar title TintColor
#define KTabarTitleTintColor        [ColorTools colorWithHexString:@"#ff2e3e"]

// 左视图
#define KMailTableViewCellTextColor         [UIColor blackColor]
#define KMailLeftTableViewCellSelectColor   SETCOLOR(255,47,63,.8)

// 登录界面
#define KBlueColor                  SETCOLOR(53,141,255,1.0)

#define KHex16Color1                [ColorTools colorWithHexString:@"#333333"]
#define KHex16Color2                [ColorTools colorWithHexString:@"#666666"]
#define KHex16Color3                [ColorTools colorWithHexString:@"#999999"]
#define KHex16Color4                [ColorTools colorWithHexString:@"#F4F4F4"]  // 线条色

/// 手势圆圈的颜色
#define KCircleErrorColor           UIColorFrom16RGB(0xFF0033, 1.0)
#define KCircleNormalColor          UIColorFrom16RGB(0x33CCFF, 1.0)
#define KCircleSelectedColor        UIColorFrom16RGB(0x3393F2, 1.0)

/// 根据16位RBG值转换成颜色，格式:UIColorFrom16RGB(0xFF0000)
#define UIColorFrom16RGB(rgbValue, alp) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alp]

/// 根据10位RBG值转换成颜色, 格式:UIColorFrom10RGB(255,255,255)
#define UIColorFrom10RGB(RED, GREEN, BLUE, alp) [UIColor colorWithRed:RED/255.0 green:GREEN/255.0 blue:BLUE/255.0 alpha:alp]

@interface ColorTools : NSObject

/** 颜色转换 IOS中十六进制的颜色转换为UIColor **/
+ (UIColor *) colorWithHexString: (NSString *)color;

@end
