//
//  KInputBoxRecorderView.m
//  KXiniuCloud
//
//  Created by RPK on 2018/5/7.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KInputBoxRecorderView.h"

// 录音时间太短 提示图片
#define tooShortImage [UIImage imageNamed:@"icon_inputBox_recoder_too_short"]
// 录音撤销 提示图片
#define recallImage   [UIImage imageNamed:@"icon_inputBox_recorder_prompt_recall"]

static KInputBoxRecorderView *recorderPrompt = nil;

@implementation KInputBoxRecorderView

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorderPrompt = [[super allocWithZone:NULL] init];
        recorderPrompt.hidden = YES;
    });
    
    return recorderPrompt;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [KInputBoxRecorderView shareInstance];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {

        self.frame = CGRectMake(0, 0, 150, 150);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = bezierPath.CGPath;
        self.layer.mask = shapeLayer;
        
        self.leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.mj_w - 79) / 2, (self.mj_h - 70)/2., 42, 60)];
        self.leftImageView.image = [UIImage imageNamed:@"icon_inputBox_recorder_prompt_voice"];
        [self addSubview:self.leftImageView];
        
        self.rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_leftImageView.mj_x + 52, _leftImageView.mj_y, 27, 60)];
        self.rightImageView.image = [UIImage imageNamed:@"icon_inputBox_recorder_prompt1"];
        [self addSubview:self.rightImageView];

        self.recallImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        self.recallImageView.center = CGPointMake(self.center.x, self.center.y - 10);
        self.recallImageView.image = recallImage;
        [self addSubview:self.recallImageView];
        [self.recallImageView setHidden:YES];
        
        self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, self.mj_h - 30, self.mj_w - 20, 20)];
        self.prompt.textColor = [UIColor whiteColor];
        self.prompt.font = [UIFont systemFontOfSize:14];
        self.prompt.textAlignment = NSTextAlignmentCenter;
        self.prompt.text = @"手指上滑，取消发送";
        [self addSubview:self.prompt];
    
    }
    
    return self;
}

- (void)updateState:(KInputBoxRecordStatus)state
{
    [recorderPrompt setHidden:state == KInputBoxRecordStatusNone];
    [self.secondLabel setHidden:state == KInputBoxRecordStatusNone];
    
    if (state == KInputBoxRecordStatusRecording ||
        state == KInputBoxRecordStatusMoveInside)
    {
        [recorderPrompt setHidden:NO];
        [recorderPrompt.rightImageView setHidden:NO];
        [recorderPrompt.leftImageView setHidden:NO];
        [recorderPrompt.recallImageView setHidden:YES];
        [self.secondLabel setHidden:YES];
        recorderPrompt.prompt.text = @"手指上滑，取消发送";
        recorderPrompt.prompt.backgroundColor = [UIColor clearColor];
    }
    else if (state == KInputBoxRecordStatusMoveOutside)
    {
        [recorderPrompt setHidden:NO];
        [recorderPrompt.rightImageView setHidden:YES];
        [recorderPrompt.leftImageView setHidden:YES];
        [recorderPrompt.recallImageView setHidden:NO];
        [recorderPrompt.recallImageView setImage:recallImage];
        [self.secondLabel setHidden:YES];
        recorderPrompt.prompt.text = @"松开手指，取消发送";
        recorderPrompt.prompt.backgroundColor = [ColorTools colorWithHexString:@"0x953729"];
    }
    else if (state == KInputBoxRecordStatusCancel ||
             state == KInputBoxRecordStatusEnd ||
             state == KInputBoxRecordStatusNone)
    {
        [recorderPrompt setHidden:YES];
    }
    else if (state == KInputBoxRecordStatusTooShort)
    {
        [recorderPrompt setHidden:NO];
        [recorderPrompt.rightImageView setHidden:YES];
        [recorderPrompt.leftImageView setHidden:YES];
        [recorderPrompt.recallImageView setHidden:NO];
        [recorderPrompt.recallImageView setImage:tooShortImage];
        recorderPrompt.prompt.text = @"说话时间太短!";
        recorderPrompt.prompt.backgroundColor = [UIColor clearColor];
    }
}

- (UILabel *)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 120, 120)];
        _secondLabel.font = [UIFont systemFontOfSize:100];
        _secondLabel.textColor = [UIColor whiteColor];
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_secondLabel];
    }
    return _secondLabel;
}

- (void)updateSecond:(NSInteger)second
{
    NSInteger remainingTime = MAX_VOICE_LENGTH - second;
    // 录音时长超过了50秒，需要显示倒计时
    if (remainingTime <= 10000)
    {
        if (remainingTime % 1000 == 0)
        {
            [recorderPrompt.leftImageView setHidden:YES];
            [recorderPrompt.rightImageView setHidden:YES];
            self.secondLabel.hidden = NO;
            self.secondLabel.text = [NSString stringWithFormat:@"%ld", remainingTime/1000];
        }
    }
    
    if (remainingTime/1000 == 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self setHidden:YES];
            
            [recorderPrompt.leftImageView setHidden:NO];
            [recorderPrompt.rightImageView setHidden:NO];
            self.secondLabel.hidden = YES;
            [self.secondLabel removeFromSuperview];
            self.secondLabel = nil;
            
        });
    }
}

@end
