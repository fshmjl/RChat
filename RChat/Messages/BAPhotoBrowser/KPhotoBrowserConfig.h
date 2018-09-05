//
//  KPhotoBrowserConfig.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/17.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#define KPhotoBrowserDebug 1
// 是否开启断言调试模式
#define IsOpenAssertDebug 1
#define KPhotoBrowserVersion @"1.2.0"

/**
 *  进度视图类型类型
 */
typedef NS_ENUM(NSUInteger, KProgressViewMode) {
    KProgressViewModeLoopDiagram = 0,   // 圆环形
    KProgressViewModePieDiagram         // 圆饼型
};

/**
 *  图片浏览器的样式
 */
typedef NS_ENUM(NSUInteger, KPhotoBrowserStyle) {
    // 长按图片弹出功能组件,底部一个PageControl
    KPhotoBrowserStylePageControl = 0,
    // 长按图片弹出功能组件,顶部一个索引UILabel
    KPhotoBrowserStyleIndeKabel,
    // 没有长按图片弹出的功能组件,顶部一个索引UILabel,底部一个保存图片按钮
    KPhotoBrowserStyleSimple
};

/**
 *  pageControl的位置
 */
typedef NS_ENUM(NSUInteger, KPhotoBrowserPageControlAliment) {
    KPhotoBrowserPageControlAlimentRight = 0,   // 右边
    KPhotoBrowserPageControlAlimentCenter,      // 中间
    KPhotoBrowserPageControlAlimentLeft         // 左边
};

/**
 *  pageControl的样式
 */
typedef NS_ENUM(NSUInteger, KPhotoBrowserPageControlStyle) {
    KPhotoBrowserPageControlStyleClassic = 0,   // 系统自带经典样式
    KPhotoBrowserPageControlStyleAnimated,      // 动画效果pagecontrol
    KPhotoBrowserPageControlStyleNone           // 不显示pagecontrol
};

#define KPhotoBrowserLoadingImageText       @"图片加载中,请稍后 ";
// 图片保存成功提示文字
#define KPhotoBrowserSaveImageSuccessText   @"保存成功 ";
// 图片保存失败提示文字
#define KPhotoBrowserSaveImageFailText      @"保存失败 ";
// 网络图片加载失败的提示文字
#define KPhotoBrowserLoadNetworkImageFail   @"图片加载失败"

// browser 图片间的margin
#define KPhotoBrowserImageViewMargin 10
// browser 中显示图片动画时长
#define KPhotoBrowserShowImageAnimationDuration 0.4f
// browser 中显示图片动画时长
#define KPhotoBrowserHideImageAnimationDuration 0.2f
// browser 背景颜色
#define KPhotoBrowserBackgrounColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]

// 图片下载进度指示进度显示样式（KProgressViewModeLoopDiagram 环形，KProgressViewModePieDiagram 饼型）
#define KProgressViewProgressMode KProgressViewModeLoopDiagram
// 图片下载进度指示器背景色
#define KProgressViewBackgroundColor [UIColor clearColor]
// 图片下载进度指示器圆环/圆饼颜色
#define KProgressViewStrokeColor [UIColor whiteColor]
// 图片下载进度指示器内部控件间的间距
#define KProgressViewItemMargin 10
// 圆环形图片下载进度指示器 环线宽度
#define KProgressViewLoopDiagramLineWidth 8

#define KPBLog(...) KFormatLog(__VA_ARGS__)

#if KPhotoBrowserDebug
#define KFormatLog(...)\
{\
NSString *string = [NSString stringWithFormat:__VA_ARGS__];\
NSLog(@"\n===========================\n===========================\n=== KPhotoBrowser' Log ===\n提示信息:%@\n所在方法:%s\n所在行数:%d\n===========================\n===========================",string,__func__,__LINE__);\
}

#define KLogFunc NSLog(@"%s", __func__)

#else
#define KFormatLog(...)
#define KLogFunc
#endif

