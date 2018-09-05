//
//  KZoomingScrollView.m
//  KPhotoBrowserDemo
//
//  Created by Liushannoon on 16/7/15.
//  Copyright © 2016年 LiuShannoon. All rights reserved.
//

#import "KZoomingScrollView.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "SDImageCache.h"
#import "BAProgressView.h"
#import "KVideoPlayView.h"

@interface KZoomingScrollView () <UIScrollViewDelegate, KVideoPlayViewDelegate>
{
    UIScrollView *_scrollview;
}

@property (nonatomic, strong) UIImageView  *photoImageView;
@property (nonatomic, strong) BAProgressView *progressView;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, assign) BOOL hasLoadedImage;
@property (nonatomic, strong) NSURL  *imageURL;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapBackgroundView;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapBackgroundView;

@end

@implementation KZoomingScrollView

#pragma mark - set / get

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.progressView.progress = progress;
    if ([self.zoomingScrollViewdelegate respondsToSelector:@selector(zoomingScrollView:imageLoadProgress:)]) {
        [self.zoomingScrollViewdelegate zoomingScrollView:self imageLoadProgress:progress];
    }
}

- (UIImageView *)imageView
{
    return self.photoImageView;
}

- (UIImageView *)photoImageView
{
    if (_photoImageView == nil) {
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.backgroundColor = [UIColor clearColor];
        [_photoImageView setHidden:YES];
    }
    
    return _photoImageView;
}

- (KVideoPlayView *)videoPlayer {
    if (!_videoPlayer) {
        _videoPlayer = [[KVideoPlayView alloc] init];
        _videoPlayer.delegate = self;
        [_videoPlayer setHidden:YES];
    }
    return _videoPlayer;
}

- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        [_scrollview addSubview:self.photoImageView];
        [_scrollview addSubview:self.videoPlayer];
        _scrollview.delegate = self;
        _scrollview.clipsToBounds = YES;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
    }
    return _scrollview;
}

- (UILabel *)stateLabel
{
    if (_stateLabel == nil) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.text = KPhotoBrowserLoadNetworkImageFail;
        _stateLabel.font = [UIFont systemFontOfSize:16];
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        _stateLabel.layer.cornerRadius = 5;
        _stateLabel.clipsToBounds = YES;
        _stateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _stateLabel;
}

- (BAProgressView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[BAProgressView alloc] init];
    }
    return _progressView;
}

- (UITapGestureRecognizer *)singleTapBackgroundView {
    if (!_singleTapBackgroundView) {
        _singleTapBackgroundView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapBackgroundView:)];
    }
    return _singleTapBackgroundView;
}

- (UITapGestureRecognizer *)doubleTapBackgroundView {
    if (!_doubleTapBackgroundView) {
        _doubleTapBackgroundView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapBackgroundView:)];
        _doubleTapBackgroundView.numberOfTapsRequired = 2;
        [self.singleTapBackgroundView requireGestureRecognizerToFail:_doubleTapBackgroundView];
    }
    return _doubleTapBackgroundView;
}

#pragma mark - initial UI
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

/**
 *  初始化
 */
- (void)initial
{
    [self addSubview:self.scrollview];

    [self addGestureRecognizer:self.singleTapBackgroundView];
    [self addGestureRecognizer:self.doubleTapBackgroundView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.stateLabel.bounds = CGRectMake(0, 0, 160, 30);
    self.stateLabel.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    self.progressView.bounds = CGRectMake(0, 0, 100, 100);
    self.progressView.center = CGPointMake(self.mj_w * 0.5, self.mj_h * 0.5);
    self.scrollview.frame = self.bounds;
    
    [self setMaxAndMinZoomScales];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.photoImageView.center = [self centerOfScrollViewContent:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.scrollview.scrollEnabled = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.scrollview.userInteractionEnabled = YES;
}

#pragma mark - private method - 手势处理,缩放图片
- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
     (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
     (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGFloat height = self.frame.size.height / scale;
    CGFloat width  = self.frame.size.width / scale;
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    return CGRectMake(x, y, width, height);
}

- (void)singleTapBackgroundView:(UITapGestureRecognizer *)singleTap
{
    if (self.zoomingScrollViewdelegate && [self.zoomingScrollViewdelegate respondsToSelector:@selector(zoomingScrollView:singleTapDetected:)]) {
        [self.zoomingScrollViewdelegate zoomingScrollView:self singleTapDetected:singleTap];
    }
    
}

- (void)doubleTapBackgroundView:(UITapGestureRecognizer *)doubleTap
{
    if (!self.hasLoadedImage) {
        return;
    }
    self.scrollview.userInteractionEnabled = NO;
    
    
    if (self.scrollview.zoomScale > self.scrollview.minimumZoomScale) {
        [self.scrollview setZoomScale:self.scrollview.minimumZoomScale animated:YES];
    } else {
        CGPoint point = [doubleTap locationInView:doubleTap.view];
        CGFloat touchX = point.x;
        CGFloat touchY = point.y;
        touchX *= 1/self.scrollview.zoomScale;
        touchY *= 1/self.scrollview.zoomScale;
        touchX += self.scrollview.contentOffset.x;
        touchY += self.scrollview.contentOffset.y;
        CGRect zoomRect = [self zoomRectForScale:self.scrollview.maximumZoomScale withCenter:CGPointMake(touchX, touchY)];
        [self.scrollview zoomToRect:zoomRect animated:YES];
    }
}

- (void)resetZoomScale
{
    self.scrollview.maximumZoomScale = 1.0;
    self.scrollview.minimumZoomScale = 1.0;
}

#pragma mark - public method
/**
 *  显示图片
 *
 *  @param photo 图片
 */
- (void)setShowImage:(KPhoto *)photo
{
    self.photo = photo;
    self.photoImageView.image = photo.defaultImage;
    [self setMaxAndMinZoomScales];
    [self setNeedsLayout];
    self.progress = 1.0;
    self.hasLoadedImage = YES;
}

/**
 *  显示图片
 *
 *  @param photo       图片的高清大图链接
 */
- (void)setShowHighQualityImageWithPhoto:(KPhoto *)photo
{
    NSURL *url = nil;
    if (photo.imageUrl) {
        url = [NSURL URLWithString:photo.imageUrl];
    }
    if (!url) {
        [self setShowImage:photo];
        return;
    }
    
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[url absoluteString]];
    if (cacheImage) {
        KPhoto *photo = [KPhoto new];
        photo.defaultImage = cacheImage;
        [self setShowImage:photo];
        return;
    }
    
    self.photoImageView.image = photo.defaultImage;
    [self setMaxAndMinZoomScales];
    
    __weak typeof(self) weakSelf = self;
    
    [self addSubview:self.progressView];;
    self.progressView.mode = KProgressViewProgressMode;
    self.imageURL = url;
    
    if ([photo.imageUrl containsString:@"/storage/msgs"]) {
        NSString *imagePath = [kDocDir stringByAppendingPathComponent:photo.imageUrl];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        [self.progressView removeFromSuperview];
        [self.stateLabel removeFromSuperview];
        if (image == nil) {
            self.photoImageView.image = photo.defaultImage;
        }
        else {
            KPhoto *photo = [KPhoto new];
            photo.defaultImage = image;
            [self setShowImage:photo];
            [self.photoImageView setNeedsDisplay];
            [self setMaxAndMinZoomScales];
            self.photoImageView.image = image;
        }
    }
    else {
        
        [weakSelf.photoImageView sd_setImageWithURL:url placeholderImage:photo.defaultImage options:SDWebImageRetryFailed | SDWebImageLowPriority | SDWebImageHandleCookies progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (expectedSize > 0) {
                    strongSelf.progress = (CGFloat)receivedSize / expectedSize ;
                    //                NSLog(@"targetURL %@ , strongSelf %@ , strongSelf.imageURL = %@ , progress = %f",targetURL , strongSelf , strongSelf.imageURL,strongSelf.progress);
                }
            });
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.progressView removeFromSuperview];
            if (error) {
                [strongSelf setMaxAndMinZoomScales];
                //[strongSelf addSubview:strongSelf.stateLabel];
                KPBLog(@"加载图片失败 , 图片链接imageURL = %@ , 错误信息: %@ ,检查是否开启允许HTTP请求",imageURL,error);
            } else {
                [strongSelf.stateLabel removeFromSuperview];
                [UIView animateWithDuration:0.25 animations:^{
                    KPhoto *photo = [KPhoto new];
                    photo.defaultImage  = image;
                    [strongSelf setShowImage:photo];
                    [strongSelf.photoImageView setNeedsDisplay];
                    [strongSelf setMaxAndMinZoomScales];
                }];
            }
        }];
    }
}

/**
 *  根据图片和屏幕比例关系,调整最大和最小伸缩比例
 */
- (void)setMaxAndMinZoomScales
{
    if (!_photo.videoUrl)
    {
        [self.videoPlayer setHidden:YES];
        
        if (![self.gestureRecognizers containsObject:self.singleTapBackgroundView]) {
            [self addGestureRecognizer:self.singleTapBackgroundView];
        }
        if (![self.gestureRecognizers containsObject:self.doubleTapBackgroundView]) {
            [self addGestureRecognizer:self.doubleTapBackgroundView];
        }
        
        [_photoImageView setHidden:NO];
        UIImage *image = self.photoImageView.image;
        if (image == nil || image.size.height==0) {
            return;
        }
        
        CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
        self.photoImageView.mj_w = self.mj_w;
        self.photoImageView.mj_h = self.mj_w / imageWidthHeightRatio;
        self.photoImageView.mj_x = 0;
        if (self.photoImageView.mj_h > MSHEIGHT) {
            self.photoImageView.mj_y = 0;
            self.scrollview.scrollEnabled = YES;
        } else {
            self.photoImageView.mj_y = (MSHEIGHT - self.photoImageView.mj_h ) * 0.5;
            self.scrollview.scrollEnabled = NO;
        }
        self.scrollview.maximumZoomScale = MAX(MSHEIGHT / self.photoImageView.mj_h, 3.0);
        self.scrollview.minimumZoomScale = 1.0;
        self.scrollview.zoomScale = 1.0;
        self.scrollview.contentSize = CGSizeMake(self.photoImageView.mj_w, MAX(self.photoImageView.mj_h, MSHEIGHT));
    }
    else
    {
        self.photoImageView.frame = CGRectMake(0, 0, MSWIDTH, MSHEIGHT);
        
        [self removeGestureRecognizer:self.doubleTapBackgroundView];
        [self.videoPlayer setHidden:NO];
        self.videoPlayer.frame = CGRectMake(self.scrollview.mj_x, self.scrollview.mj_y, self.scrollview.mj_w, self.scrollview.mj_h);
        [self.videoPlayer setVideoUrl:[NSURL URLWithString:self.photo.videoUrl]];
        if (self.isAutoPlay) {
            [self.videoPlayer play];
        }
        
    }
}

- (void)videoPlayView:(KVideoPlayView *)videoPlayView clickBackButton:(UIButton *)back
{
    if (self.zoomingScrollViewdelegate && [self.zoomingScrollViewdelegate respondsToSelector:@selector(zoomingScrollView:singleTapDetected:)])
    {
        [self.zoomingScrollViewdelegate zoomingScrollView:self singleTapDetected:self.singleTapBackgroundView];
    }
}

/**
 *  重用，清理资源
 */
- (void)prepareForReuse
{
    [self setMaxAndMinZoomScales];
    
    self.progress               = 0;
    self.photoImageView.image   = nil;
    self.hasLoadedImage         = NO;
    
    [self.stateLabel removeFromSuperview];
    [self.progressView removeFromSuperview];
}

@end
