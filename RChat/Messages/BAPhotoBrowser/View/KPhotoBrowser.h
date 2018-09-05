//
//  KPhotoBrowser.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/17.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>

#import "KPhoto.h"
#import "KPhotoBrowserConfig.h"

@class KPhotoBrowser;

@protocol KPhotoBrowserDelegate <NSObject>

@optional

/**
 *  点击底部actionSheet回调,对于图片添加了长按手势的底部功能组件
 *
 *  @param browser 图片浏览器
 *  @param actionSheetindex   点击的actionSheet索引
 *  @param currentImageIndex    当前展示的图片索引
 */
- (void)photoBrowser:(KPhotoBrowser *)browser clickActionSheetIndex:(NSInteger)actionSheetindex currentImageIndex:(NSInteger)currentImageIndex;

@end

@protocol KPhotoBrowserDatasource <NSObject>

@optional

/**
 返回当前位置的数据

 @param browser 浏览器
 @param index 位置索引
 @return 位置需要显示的数据
 */
- (KPhoto *)photoBrowser:(KPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

/**
 *  返回这个位置的占位图片 , 也可以是原图(如果不实现此方法,会默认使用placeholderImage)
 *
 *  @param browser 浏览器
 *  @param index   位置索引
 *
 *  @return 占位图片
 */
//- (UIImage *)photoBrowser:(KPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

/**
 *  返回指定位置的高清图片URL
 *
 *  @param browser 浏览器
 *  @param index   位置索引
 *
 *  @return 返回高清大图索引
 */
//- (NSURL *)photoBrowser:(KPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;
/**
 *  返回指定位置的ALAsset对象,从其中获取图片
 *
 *  @param browser 浏览器
 *  @param index   位置索引
 *
 *  @return 返回高清大图索引
 */
//- (ALAsset *)photoBrowser:(KPhotoBrowser *)browser assetForIndex:(NSInteger)index;
/**
 *  返回指定位置图片的UIImageView,用于做图片浏览器弹出放大和消失回缩动画等
 *  如果没有实现这个方法,没有回缩动画,如果传过来的view不正确,可能会影响回缩动画
 *
 *  @param browser 浏览器
 *  @param index   位置索引
 *
 *  @return 展示图片的UIImageView
 */
- (UIImageView *)photoBrowser:(KPhotoBrowser *)browser sourceImageViewForIndex:(NSInteger)index;

@end

@interface KPhotoBrowser : UIView

@property (nonatomic, assign) BOOL isAutoPlay;

/**
 *  用户点击的图片视图,用于做图片浏览器弹出的放大动画,不给次属性赋值会通过代理方法photoBrowser: sourceImageViewForIndex:尝试获取,如果还是获取不到则没有弹出放大动画
 */
@property (nonatomic, weak) UIImageView *sourceImageView;
/**
 *  当前显示的图片位置索引 , 默认是0
 */
@property (nonatomic, assign ) NSInteger currentImageIndex;
/**
 *  浏览的图片数量,大于0
 */
@property (nonatomic, assign ) NSInteger imageCount;
/**
 *  datasource
 */
@property (nonatomic, weak) id<KPhotoBrowserDatasource> datasource;
/**
 *  delegate
 */
@property (nonatomic , weak) id<KPhotoBrowserDelegate> delegate;
/**
 *  browser style
 */
@property (nonatomic , assign) KPhotoBrowserStyle browserStyle;
/**
 *  占位图片,可选(默认是一张灰色的100*100像素图片)
 *  当没有实现数据源中placeholderImageForIndex方法时,默认会使用这个占位图片
 */
@property(nonatomic, strong) KPhoto *placeholderImage;


#pragma mark - 自定义PageControl样式接口

/**
 *  是否在只有一张图时隐藏pagecontrol，默认为YES
 */
@property(nonatomic) BOOL hidesForSinglePage;
/**
 *  pagecontrol 样式，默认为KPhotoBrowserPageControlStyleAnimated样式
 */
@property (nonatomic, assign) KPhotoBrowserPageControlStyle pageControlStyle;
/**
 *  分页控件位置 , 默认为KPhotoBrowserPageControlAlimentCenter
 */
@property (nonatomic, assign) KPhotoBrowserPageControlAliment pageControlAliment;
/**
 *  当前分页控件小圆标颜色
 */
@property (nonatomic, strong) UIColor *currentPageDotColor;
/**
 *  其他分页控件小圆标颜色
 */
@property (nonatomic, strong) UIColor *pageDotColor;
/**
 *  当前分页控件小圆标图片
 */
@property (nonatomic, strong) UIImage *currentPageDotImage;
/**
 *  其他分页控件小圆标图片
 */
@property (nonatomic, strong) UIImage *pageDotImage;


#pragma mark - KPhotoBrowser控制接口

/**
 *  快速创建并进入图片浏览器 , 同时传入数据源对象
 *
 *  @param currentImageIndex 开始展示的图片索引
 *  @param imageCount        图片数量
 *  @param datasource        数据源
 *
 */
+ (instancetype)showPhotoBrowserWithCurrentImageIndex:(NSInteger)currentImageIndex imageCount:(NSUInteger)imageCount datasource:(id<KPhotoBrowserDatasource>)datasource;

/**
 一行代码展示 (在某些使用场景,不需要做很复杂的操作,例如不需要长按弹出actionSheet,从而不需要实现数据源方法和代理方法,那么可以选择这个方法,直接传数据源数组进来,框架内部做处理)
 
 @param images            图片数据源数组(数组内部可以是UIImage/NSURL网络图片地址/ALAsset,但只能是其中一种)
 @param currentImageIndex 展示第几张,从0开始
 
 @return KPhotoBrowser实例对象
 */
+ (instancetype)showPhotoBrowserWithImages:(NSArray *)images currentImageIndex:(NSInteger)currentImageIndex;

/**
 *  初始化底部ActionSheet弹框数据 , 不实现此方法,则没有类似微信那种长按手势弹框
 *
 *  @param title                  ActionSheet的title
 *  @param delegate               KPhotoBrowserDelegate
 *  @param cancelButtonTitle      取消按钮文字
 *  @param deleteButtonTitle      删除按钮文字,如果为nil,不显示删除按钮
 *  @param otherButtonTitle    其他按钮数组
 */
- (void)setActionSheetWithTitle:(NSString *)title delegate:(id<KPhotoBrowserDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle deleteButtonTitle:( NSString *)deleteButtonTitle otherButtonTitles:( NSString *)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;
/**
 *  保存当前展示的图片
 */
- (void)saveCurrentShowImage;
/**
 *  进入图片浏览器
 */
- (void)show;
/**
 *  退出
 */
- (void)dismiss;

@end
