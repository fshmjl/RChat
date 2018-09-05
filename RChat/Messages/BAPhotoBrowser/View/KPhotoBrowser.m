//
//  KPhotoBrowser.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/17.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KPhotoBrowser.h"

#import "FSActionSheet.h"
#import "TAPageControl.h"
#import "KVideoPlayView.h"
#import "KZoomingScrollView.h"
#import "FSActionSheetConfig.h"
#import "KPhotoBrowserConfig.h"

#define BaseTag 100

@interface KPhotoBrowser () <KZoomingScrollViewDelegate , UIScrollViewDelegate>

@property (nonatomic , strong) UIWindow *photoBrowserWindow;

/**
 *  存放所有图片的容器
 */
@property (nonatomic , strong) UIScrollView  *scrollView;
/**
 *   保存图片的过程指示菊花
 */
@property (nonatomic , strong) UIActivityIndicatorView  *indicatorView;
/**
 *   保存图片的结果指示label
 */
@property (nonatomic , strong) UILabel *savaImageTipLabel;
/**
 *  正在使用的KZoomingScrollView对象集
 */
@property (nonatomic , strong) NSMutableSet  *visibleZoomingScrollViews;
/**
 *  循环利用池中的KZoomingScrollView对象集,用于循环利用
 */
@property (nonatomic , strong) NSMutableSet  *reusableZoomingScrollViews;
/**
 *  pageControl
 */
@property (nonatomic , strong) UIControl  *pageControl;
/**
 *  index label
 */
@property (nonatomic , strong) UILabel  *indeKabel;
/**
 *  保存按钮
 */
@property (nonatomic , strong) UIButton *saveButton;
/**
 *  ActionSheet的otherbuttontitles
 */
@property (nonatomic , strong) NSArray  *actionOtherButtonTitles;
/**
 *  ActionSheet的title
 */
@property (nonatomic , strong) NSString  *actionSheetTitle;
/**
 *  actionSheet的取消按钮title
 */
@property (nonatomic , strong) NSString  *actionSheetCancelTitle;
/**
 *  actionSheet的高亮按钮title
 */
@property (nonatomic , strong) NSString  *actionSheetDeleteButtonTitle;
@property (nonatomic, assign) CGSize pageControlDotSize;
@property(nonatomic, strong) NSArray<KPhoto *> *images;
@property (nonatomic, strong) KZoomingScrollView *lastZoomingScrollView;

@end

@implementation KPhotoBrowser

#pragma mark - set / get
- (UILabel *)savaImageTipLabel
{
    if (_savaImageTipLabel == nil) {
        _savaImageTipLabel = [[UILabel alloc] init];
        _savaImageTipLabel.textColor = [UIColor whiteColor];
        _savaImageTipLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
        _savaImageTipLabel.textAlignment = NSTextAlignmentCenter;
        _savaImageTipLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _savaImageTipLabel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    return _indicatorView;
}

- (KPhoto *)placeholderImage
{
    if (!_placeholderImage) {
        _placeholderImage = [[KPhoto alloc] init];
    }
    return _placeholderImage;
}

- (UIWindow *)photoBrowserWindow
{
    if (!_photoBrowserWindow) {
        _photoBrowserWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _photoBrowserWindow.windowLevel = MAXFLOAT;
        //        _photoBrowserWindow.windowLevel = UIWindowLevelAlert;//2000的优先级,这样不会遮盖UIAlertView的提示弹框
        UIViewController *tempVC = [[UIViewController alloc] init];
        tempVC.view.backgroundColor = KPhotoBrowserBackgrounColor;
        ;
        _photoBrowserWindow.rootViewController = tempVC;
    }
    return _photoBrowserWindow;
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor
{
    _currentPageDotColor = currentPageDotColor;
    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        pageControl.dotColor = currentPageDotColor;
    }
    else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    }
}

- (void)setPageDotColor:(UIColor *)pageDotColor
{
    _pageDotColor = pageDotColor;
    if ([self.pageDotColor isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.pageIndicatorTintColor = pageDotColor;
    }
}

- (void)setCurrentPageDotImage:(UIImage *)currentPageDotImage
{
    _currentPageDotImage = currentPageDotImage;
    [self setCustomPageControlDotImage:currentPageDotImage isCurrentPageDot:YES];
}

- (void)setPageDotImage:(UIImage *)pageDotImage
{
    _pageDotImage = pageDotImage;
    [self setCustomPageControlDotImage:pageDotImage isCurrentPageDot:NO];
}

- (void)setCustomPageControlDotImage:(UIImage *)image isCurrentPageDot:(BOOL)isCurrentPageDot
{
    if (!image || !self.pageControl) return;
    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        if (isCurrentPageDot) {
            pageControl.currentDotImage = image;
        } else {
            pageControl.dotImage = image;
        }
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        if (isCurrentPageDot) {
            [pageControl setValue:image forKey:@"_currentPageImage"];
        } else {
            [pageControl setValue:image forKey:@"_pageImage"];
        }
    }
}

- (void)setPageControlStyle:(KPhotoBrowserPageControlStyle)pageControlStyle
{
    // KLogFunc;
    _pageControlStyle = pageControlStyle;
    [self setUpPageControl];
    [self updateIndexVisible];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage
{
    _hidesForSinglePage = hidesForSinglePage;
    [self updateIndexVisible];
}

- (void)setBrowserStyle:(KPhotoBrowserStyle)browserStyle
{
    _browserStyle = browserStyle;
    [self updateIndexVisible];
}

- (void)setPageControlAliment:(KPhotoBrowserPageControlAliment)pageControlAliment
{
    _pageControlAliment = pageControlAliment;
    switch (self.pageControlAliment) {
        case KPhotoBrowserPageControlAlimentLeft:
        {
            self.pageControl.mj_x = 10;
        }
            break;
        case KPhotoBrowserPageControlAlimentRight:
        {
            self.pageControl.mj_x = (self.mj_w - self.pageControl.mj_w) - 10;
        }
            break;
        case KPhotoBrowserPageControlAlimentCenter:
        default:
        {
            self.pageControl.mj_x = (self.mj_w - self.pageControl.mj_w) * 0.5;
        }
            break;
    }
}

#pragma mark  - initial
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initial];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)initial
{
    self.backgroundColor = KPhotoBrowserBackgrounColor;
    self.visibleZoomingScrollViews = [[NSMutableSet alloc] init];
    self.reusableZoomingScrollViews = [[NSMutableSet alloc] init];
    [self placeholderImage];
    
    _pageControlAliment = KPhotoBrowserPageControlAlimentCenter;
    _pageControlDotSize = CGSizeMake(10, 10);
    _pageControlStyle = KPhotoBrowserPageControlStyleAnimated;
    _hidesForSinglePage = YES;
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor lightGrayColor];
    _browserStyle = KPhotoBrowserStylePageControl;
    
    self.currentImageIndex = 0;
    self.imageCount = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationDidChange) name:UIDeviceOrientationDidChangeNotification  object:nil];
    
}

- (void)dealloc {
    [self.reusableZoomingScrollViews removeAllObjects];
    [self.visibleZoomingScrollViews removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)iniaialUI
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];
    
    if (self.currentImageIndex == 0) { // 如果刚进入的时候是0,不会调用scrollViewDidScroll:方法,不会展示第一张图片
        // KFormatLog(@"self.currentImageIndex == %zd",self.currentImageIndex);
        self.isAutoPlay = YES;
        [self showPhotos];
    }
    
    [self setUpPageControl];
    
    // 添加KPhotoBrowserStyleSimple相关控件
    UILabel *indeKabel = [[UILabel alloc] init];
    indeKabel.textAlignment = NSTextAlignmentCenter;
    indeKabel.textColor = [UIColor whiteColor];
    indeKabel.font = [UIFont systemFontOfSize:18];
    indeKabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    indeKabel.clipsToBounds = YES;
    self.indeKabel = indeKabel;
    [self addSubview:indeKabel];
    UIButton *saveButton = [[UIButton alloc] init];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    saveButton.layer.cornerRadius = 5;
    saveButton.clipsToBounds = YES;
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton = saveButton;
    [self addSubview:saveButton];
    
    [self showFirstImage];
    [self updateIndexContent];
    [self updateIndexVisible];
}

- (void)setUpPageControl
{
    if (_pageControl) {
        [_pageControl removeFromSuperview];
        _pageControl = nil;
        // 重新加载数据时调整
    }
    switch (self.pageControlStyle) {
        case KPhotoBrowserPageControlStyleAnimated:
        {
            TAPageControl *pageControl = [[TAPageControl alloc] init];
            _pageControl = pageControl;
            pageControl.numberOfPages = self.imageCount;
            pageControl.dotColor = self.currentPageDotColor;
            pageControl.currentPage = self.currentImageIndex;
            pageControl.userInteractionEnabled = NO;
            [self addSubview:pageControl];
        }
            break;
        case KPhotoBrowserPageControlStyleClassic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            _pageControl = pageControl;
            pageControl.numberOfPages = self.imageCount;
            pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
            pageControl.pageIndicatorTintColor = self.pageDotColor;
            pageControl.userInteractionEnabled = NO;
            [self addSubview:pageControl];
            pageControl.currentPage = self.currentImageIndex;
        }
            break;
        default:
            break;
    }
    
    // 重设pagecontroldot图片
    self.currentPageDotImage = self.currentPageDotImage;
    self.pageDotImage = self.pageDotImage;
}

#pragma mark - layout
- (void)orientationDidChange
{
    self.scrollView.delegate = nil; // 旋转期间,禁止调用scrollView的代理事件等
    KZoomingScrollView *temp = [self zoomingScrollViewAtIndex:self.currentImageIndex];
    [temp.scrollview setZoomScale:1.0 animated:YES];
    [self updateFrames];
    self.scrollView.delegate = self;
}

- (void)updateFrames
{
    self.frame = [UIScreen mainScreen].bounds;
    CGRect rect = self.bounds;
    rect.size.width += KPhotoBrowserImageViewMargin;
    self.scrollView.frame = rect; // frame修改的时候,也会触发scrollViewDidScroll,不是每次都触发
    self.scrollView.mj_x = 0;
    self.scrollView.contentSize = CGSizeMake((self.scrollView.mj_w) * self.imageCount, 0);
    self.scrollView.contentOffset = CGPointMake(self.currentImageIndex * (self.scrollView.mj_w), 0);// 回触发scrollViewDidScroll
    
    kWeakSelf;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag >= BaseTag) {
            obj.frame = CGRectMake((weakSelf.scrollView.mj_w) * (obj.tag - BaseTag), 0, weakSelf.mj_w, weakSelf.mj_h);
        }
    }];
    
    self.saveButton.frame = CGRectMake(30, self.mj_h - 70, 50, 25);
    self.indeKabel.bounds = CGRectMake(0, 0, 80, 30);
    self.indeKabel.center = CGPointMake(self.mj_w * 0.5, 35);
    self.indeKabel.layer.cornerRadius = self.indeKabel.mj_h * 0.5;
    
    self.savaImageTipLabel.layer.cornerRadius = 5;
    self.savaImageTipLabel.clipsToBounds = YES;
    [self.savaImageTipLabel sizeToFit];
    self.savaImageTipLabel.mj_h = 30;
    self.savaImageTipLabel.mj_w += 20;
    self.savaImageTipLabel.center = self.center;
    
    self.indicatorView.center = self.center;
    
    CGSize size = CGSizeZero;
    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        size = [pageControl sizeForNumberOfPages:self.imageCount];
        // TAPageControl 本身设计的缺陷,如果TAPageControl在设置颜色等属性以后再给frame,里面的圆点位置可能不正确 , 但是调用sizeToFit 又会改变TAPageControl的显隐状态,所以还需要
        BOOL hidden = pageControl.hidden;
        [pageControl sizeToFit];
        pageControl.hidden = hidden;
    } else {
        size = CGSizeMake(self.imageCount * self.pageControlDotSize.width * 1.2, self.pageControlDotSize.height);
    }
    CGFloat x;
    switch (self.pageControlAliment) {
        case KPhotoBrowserPageControlAlimentCenter:
        {
            x = (self.mj_w - size.width) * 0.5;
        }
            break;
        case KPhotoBrowserPageControlAlimentLeft:
        {
            x = 10;
        }
            break;
        case KPhotoBrowserPageControlAlimentRight:
        {
            x = self.mj_w - size.width - 10;
        }
            break;
        default:
            break;
    }
    CGFloat y = self.mj_h - size.height - 10;
    self.pageControl.frame = CGRectMake(x, y, size.width, size.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateFrames];
}

#pragma mark - private -- 长按图片相关
- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    KZoomingScrollView *currentZoomingScrollView = [self zoomingScrollViewAtIndex:self.currentImageIndex];
    if (longPress.state == UIGestureRecognizerStateBegan) {
        KPBLog(@"UIGestureRecognizerStateBegan , currentZoomingScrollView.progress %f",currentZoomingScrollView.progress);
        if (currentZoomingScrollView.progress < 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self longPress:longPress];
            });
            return;
        }
        
        if (self.actionOtherButtonTitles.count <= 0 && self.actionSheetDeleteButtonTitle.length <= 0 && self.actionSheetTitle.length <= 0) {
            return;
        }
        FSActionSheet *actionSheet = [[FSActionSheet alloc] initWithTitle:self.actionSheetTitle delegate:nil cancelButtonTitle:self.actionSheetCancelTitle highlightedButtonTitle:self.actionSheetDeleteButtonTitle otherButtonTitles:self.actionOtherButtonTitles sourceWindow:self.photoBrowserWindow];
        __weak typeof(self) weakSelf = self;
        // 展示并绑定选择回调
        [actionSheet showWithSelectedCompletion:^(NSInteger selectedIndex) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(photoBrowser:clickActionSheetIndex:currentImageIndex:)]) {
                [weakSelf.delegate photoBrowser:weakSelf clickActionSheetIndex:selectedIndex currentImageIndex:weakSelf.currentImageIndex];
            }
        }];
    }
}

/**
 具体的删除逻辑,请根据自己项目的实际情况,自行处理
 */
//- (void)delete
//{
//    if (self.currentImageIndex == 0) {
//        KZoomingScrollView *currentZoomingScrollView = [self zoomingScrollViewAtIndex:self.currentImageIndex];
//        [self.reusableZoomingScrollViews addObject:currentZoomingScrollView];
//        [currentZoomingScrollView prepareForReuse];
//        [currentZoomingScrollView removeFromSuperview];
//        [self.visibleZoomingScrollViews minusSet:self.reusableZoomingScrollViews];
//    }
//    self.currentImageIndex --;
//    self.imageCount --;
//    if (self.currentImageIndex == -1 && self.imageCount == 0) {
//        [self dismiss];
//    } else {
//        self.currentImageIndex = (self.currentImageIndex == (-1) ? 0 : self.currentImageIndex);
//        if (self.currentImageIndex == 0) {
//            [self setUpImageForZoomingScrollViewAtIndex:0];
//            [self updatePageControlIndex];
//            [self showPhotos];
//        }
//
//        self.scrollView.contentSize = CGSizeMake((self.scrollView.frame.size.width) * self.imageCount, 0);
//        self.scrollView.contentOffset = CGPointMake(self.currentImageIndex * (self.scrollView.frame.size.width), 0);
//    }
//    UIPageControl *pageControl = (UIPageControl *)self.pageControl;
//    pageControl.numberOfPages = self.imageCount;
//    [self updatePageControlIndex];
//}

#pragma mark    -   private -- save image
- (void)saveImage
{
    KZoomingScrollView *zoomingScrollView = [self zoomingScrollViewAtIndex:self.currentImageIndex];
    if (zoomingScrollView.progress < 1.0) {
        self.savaImageTipLabel.text = KPhotoBrowserLoadingImageText;
        [self addSubview:self.savaImageTipLabel];
        [self.savaImageTipLabel performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
        return;
    }
    // 保存图片
    if (!zoomingScrollView.photo.videoUrl) {
        UIImageWriteToSavedPhotosAlbum(zoomingScrollView.photo.defaultImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
    
    [self addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [self.indicatorView removeFromSuperview];
    [self addSubview:self.savaImageTipLabel];
    if (error) {
        self.savaImageTipLabel.text = KPhotoBrowserSaveImageFailText;
    } else {
        self.savaImageTipLabel.text = KPhotoBrowserSaveImageSuccessText;
    }
    [self.savaImageTipLabel performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

#pragma mark - private loadimage
- (void)showPhotos
{
    // KLogFunc;
    // 只有一张图片
    if (self.imageCount == 1) {
        [self setUpImageForZoomingScrollViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = self.scrollView.bounds;
    NSInteger firstIndex = floor((CGRectGetMinX(visibleBounds)) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = floor((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (firstIndex >= self.imageCount) {
        firstIndex = self.imageCount - 1;
    }
    if (lastIndex < 0){
        lastIndex = 0;
    }
    if (lastIndex >= self.imageCount) {
        lastIndex = self.imageCount - 1;
    }
    
    // 回收不再显示的zoomingScrollView
    NSInteger zoomingScrollViewIndex = 0;
    for (KZoomingScrollView *zoomingScrollView in self.visibleZoomingScrollViews) {
        zoomingScrollViewIndex = zoomingScrollView.tag - BaseTag;
        if (zoomingScrollViewIndex < firstIndex || zoomingScrollViewIndex > lastIndex) {
            [self.reusableZoomingScrollViews addObject:zoomingScrollView];
            [zoomingScrollView prepareForReuse];
            [zoomingScrollView removeFromSuperview];
        }
    }
    
    // _visiblePhotoViews 减去 _reusablePhotoViews中的元素
    [self.visibleZoomingScrollViews minusSet:self.reusableZoomingScrollViews];
    while (self.reusableZoomingScrollViews.count > 2) { // 循环利用池中最多保存两个可以用对象
        [self.reusableZoomingScrollViews removeObject:[self.reusableZoomingScrollViews anyObject]];
    }
    
    // 展示图片
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingZoomingScrollViewAtIndex:index]) {
            [self setUpImageForZoomingScrollViewAtIndex:index];
        }
    }
}

/**
 *  判断指定的某个位置图片是否在显示
 */
- (BOOL)isShowingZoomingScrollViewAtIndex:(NSInteger)index
{
    for (KZoomingScrollView* view in self.visibleZoomingScrollViews) {
        if ((view.tag - BaseTag) == index) {
            return YES;
        }
    }
    return NO;
}

/**
 *  获取指定位置的KZoomingScrollView , 三级查找,正在显示的池,回收池,创建新的并赋值
 *
 *  @param index 指定位置索引
 */
- (KZoomingScrollView *)zoomingScrollViewAtIndex:(NSInteger)index
{
    for (KZoomingScrollView* zoomingScrollView in self.visibleZoomingScrollViews) {
        if ((zoomingScrollView.tag - BaseTag) == index) {
            return zoomingScrollView;
        }
    }
    KZoomingScrollView* zoomingScrollView = [self dequeueReusableZoomingScrollView];
    [self setUpImageForZoomingScrollViewAtIndex:index];
    return zoomingScrollView;
}

/**
 *   加载指定位置的图片
 */
- (void)setUpImageForZoomingScrollViewAtIndex:(NSInteger)index
{
    // KLogFunc;
    KZoomingScrollView *zoomingScrollView = [self dequeueReusableZoomingScrollView];
    zoomingScrollView.zoomingScrollViewdelegate = self;
    self.lastZoomingScrollView = zoomingScrollView;
    zoomingScrollView.isAutoPlay = self.isAutoPlay;
    [zoomingScrollView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    zoomingScrollView.tag = BaseTag + index;
    zoomingScrollView.frame = CGRectMake((self.scrollView.mj_w) * index, 0, self.mj_w, self.mj_h);
    self.currentImageIndex = index;
    if ([self highQualityImageURLForIndex:index]) { // 如果提供了高清大图数据源,就去加载
        [zoomingScrollView setShowHighQualityImageWithPhoto:[self highQualityImageURLForIndex:index]];
    }
//    else if ([self assetForIndex:index]) {
//        ALAsset *asset = [self assetForIndex:index];
//        CGImageRef imageRef = asset.defaultRepresentation.fullScreenImage;
//        [zoomingScrollView setShowImage:[UIImage imageWithCGImage:imageRef]];
//        CGImageRelease(imageRef);
//    }
    else {
        [zoomingScrollView setShowImage:[self placeholderImageForIndex:index]];
    }
    
    [self.visibleZoomingScrollViews addObject:zoomingScrollView];
    [self.scrollView addSubview:zoomingScrollView];
}

/**
 *  从缓存池中获取一个KZoomingScrollView对象
 */
- (KZoomingScrollView *)dequeueReusableZoomingScrollView
{
    KZoomingScrollView *photoView = [self.reusableZoomingScrollViews anyObject];
    if (photoView) {
        [self.reusableZoomingScrollViews removeObject:photoView];
    } else {
        photoView = [[KZoomingScrollView alloc] init];
    }
    return photoView;
}

/**
 *  获取指定位置的占位图片,和外界的数据源交互
 */
- (KPhoto *)placeholderImageForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        KPhoto *photo = [self.datasource photoBrowser:self placeholderImageForIndex:index];
//        return [self.datasource photoBrowser:self placeholderImageForIndex:index];
        return photo;//photo.defaultImage;
    } else if(self.images.count > index) {
        if ([self.images[index] isKindOfClass:[KPhoto class]]) {
            return self.images[index];
        } else {
            return self.placeholderImage;
        }
    }
    return self.placeholderImage;
}

/**
 *  获取指定位置的高清大图URL,和外界的数据源交互
 */
- (KPhoto *)highQualityImageURLForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
//        NSURL *url = [self.datasource photoBrowser:self highQualityImageURLForIndex:index];
        KPhoto *photo = [self.datasource photoBrowser:self placeholderImageForIndex:index];
        if ([photo isEmpty]) {
            KPBLog(@"你所设置的需要显示的数据为空:%zd",index);
            
            return nil;
        }
        return photo;
    }
    return nil;
}

/**
 *  获取多图浏览,指定位置图片的UIImageView视图,用于做弹出放大动画和回缩动画
 */
- (UIView *)sourceImageViewForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:sourceImageViewForIndex:)]) {
        return [self.datasource photoBrowser:self sourceImageViewForIndex:index];
    }
    return nil;
}

/**
 *  第一个展示的图片 , 点击图片,放大的动画就是从这里来的
 */
- (void)showFirstImage
{
    // 获取到用户点击的那个UIImageView对象,进行坐标转化
    CGRect startRect;
    if (!self.sourceImageView) {
        if(self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:sourceImageViewForIndex:)]) {
            self.sourceImageView = [self.datasource photoBrowser:self sourceImageViewForIndex:self.currentImageIndex];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 1.0;
            }];
            KPBLog(@"需要提供源视图才能做弹出/退出图片浏览器的缩放动画");
            return;
        }
    }
    startRect = [self.sourceImageView.superview convertRect:self.sourceImageView.frame toView:self];
    
    KPhoto *photo = [self placeholderImageForIndex:self.currentImageIndex];
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = photo.defaultImage;
    tempView.frame = startRect;
    [self addSubview:tempView];
    
    CGRect targetRect; // 目标frame
    UIImage *image = self.sourceImageView.image;
    
    //TODO 完善image为空的闪退
    if (image == nil) {
        KPBLog(@"需要提供源视图才能做弹出/退出图片浏览器的缩放动画");
        return;
    }
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    CGFloat width = MSWIDTH;
    CGFloat height = MSWIDTH / imageWidthHeightRatio;
    CGFloat x = 0;
    CGFloat y;
    if (height > MSHEIGHT) {
        y = 0;
    } else {
        y = (MSHEIGHT - height ) * 0.5;
    }
    targetRect = CGRectMake(x, y, width, height);
    self.scrollView.hidden = YES;
    self.alpha = 1.0;
    
    // 动画修改图片视图的frame , 居中同时放大
    [UIView animateWithDuration:KPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.frame = targetRect;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
        self.scrollView.hidden = NO;
    }];
}

#pragma mark - KZoomingScrollViewDelegate
/**
 *  单击图片,退出浏览
 */
- (void)zoomingScrollView:(KZoomingScrollView *)zoomingScrollView singleTapDetected:(UITapGestureRecognizer *)singleTap
{
    [UIView animateWithDuration:0.05 animations:^{
        self.savaImageTipLabel.alpha = 0.0;
        self.indicatorView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.savaImageTipLabel removeFromSuperview];
        [self.indicatorView removeFromSuperview];
    }];
    NSInteger currentIndex = zoomingScrollView.tag - BaseTag;
    UIView *sourceView = [self sourceImageViewForIndex:currentIndex];
    if (sourceView == nil) {
        [self dismiss];
        return;
    }
    self.scrollView.hidden = YES;
    self.pageControl.hidden = YES;
    self.indeKabel.hidden = YES;
    self.saveButton.hidden = YES;
    
    
    CGRect targetTemp = [sourceView.superview convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = zoomingScrollView.photo.defaultImage;
    tempView.frame = CGRectMake( - zoomingScrollView.scrollview.contentOffset.x + zoomingScrollView.imageView.mj_x,  - zoomingScrollView.scrollview.contentOffset.y + zoomingScrollView.imageView.mj_y, zoomingScrollView.imageView.mj_w, zoomingScrollView.imageView.mj_h);
    [self addSubview:tempView];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:KPhotoBrowserHideImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // KLogFunc;
    [self.lastZoomingScrollView.videoPlayer stop];
    
    [self showPhotos];
    NSInteger pageNum = floor((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width);
    if (self.currentImageIndex == pageNum && self.isAutoPlay == YES) {
        self.isAutoPlay = YES;
    }
    else {
        self.isAutoPlay = NO;
    }
    self.currentImageIndex = pageNum == self.imageCount ? pageNum - 1 : pageNum;
    [self updateIndexContent];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger pageNum = floor((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width);
    self.currentImageIndex = pageNum == self.imageCount ? pageNum - 1 : pageNum;
    [self updateIndexContent];
}

#pragma mark - 图片索引的显示内容和显隐逻辑
/**
 更新索引指示控件的显隐逻辑
 */
- (void)updateIndexVisible
{
    switch (self.browserStyle) {
        case KPhotoBrowserStylePageControl:
        {
            self.pageControl.hidden = NO;
            self.indeKabel.hidden = YES;
            self.saveButton.hidden = YES;
        }
            break;
        case KPhotoBrowserStyleIndeKabel:
        {
            self.indeKabel.hidden = NO;
            self.pageControl.hidden = YES;
            self.saveButton.hidden = YES;
        }
            break;
        case KPhotoBrowserStyleSimple:
        {
            self.indeKabel.hidden = NO;
            self.saveButton.hidden = NO;
            self.pageControl.hidden = YES;
        }
            break;
        default:
            break;
    }
    
    if (self.imageCount == 1 && self.hidesForSinglePage == YES) {
        self.indeKabel.hidden = YES;
        self.pageControl.hidden = YES;
    }
}

/**
 *  修改图片指示索引内容
 */
- (void)updateIndexContent
{
    UIPageControl *pageControl = (UIPageControl *)self.pageControl;
    pageControl.currentPage = self.currentImageIndex;
    NSString *title = [NSString stringWithFormat:@"%zd / %zd",self.currentImageIndex+1,self.imageCount];
    self.indeKabel.text = title;
}

#pragma mark - public method
/**
 *  快速创建并进入图片浏览器
 *
 *  @param currentImageIndex 开始展示的图片索引
 *  @param imageCount        图片数量
 *  @param datasource        数据源
 *
 */
+ (instancetype)showPhotoBrowserWithCurrentImageIndex:(NSInteger)currentImageIndex imageCount:(NSUInteger)imageCount datasource:(id<KPhotoBrowserDatasource>)datasource
{
    KPhotoBrowser *browser = [[KPhotoBrowser alloc] init];
    browser.imageCount = imageCount;
    browser.currentImageIndex = currentImageIndex;
    browser.datasource = datasource;
    [browser show];
    return browser;
}

- (void)show
{
    if (self.imageCount <= 0) {
        return;
    }
    if (self.currentImageIndex >= self.imageCount) {
        self.currentImageIndex = self.imageCount - 1;
    }
    if (self.currentImageIndex < 0) {
        self.currentImageIndex = 0;
    }
    
    self.frame = self.photoBrowserWindow.bounds;
    self.alpha = 0.0;
    [self.photoBrowserWindow.rootViewController.view addSubview:self];
    [self.photoBrowserWindow makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self iniaialUI];
}

/**
 *  退出
 */
- (void)dismiss
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:KPhotoBrowserHideImageAnimationDuration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.photoBrowserWindow = nil;
    }];
}

/**
 *  初始化底部ActionSheet弹框数据
 *
 *  @param title                  ActionSheet的title
 *  @param delegate               KPhotoBrowserDelegate
 *  @param cancelButtonTitle      取消按钮文字
 *  @param deleteButtonTitle      删除按钮文字
 *  @param otherButtonTitle       其他按钮数组
 */
- (void)setActionSheetWithTitle:(nullable NSString *)title delegate:(nullable id<KPhotoBrowserDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle deleteButtonTitle:(nullable NSString *)deleteButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitle, ...
{
    NSMutableArray *otherButtonTitlesArray = [NSMutableArray array];
    NSString *buttonTitle;
    va_list argumentList;
    if (otherButtonTitle) {
        [otherButtonTitlesArray addObject:otherButtonTitle];
        va_start(argumentList, otherButtonTitle);
        while ((buttonTitle = va_arg(argumentList, id))) {
            [otherButtonTitlesArray addObject:buttonTitle];
        }
        va_end(argumentList);
    }
    self.actionOtherButtonTitles = otherButtonTitlesArray;
    self.actionSheetTitle = title;
    self.actionSheetCancelTitle = cancelButtonTitle;
    self.actionSheetDeleteButtonTitle = deleteButtonTitle;
    if (delegate) {
        self.delegate = delegate;
    }
}

/**
 *  保存当前展示的图片
 */
- (void)saveCurrentShowImage
{
    [self saveImage];
}

#pragma mark - public method -> KPhotoBrowser简易使用方式:一行代码展示

/**
 一行代码展示(在某些使用场景,不需要做很复杂的操作,例如不需要长按弹出actionSheet,从而不需要实现数据源方法和代理方法,那么可以选择这个方法,直接传数据源数组进来,框架内部做处理)
 
 @param images            图片数据源数组(,内部可以是UIImage/NSURL网络图片地址/ALAsset)
 @param currentImageIndex 展示第几张
 
 @return KPhotoBrowser实例对象
 */
+ (instancetype)showPhotoBrowserWithImages:(NSArray *)images currentImageIndex:(NSInteger)currentImageIndex
{
    if (images.count <=0 || images ==nil) {
        KPBLog(@"一行代码展示图片浏览的方法,传入的数据源为空,请检查传入数据源");
        return nil;
    }
    
    //检查数据源对象是否非法
    for (id image in images) {
        if (![image isKindOfClass:[KPhoto class]]) {
            KPBLog(@"识别到非法数据格式,请检查传入数据是否为 NSString/NSURL/ALAsset 中一种");
            return nil;
        }
    }
    
    KPhotoBrowser *browser = [[KPhotoBrowser alloc] init];
    browser.imageCount = images.count;
    browser.currentImageIndex = currentImageIndex;
    browser.images = images;
    [browser show];
    return browser;
}

@end
