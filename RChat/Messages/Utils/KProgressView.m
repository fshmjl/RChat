//
//  KProgressView.m
//  KXiniuCloud
//
//  Created by RPK on 2018/2/6.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KProgressView.h"

@interface KProgressView()

@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation KProgressView

static dispatch_once_t onceToken;

+ (instancetype)shareInstance {

    static KProgressView *progressView = nil;

    dispatch_once(&onceToken, ^{
        progressView = [[KProgressView alloc] init];
    });

    return progressView;

}
                  
- (void)setupProgressUI {
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.progress          = 0; // 进度 默认为0.0∈[0.0,1.0]
    _progressView.backgroundColor   = [UIColor clearColor];
    _progressView.progressTintColor = [UIColor redColor];
    _progressView.trackTintColor    = KLineColor;  // 为走过的颜色
    _progressView.transform         = CGAffineTransformMakeScale(1.0f, 2.0f);
    [self addSubview:_progressView];
    
    _progressView.sd_layout.topSpaceToView(self, 0).leftSpaceToView(self, 0).rightSpaceToView(self, 0).heightIs(1);
    
}

- (void)setPressSlider:(float)value {
    
    [self.progressView setProgress:value animated:YES];
    if (value == 1) {
        [self hidePressSlider:YES];
    }
}

- (void)hidePressSlider:(BOOL)isHide {
    if (isHide) {
        _progressView.progress = 0;
    }
}

@end
