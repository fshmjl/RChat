//
//  KVideoViewController.m
//  KXiniuCloud
//
//  Created by eims on 2018/5/15.
//  Copyright © 2018年 EIMS. All rights reserved.
//

#import "KVideoViewController.h"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import "NSDate+KCategory.h"

#import "KPlayer.h"
#import "KFileManagement.h"
#import "KVideoProgressView.h"
#import "KSystemAuthorization.h"

//时间大于这个就是视频，否则为拍照
#define TimeMax 0.5
typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);


@interface KVideoViewController ()<AVCaptureFileOutputRecordingDelegate>


// 视频输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput   *captureMovieFileOutput;
// 负责从AVCaptureDevice获得输入数据
@property (nonatomic, strong) AVCaptureDeviceInput       *captureDeviceInput;
// 后台任务标识
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@property (nonatomic, assign) UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier;
// 图像预览层，实时显示捕获的图像
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

// 负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession           *session;

@property (nonatomic, strong) AVCaptureDevice *captureDevice;

// 轻触拍照，按住摄像
@property (nonatomic, strong) UILabel       *labelTipTitle;
// 聚焦光标
@property (nonatomic, strong) UIImageView   *focusCursor;

@property (nonatomic, strong) UIButton      *btnBack;
// 重新录制
@property (nonatomic, strong) UIButton      *btnAfresh;
// 确定
@property (nonatomic, strong) UIButton      *btnEnsure;
// 摄像头切换
@property (nonatomic, strong) UIButton      *btnCamera;

@property (nonatomic, strong) UIImageView   *bgView;

@property (nonatomic, strong) UIImage       *takeImage;
// 图片路径
@property (nonatomic, strong) NSString      *imagePath;

@property (nonatomic, strong) UIImageView   *takeImageView;

@property (nonatomic, strong) UIImageView   *imgRecord;
// 视频播放
@property (nonatomic, strong) KPlayer       *player;

@property (nonatomic, strong) KVideoProgressView *progressView;

// 记录录制的时间 默认最大60秒
@property (nonatomic, assign) CGFloat       seconds;

// 记录需要保存视频的路径
@property (nonatomic, strong) NSURL         *saveVideoUrl;

// 是否在对焦
@property (nonatomic, assign) BOOL          isFocus;

// 是否是摄像 YES 代表是录制  NO 表示拍照
@property (nonatomic, assign) BOOL          isVideo;
// 视频存放路径
@property (nonatomic, strong) NSString *outputFielPath;

@end


@implementation KVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    if (self.maxDuration == 0) {
        self.maxDuration = 10;
    }
    
    [self performSelector:@selector(hiddenTipsLabel) withObject:nil afterDelay:3];
}

- (void)initView {
    
    CGFloat spacingBetweenButton = MSWIDTH / 4.;
    CGFloat topSpace = IS_iPhoneX ? 88.f : 0;
    CGFloat bottomSpace = IS_iPhoneX ? 83.f : 0;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.bgView = [UIImageView new];
    self.bgView.userInteractionEnabled = YES;
    [self.view addSubview:self.bgView];
    self.bgView.sd_layout.topSpaceToView(self.view, topSpace).leftEqualToView(self.view).bottomSpaceToView(self.view, bottomSpace).rightEqualToView(self.view);
    
    [self addGenstureRecognizer];
    
    self.focusCursor = [[UIImageView alloc] initWithFrame:CGRectMake(28, 106, 60, 60)];
    self.focusCursor.image = [UIImage imageNamed:@"icon_inputBox_more_takeVideo_focusing"];
    [self.view addSubview:self.focusCursor];
    [self performSelector:@selector(onHiddenFocusCurSorAction) withObject:nil afterDelay:0.5];
    
    self.progressView = [KVideoProgressView new];
    self.progressView.backgroundColor = [ColorTools colorWithHexString:@"0xd8d4d0"];
    [self.progressView setHidden:YES];
    [self.view addSubview:self.progressView];
    self.progressView.sd_layout.centerXEqualToView(self.bgView).bottomSpaceToView(self.view, 90 + kTabbarSafeBottomMargin).widthIs(120).heightIs(120);
    
    self.progressView.layer.cornerRadius  = self.progressView.frame.size.width/2;
    self.progressView.layer.masksToBounds = YES;
    
    self.labelTipTitle = [UILabel new];
    self.labelTipTitle.textColor = [UIColor whiteColor];
    self.labelTipTitle.font = [UIFont systemFontOfSize:15];
    self.labelTipTitle.text = @"轻触拍照，按住摄像";
    self.labelTipTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelTipTitle];
    self.labelTipTitle.sd_layout.bottomSpaceToView(self.progressView, 5).centerXEqualToView(self.view).widthIs(140).heightIs(20);
    
    // 返回按钮
    self.btnBack = [UIButton new];
    [self.btnBack setImage:[UIImage imageNamed:@"icon_inputBox_more_takeVideo_back"] forState:UIControlStateNormal];
    [self.btnBack addTarget:self action:@selector(onCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnBack];
    self.btnBack.sd_layout.centerXIs((MSWIDTH/2. - 67/2.)/2.).centerYEqualToView(self.progressView).widthIs(40).heightIs(40);
    
    // 录制按钮
    self.imgRecord = [UIImageView new];
    self.imgRecord.userInteractionEnabled = YES;
    self.imgRecord.image = [UIImage imageNamed:@"icon_inputBox_more_takeVideo_photograph"];
    [self.view addSubview:self.imgRecord];
    self.imgRecord.sd_layout.centerYEqualToView(self.progressView).centerXEqualToView(self.progressView).widthIs(74).heightIs(74);
    
    // 取消，重拍
    self.btnAfresh = [UIButton new];
    [self.btnAfresh setImage:[UIImage imageNamed:@"icon_inputBox_more_takeVideo_cancel"] forState:UIControlStateNormal];
    [self.btnAfresh setHidden:YES];
    [self.btnAfresh addTarget:self action:@selector(onAfreshAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnAfresh];
    self.btnAfresh.sd_layout.centerXIs(spacingBetweenButton).centerYEqualToView(self.progressView).widthIs(74).heightIs(74);
    
    // 选择图片按钮
    self.btnEnsure = [UIButton new];
    [self.btnEnsure setImage:[UIImage imageNamed:@"icon_inputBox_more_takeVideo_confirm"] forState:UIControlStateNormal];
    [self.btnEnsure setHidden:YES];
    [self.btnEnsure addTarget:self action:@selector(onEnsureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnEnsure];
    self.btnEnsure.sd_layout.centerXIs(spacingBetweenButton * 3).centerYEqualToView(self.progressView).widthIs(74).heightIs(74);
    
    // 切换镜头
    self.btnCamera = [UIButton new];
    [self.btnCamera setImage:[UIImage imageNamed:@"icon_inputBox_more_takeVideo_camera"] forState:UIControlStateNormal];
    [self.btnCamera addTarget:self action:@selector(onCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnCamera];
    
    CGFloat topMargin = IS_iPhoneX ? 88 - 20 : 0;
    self.btnCamera.sd_layout.topSpaceToView(self.view, 25 + topMargin).rightSpaceToView(self.view, 20).widthIs(30).heightIs(30);
    
}

- (void)hiddenTipsLabel {
    self.labelTipTitle.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self customCamera];
    [self.session startRunning];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}


- (BOOL)prefersStatusBarHidden {
    [super prefersStatusBarHidden];
    return YES;
}

- (AVCaptureSession *)session {
    if (!_session) {
        //初始化会话，用来结合输入输出
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureDevice *)captureDevice {
    if (!_captureDevice) {
        //取得后置摄像头
        _captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    }
    return _captureDevice;
}

- (AVCaptureDeviceInput *)captureDeviceInput {
    if (!_captureDeviceInput) {
        
        //初始化输入设备
        NSError *error = nil;
        _captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:&error];
        if (error) {
            
        }
    }
    return _captureDeviceInput;
}

- (AVCaptureMovieFileOutput *)captureMovieFileOutput {
    if (!_captureMovieFileOutput) {
        //输出对象
        _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];//视频输出
    }
    return _captureMovieFileOutput;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        //创建视频预览层，用于实时展示摄像头状态
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    }
    return _previewLayer;
}


- (void)customCamera {

    //设置分辨率 (设备支持的最高分辨率)
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    //添加音频
    NSError *error = nil;
    AVCaptureDeviceInput *audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //将输入设备添加到会话
    if ([self.session canAddInput:self.captureDeviceInput]) {
        [self.session addInput:self.captureDeviceInput];
        [self.session addInput:audioCaptureDeviceInput];
        //设置视频防抖
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        }
    }
    
    //将输出设备添加到会话 (刚开始 是照片为输出对象)
    if ([self.session canAddOutput:self.captureMovieFileOutput]) {
        [self.session addOutput:self.captureMovieFileOutput];
    }
    
    CGFloat topSpace = IS_iPhoneX ? 88.f : 0;
    CGFloat bottomSpace = IS_iPhoneX ? 83.f : 0;
    
    
    self.previewLayer.frame = CGRectMake(0, 0, self.view.width, self.view.height - bottomSpace - topSpace);
//    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
//    self.bgView.frame = CGRectMake(0, 0, self.view.width, self.view.height - bottomSpace - topSpace);
    [self.bgView.layer addSublayer:self.previewLayer];
    
    
    [self addNotificationToCaptureDevice:self.captureDevice];
    
}

- (void)onCancelAction:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{    
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    if ([[touches anyObject] view] == self.imgRecord) {
        //根据设备输出获得连接
        AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeAudio];
        //根据连接取得设备输出的数据
        if (![self.captureMovieFileOutput isRecording]) {
//            self.imgRecord.sd_layout.widthIs(64).heightIs(64);
            //如果支持多任务则开始多任务
            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            if (self.saveVideoUrl) {
                [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
            }
            //预览图层和视频方向保持一致
            connection.videoOrientation = [self.previewLayer connection].videoOrientation;
            
            NSString *fileName = [NSString stringWithFormat:@"%@.mov", [NSDate getCurrentTimestamp]];
            
            _outputFielPath = [KAttachmentTempPath stringByAppendingPathComponent:fileName];
            NSLog(@"save path is :%@",_outputFielPath);
            NSURL *fileUrl = [NSURL fileURLWithPath:_outputFielPath];
//            NSLog(@"fileUrl:%@",fileUrl);

            [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        } else {
            [self.captureMovieFileOutput stopRecording];
        }
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([[touches anyObject] view] == self.imgRecord) {
//        self.imgRecord.sd_layout.widthIs(74).heightIs(74);
//        NSLog(@"结束触摸");
        if (!self.isVideo) {
            [self performSelector:@selector(endRecord) withObject:nil afterDelay:0.1];
        } else {
            [self endRecord];
        }
    }
}

- (void)endRecord {
    [self.captureMovieFileOutput stopRecording];//停止录制
}

- (void)onAfreshAction:(UIButton *)sender {
    [self recoverLayout];
}

- (void)onEnsureAction:(UIButton *)sender
{
    if ([[KSystemAuthorization shareInstance] checkPhotoAlbumAuthorization]) {
        [self save];
    }
}

- (void)save
{
    if (self.saveVideoUrl)
    {
        kWeakSelf
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                
                if (weakSelf.takeBlock)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        weakSelf.takeBlock(weakSelf.saveVideoUrl, weakSelf.outputFielPath);
                        [weakSelf onCancelAction:nil];
                    });
                }
                
            }else {
                NSLog(@"视频保存错误error：%@",error);
            }
        }];
    }
    else
    {
        if (self.takeImage) {
            //照片
            UIImageWriteToSavedPhotosAlbum(self.takeImage, self, nil, nil);
            NSString *fileName = [NSString stringWithFormat:@"%@.png", [NSDate getCurrentTimestamp]];
            // 保存文件的名称
            self.imagePath = [KAttachmentTempPath stringByAppendingPathComponent:fileName];
            // 保存成功会返回YES
            BOOL result = [UIImagePNGRepresentation(self.takeImage) writeToFile:self.imagePath atomically:YES];
            if (!result) {
                NSLog(@"保存图片失败");
            }
            if (self.takeBlock) {
                self.takeBlock(self.takeImage, self.imagePath);
            }
            
            [self onCancelAction:nil];
        }
        else
        {
            [SVProgressHUD showImage:[UIImage imageNamed:@""] status:@"拍摄获取图片失败,请重试"];
            [self onAfreshAction:nil];
        }
    }
    
}

// 前后摄像头的切换
- (void)onCameraAction:(UIButton *)sender {

    AVCaptureDevice *currentDevice = [self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront; // 前
    if (currentPosition == AVCaptureDevicePositionUnspecified ||
        currentPosition == AVCaptureDevicePositionFront)
    {
        toChangePosition = AVCaptureDevicePositionBack; // 后
    }
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    
    // 获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.session beginConfiguration];
    //移除原有输入对象
    [self.session removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.session canAddInput:toChangeDeviceInput]) {
        [self.session addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    //提交会话配置
    [self.session commitConfiguration];
}

- (void)onStartTranscribe:(NSURL *)fileURL
{
    if ([self.captureMovieFileOutput isRecording])
    {
        self.seconds = self.seconds - 0.01;
        if (self.seconds > 0)
        {
            CGFloat s = self.maxDuration - self.seconds;
            if (s >= TimeMax && !self.isVideo)
            {
                self.isVideo = YES;//长按时间超过TimeMax 表示是视频录制
                self.progressView.timeMax = self.seconds;
            }
            
            [self performSelector:@selector(onStartTranscribe:) withObject:fileURL afterDelay:0.01];
        }
        else
        {
            if ([self.captureMovieFileOutput isRecording]) {
                [self.captureMovieFileOutput stopRecording];
            }
        }
    }
}

#pragma mark - 视频输出代理
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    self.seconds = self.maxDuration;
    [self performSelector:@selector(onStartTranscribe:) withObject:fileURL afterDelay:0.];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    [self changeLayout];
    
    if (self.isVideo)
    {
        self.saveVideoUrl = outputFileURL;
        // 当录制的视频小于1秒时当做图片处理
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:outputFileURL options:opts];  // 初始化视频媒体文件
        int second = (int)urlAsset.duration.value / (int)urlAsset.duration.timescale; // 获取视频总时长,单位秒
        if (second < 1) {
            //照片
            self.saveVideoUrl = nil;
            [self videoHandlePhoto:outputFileURL];
        }
        else {
            if (!self.player) {
                self.player = [[KPlayer alloc] initWithFrame:self.bgView.bounds withShowInView:self.bgView url:outputFileURL];
            } else {
                if (outputFileURL) {
                    self.player.videoUrl = outputFileURL;
                    self.player.hidden = NO;
                }
            }
        }
    } else {
        //照片
        self.saveVideoUrl = nil;
        [self videoHandlePhoto:outputFileURL];
    }
    
}

- (void)videoHandlePhoto:(NSURL *)url
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
        
        int timescale = urlSet.duration.timescale;
        NSLog(@"timescale:%d",timescale);
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
        imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
        
        // 缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要获取某一秒的第几帧可以使用CMTimeMake方法)
        CMTime time = CMTimeMake(0,timescale);
        
        NSError *error = nil;
        CMTime actucalTime; //缩略图实际生成的时间
        CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
        if (error) {
            NSLog(@"截取视频图片失败:%@",error.localizedDescription);
            return;
        }
        
        CMTimeShow(actucalTime);
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        
        CGImageRelease(cgImage);
        if (!image) {
            NSLog(@"视频截取失败");
        }
        
        self.takeImage = image;
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        
        [self takeImageView];
        self.takeImageView.hidden = NO;
        self.takeImageView.image  = self.takeImage;
        
    });
}

- (UIImageView *)takeImageView
{
    if (!_takeImageView) {
        CGFloat leftMargin = IS_iPhoneX ? 8 : 0;
        _takeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftMargin, 0, MSWIDTH - leftMargin * 2, self.bgView.mj_h)];
        [self.bgView addSubview:_takeImageView];
    }
    
    return _takeImageView;
}

#pragma mark - 通知
- (void)setupObservers
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
}

// 进入后台就退出视频录制
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self onCancelAction:nil];
}

/**
 *  给输入设备添加通知
 */
- (void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled =YES;
    }];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
- (void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
//    NSLog(@"设备已连接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
//    NSLog(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
//    NSLog(@"捕获区域改变...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
//    NSLog(@"会话发生错误.");
}



/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        //自动白平衡
        if ([captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动根据环境条件开启闪光灯
        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
        
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}
/**
 *  设置聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 *  设置曝光模式
 *
 *  @param exposureMode 曝光模式
 */
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
//        if ([captureDevice isFocusPointOfInterestSupported]) {
//            [captureDevice setFocusPointOfInterest:point];
//        }
//        if ([captureDevice isExposurePointOfInterestSupported]) {
//            [captureDevice setExposurePointOfInterest:point];
//        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}

/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.bgView addGestureRecognizer:tapGesture];
}

-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    if ([self.session isRunning]) {
        CGPoint point = [tapGesture locationInView:self.bgView];
        //将UI坐标转化为摄像头坐标
        CGPoint cameraPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
        [self setFocusCursorWithPoint:point];
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:cameraPoint];
    }
}

/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    if (!self.isFocus) {
        self.isFocus = YES;
        self.focusCursor.center =point;
        self.focusCursor.transform = CGAffineTransformMakeScale(1.25, 1.25);
        self.focusCursor.alpha = 1.0;
        [UIView animateWithDuration:0.5 animations:^{
            self.focusCursor.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self performSelector:@selector(onHiddenFocusCurSorAction) withObject:nil afterDelay:0.5];
        }];
    }
}

- (void)onHiddenFocusCurSorAction {
    self.focusCursor.alpha = 0;
    self.isFocus = NO;
}

//拍摄完成时调用
- (void)changeLayout {
    self.imgRecord.hidden = YES;
    self.btnCamera.hidden = YES;
    self.btnAfresh.hidden = NO;
    self.btnEnsure.hidden = NO;
    self.btnBack.hidden = YES;
    if (self.isVideo) {
        [self.progressView clearProgress];
    }
//    self.afreshCenterX.constant = -(MSWIDTH/2/2);
//    self.ensureCenterX.constant = MSWIDTH/2/2;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    self.lastBackgroundTaskIdentifier = self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    [self.session stopRunning];
}


//重新拍摄时调用
- (void)recoverLayout {
    if (self.isVideo) {
        self.isVideo = NO;
        [self.player stopPlayer];
        self.player.hidden = YES;
    }
    [self.session startRunning];
    
    if (!self.takeImageView.hidden) {
        self.takeImageView.hidden = YES;
    }
    
    self.imgRecord.hidden = NO;
    self.btnCamera.hidden = NO;
    self.btnAfresh.hidden = YES;
    self.btnEnsure.hidden = YES;
    self.btnBack.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
