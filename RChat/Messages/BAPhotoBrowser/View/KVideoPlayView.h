//
//  KVideoPlayView.h
//  KXiniuCloud
//
//  Created by eims on 2018/5/17.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KVideoPlayView;
@protocol KVideoPlayViewDelegate <NSObject>

- (void)videoPlayView:(KVideoPlayView *)videoPlayView clickBackButton:(UIButton *)back;

@end


@interface KVideoPlayView : UIView

// 视频URL
@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, assign) id<KVideoPlayViewDelegate> delegate;

- (void)play;
- (void)stop;

@end
