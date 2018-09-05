//
//  KVideoPlayView.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/17.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KVideoPlayView.h"

#import <AVFoundation/AVFoundation.h>

@interface KVideoPlayView ()

// 取消按钮
@property (nonatomic, strong) UIButton *cancelBtn;
// 底部播放按钮
@property (nonatomic, strong) UIButton *playBtn;
// 进度条
@property (nonatomic, strong) UISlider *slider;
// 播放器
@property (nonatomic, strong) AVPlayer *player;
// 开始时间
@property (nonatomic, strong) UILabel *currentTime;
// 结束时间
@property (nonatomic, strong) UILabel *endTime;
// 正在播放
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVURLAsset *urlAsset;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
// 中间的播放按钮
@property (nonatomic, strong) UIButton *playButton;

@end

@implementation KVideoPlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.playerLayer.frame = frame;
}

- (void)initView {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    self.player                     = [AVPlayer playerWithPlayerItem:[self getAVPlayerItem]];

    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame          = self.bounds;
    
    [self.layer addSublayer:self.playerLayer];

    self.cancelBtn                  = [[UIButton alloc] init];
    [self.cancelBtn setImage:[UIImage imageNamed:@"icon_inputBox_videoPlay_cancel"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelBtn];
    
    CGFloat topSpace = IS_iPhoneX ? 88 : 0;
    self.cancelBtn.sd_layout.topSpaceToView(self, 30 + topSpace).leftSpaceToView(self, 30).widthIs(20).heightIs(20);

    self.playBtn                    = [[UIButton alloc] init];
    [self.playBtn setImage:[UIImage imageNamed:@"icon_inputBox_video_ pause"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playBtn];
    
    CGFloat bottomSpace = IS_iPhoneX ? 83.f : 0;
    self.playBtn.sd_layout.bottomSpaceToView(self, 20 + bottomSpace).leftSpaceToView(self, 20).widthIs(20).heightIs(20);
    if (self.videoUrl) {
        NSDictionary *opts     = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        
        AVURLAsset *urlAsset   = [AVURLAsset URLAssetWithURL:self.videoUrl options:opts];// 初始化视频媒体文件
        int second             = (int)urlAsset.duration.value / (int)urlAsset.duration.timescale;// 获取视频总时长,单位秒
        
        self.currentTime            = [[UILabel alloc] init];
        self.currentTime.textColor  = [UIColor whiteColor];
        self.currentTime.font       = [UIFont systemFontOfSize:12];
        self.currentTime.text       = @"00:00";
        [self addSubview:self.currentTime];
        CGSize currentTimeSize = [self.currentTime sizeThatFits:CGSizeMake(100, 20)];
        self.currentTime.sd_layout.leftSpaceToView(self.playBtn, 15).centerYEqualToView(self.playBtn).widthIs(currentTimeSize.width).heightIs(currentTimeSize.height);
        
        self.endTime            = [[UILabel alloc] init];
        self.endTime.textColor  = [UIColor whiteColor];
        self.endTime.font       = [UIFont systemFontOfSize:12];
        self.endTime.text       = [NSString stringWithFormat:@"00:%02d", second];
        [self addSubview:self.endTime];
        CGSize endTimeSize = [self.endTime sizeThatFits:CGSizeMake(100, 20)];
        self.endTime.sd_layout.centerYEqualToView(self.playBtn).rightSpaceToView(self, 10).widthIs(endTimeSize.width).heightIs(endTimeSize.height);
        
        self.slider                     = [[UISlider alloc] init];
        self.slider.tintColor           = [UIColor whiteColor];
        self.slider.backgroundColor     = [UIColor lightGrayColor];
        [self.slider setThumbImage:[UIImage imageNamed:@"icon_inputBox_thumb"] forState:UIControlStateNormal];
        [self.slider setThumbImage:[UIImage imageNamed:@"icon_inputBox_thumb"] forState:UIControlStateHighlighted];
        self.slider.continuous          = YES;
        self.slider.layer.cornerRadius  = 2;
        [self.slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.slider];
        
        self.slider.sd_layout.leftSpaceToView(self.currentTime, 10).centerYEqualToView(self.playBtn).rightSpaceToView(self.endTime, 10).heightIs(4);
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"icon_inputBox_video_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
        _playButton.sd_layout.centerXEqualToView(self).centerYEqualToView(self).widthIs(60).heightIs(60);
        [self hiddenSubview];
    }

}

- (void)back:(UIButton *)sender {
    [self stop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayView:clickBackButton:)]) {
        [self.delegate videoPlayView:self clickBackButton:self.self.cancelBtn];
    }
}

- (AVPlayerItem *)getAVPlayerItem {
    NSDictionary *options    = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    AVURLAsset *urlAsset     = [[AVURLAsset alloc] initWithURL:_videoUrl options:options];
    self.urlAsset = urlAsset;
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    return playerItem;
}

- (AVPlayerItem *)playerItem {
    return self.player.currentItem;
}

- (void)setVideoUrl:(NSURL *)videoUrl {
    _videoUrl = videoUrl;
    [self removePlayer];
    [self nextPlayer];
}

- (void)play {
    [self.player play];
    [self.playButton setHidden:YES];
    self.isPlaying = YES;
}

- (void)stop {
    _isPlaying = NO;
    [self.player pause];
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.playButton setHidden:NO];
}

//将数值转换成时间
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSinceNow:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

- (void)playAction:(UIButton *)sender {
    
    if ([sender isEqual:_playButton]) {
        [_playButton setHidden:YES];
    }
    
    if (_isPlaying) {
        _isPlaying = NO;
        [self.player pause];
        [self.playBtn setImage:[UIImage imageNamed:@"icon_inputBox_video_bttom_play"] forState:UIControlStateNormal];
    }
    else {
        _isPlaying = YES;
        [self play];
        [self.playBtn setImage:[UIImage imageNamed:@"icon_inputBox_video_ pause"] forState:UIControlStateNormal];
        
    }
}

- (void)nextPlayer {

    [self.player replaceCurrentItemWithPlayerItem:[self getAVPlayerItem]];
    [self addAVPlayerItem:self.player.currentItem];
    NSArray *keys              = @[@"duration"];
    kWeakSelf
    [self.urlAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [self.urlAsset statusOfValueForKey:@"duration" error:&error];
        switch (tracksStatus) {
            case AVKeyValueStatusLoaded:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!CMTIME_IS_INDEFINITE(self.urlAsset.duration)) {
                        CGFloat second = self.urlAsset.duration.value / self.urlAsset.duration.timescale;
                        self.endTime.text = [self convertTime:second];
                        self.slider.minimumValue = 0;
                        self.slider.maximumValue = second;
                    }
                });
            }
                break;
            case AVKeyValueStatusFailed:
            {
                //NSLog(@"AVKeyValueStatusFailed失败,请检查网络,或查看plist中是否添加App Transport Security Settings");
            }
                break;
            case AVKeyValueStatusCancelled:
            {
                NSLog(@"AVKeyValueStatusCancelled取消");
            }
                break;
            case AVKeyValueStatusUnknown:
            {
                NSLog(@"AVKeyValueStatusUnknown未知");
            }
                break;
            case AVKeyValueStatusLoading:
            {
                NSLog(@"AVKeyValueStatusLoading正在加载");
            }
                break;
        }
    }];
    
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.f, 1.f) queue:NULL usingBlock:^(CMTime time) {
//        AVPlayerItem *playerItem = weakSelf.player.currentItem;
        weakSelf.slider.value = weakSelf.playerItem.currentTime.value/weakSelf.playerItem.currentTime.timescale;
        weakSelf.currentTime.text = [weakSelf convertTime:weakSelf.slider.value];
    }];
}


- (void)sliderAction:(UISlider *)slider {
    CGFloat value = slider.value;
    self.currentTime.text = [self convertTime:value];
    
    CMTime pointTime = CMTimeMake(value * self.playerItem.currentTime.timescale, self.playerItem.currentTime.timescale);
    [self.player seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)addAVPlayerItem:(AVPlayerItem *)playerItem {
    //监控状态属性
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];

}

- (void)removePlayer {
    AVPlayerItem *playerItem = self.player.currentItem;
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopPlayer {
    if (self.player.rate == 1) {
        [self.player pause];//如果在播放状态就停止
    }
}

/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
//            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = self.playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
    }
}

- (void)playbackFinished:(NSNotification *)notification {
    
    [self.playButton setHidden:NO];
    [self.playerItem seekToTime:kCMTimeZero];
    [self.player seekToTime:CMTimeMake(0, 1)];
    _isPlaying = NO;
    [self.playBtn setImage:[UIImage imageNamed:@"icon_inputBox_video_bttom_play"] forState:UIControlStateNormal];

}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
    [self showSubview];
}

- (void)hiddenSubview {
    
    [self.cancelBtn setHidden:YES];
    [self.playBtn setHidden:YES];
    [self.currentTime setHidden:YES];
    [self.slider setHidden:YES];
    [self.endTime setHidden:YES];
}

- (void)showSubview {
    [self.cancelBtn setHidden:NO];
    [self.playBtn setHidden:!_isPlaying];
    [self.currentTime setHidden:!_isPlaying];
    [self.slider setHidden:!_isPlaying];
    [self.endTime setHidden:!_isPlaying];
    
    [self performSelector:@selector(hiddenSubview) withObject:nil afterDelay:3];
}

- (void)dealloc {
    [self removePlayer];
    [self stopPlayer];
    self.player = nil;
}

@end
