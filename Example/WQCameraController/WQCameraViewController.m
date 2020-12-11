//
//  WQCameraViewController.m
//  WQCameraController_Example
//
//  Created by 祺祺 on 2020/12/9.
//  Copyright © 2020 YUER. All rights reserved.
//

#import "WQCameraViewController.h"
#import "WQCameraForVideoView.h"
#import "WQCameraForPhotoView.h"
#import "UIImage+GetImg.h"
@interface WQCameraViewController ()<WQCameraForVideoViewDelegate,WQCameraForPhotoViewDelegate>
@property(nonatomic,strong)UIView * preview;
@property(nonatomic,strong)WQCameraForVideoView * videoView;
@property(nonatomic,strong)WQCameraForPhotoView * photoView;
@property(nonatomic,strong)UIButton * cameraBtn;
@property(nonatomic,strong)UIButton * changeBtn;
@property(nonatomic,strong)UIButton * tropBtn;
@property(nonatomic,strong)UIButton * rePhotoBtn;
@property(nonatomic,strong)UISegmentedControl * segm;
@property(nonatomic,strong)UILabel * timeLab;

@property(nonatomic,assign)AVCaptureDevicePosition devicePosition;
@end

@implementation WQCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.preview];
    self.view.backgroundColor = [UIColor blackColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if(self.frameRate == 0){
        self.frameRate = 25;
    }
    self.devicePosition = AVCaptureDevicePositionBack;
    self.photoView = [[WQCameraForPhotoView alloc]initWithFrame:self.preview.bounds defaultDevicePosition:self.devicePosition];
    self.photoView.delegate = self;
    [self.preview addSubview:self.photoView];
    
    [self createMainView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillResignActiveNoti:) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)createMainView{
    self.cameraBtn = [[UIButton alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 80)/2, CGRectGetMaxY(self.preview.frame) + 10, 80, 80)];
    [self.cameraBtn setImage:[UIImage getImgWithBundleImgName:@"takePhotoIcon"] forState:UIControlStateNormal];
    [self.cameraBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cameraBtn];
    
    self.changeBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 55, CGRectGetMidY(self.cameraBtn.frame) - 15, 40, 40)];
    [self.changeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.changeBtn setImage:[UIImage getImgWithBundleImgName:@"changeDevice"] forState:UIControlStateNormal];
    [self.changeBtn addTarget:self action:@selector(changeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changeBtn];
    
    self.tropBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, CGRectGetMidY(self.cameraBtn.frame) - 15, 40, 40)];
    [self.tropBtn setImage:[UIImage getImgWithBundleImgName:@"flashclose"] forState:UIControlStateNormal];
    [self.tropBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.tropBtn addTarget:self action:@selector(tropBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tropBtn];
    self.segm = [[UISegmentedControl alloc]initWithItems:@[@"相机",@"视频"]];
    self.segm.frame = CGRectMake((CGRectGetWidth(self.view.frame)-100)/2, 10, 100, 40);
    self.segm.selectedSegmentIndex = 0;
    [self.segm addTarget:self action:@selector(segmChangeClick:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segm];
    
    if(self.showPresentBackBtn){
        UIButton * backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 15, 30, 30)];
        [backBtn setImage:[UIImage getImgWithBundleImgName:@"backIcon"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backBtn];
    }
}

-(void)backBtnClick:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.videoView && self.videoView.recording){
        [self.videoView stopRecord];
    }
}


-(void)segmChangeClick:(UISegmentedControl *)seg{
    if(seg.selectedSegmentIndex == 0){
        [self.videoView removeFromSuperview];
        self.videoView = nil;
        self.photoView = [[WQCameraForPhotoView alloc]initWithFrame:self.preview.bounds defaultDevicePosition:self.devicePosition];
        self.photoView.delegate = self;
        [self.preview addSubview:self.photoView];
    }else{
        [self.photoView removeFromSuperview];
        self.photoView = nil;
        self.videoView = [[WQCameraForVideoView alloc]initWithFrame:self.preview.bounds defaultDevicePosition:self.devicePosition frameRate:self.frameRate];
        self.videoView.delegate = self;
        [self.preview addSubview:self.videoView];
    }
    
}
-(void)tropBtnClick:(UIButton *)btn{
    if(self.videoView){
        if([self.videoView torchActiving]){
            [self.videoView closeTorch];
            [self.tropBtn setImage:[UIImage getImgWithBundleImgName:@"flashclose"] forState:UIControlStateNormal];
        }else{
            if([self.videoView torchSupported]){
                [self.videoView openTorch];
                [self.tropBtn setImage:[UIImage getImgWithBundleImgName:@"flashopen"] forState:UIControlStateNormal];
            }
        }
    }else{
        if([self.photoView flashActiving]){
            [self.photoView closeFlash];
            [self.tropBtn setImage:[UIImage getImgWithBundleImgName:@"flashclose"] forState:UIControlStateNormal];
        }else{
            if([self.photoView flashSupported]){
                [self.photoView openFlash];
                [self.tropBtn setImage:[UIImage getImgWithBundleImgName:@"flashopen"] forState:UIControlStateNormal];
            }
        }
    }
    
}

-(void)cameraBtnClick:(UIButton *)btn{
    if(self.videoView){
        if([self.videoView recording]){
            [self.videoView stopRecord];
            self.segm.hidden        = NO;
            self.tropBtn.hidden     = NO;
            self.changeBtn.hidden   = NO;
            [self.timeLab removeFromSuperview];
            [self.cameraBtn setImage:[UIImage getImgWithBundleImgName:@"takePhotoIcon"] forState:UIControlStateNormal];
        }else{
            [self.videoView startRecord];
            self.segm.hidden        = YES;
            self.tropBtn.hidden     = YES;
            self.changeBtn.hidden   = YES;
            [self.view addSubview:self.timeLab];
            [self.cameraBtn setImage:[UIImage getImgWithBundleImgName:@"recordingIcon"] forState:UIControlStateNormal];
        }
    }else{
        [self.photoView takePhoto];
        self.segm.hidden = YES;
        
    }
    
    
    
}
-(void)changeBtnClick:(UIButton *)btn{
    if(self.videoView){
        [self.videoView changeCaptureDevice];
    }else{
        [self.photoView changeCaptureDevice];
    }
    if(self.devicePosition == AVCaptureDevicePositionBack){
        self.devicePosition = AVCaptureDevicePositionFront;
    }else{
        self.devicePosition = AVCaptureDevicePositionBack;
    }
}

-(void)rePhotoBtnClick:(UIButton *)btn{
    if(self.photoView){
        [self.photoView start];
        self.tropBtn.hidden = NO;
        [self.rePhotoBtn removeFromSuperview];
        self.rePhotoBtn = nil;
        self.segm.hidden = NO;
    }
    
}







#pragma mark WQCameraForVideoViewDelegate
-(void)cameraForVideo:(WQCameraForVideoView *)videoView videoRecordingTime:(NSInteger)timeCount{
    self.timeLab.text = [self getTimeStrWithCount:timeCount];
}
-(void)cameraForVideoEndRecording:(WQCameraForVideoView *)videoView outputFileURL:(NSURL *)outputFileURL error:(NSError *)error{
    NSLog(@"录制结束");
    self.timeLab.text = [self getTimeStrWithCount:0];
    if(self.delegate && [self.delegate respondsToSelector:@selector(mediaFinish:mediaType:videoFileURL:photo:photoData:error:)]){
        [self.delegate mediaFinish:self mediaType:MediaTypeEnum_Video videoFileURL:outputFileURL photo:nil photoData:nil error:error];
    }
    
}

#pragma mark WQCameraForPhotoViewDelegate
-(void)cameraForPhoto:(WQCameraForPhotoView *)photoView takePhoto:(UIImage *)photo photoData:(NSData *)imageData error:(NSError * _Nullable)error{
    self.tropBtn.hidden = YES;
    self.rePhotoBtn.frame = self.tropBtn.frame;
    [self.view addSubview:self.rePhotoBtn];
    if(self.delegate && [self.delegate respondsToSelector:@selector(mediaFinish:mediaType:videoFileURL:photo:photoData:error:)]){
        [self.delegate mediaFinish:self mediaType:MediaTypeEnum_Photo videoFileURL:nil photo:photo photoData:imageData error:error];
    }
    
}

-(void)applicationWillResignActiveNoti:(NSNotification *)noti{
    if(self.videoView && [self.videoView recording]){
        [self cameraBtnClick:self.cameraBtn];
    }
}



-(UIView *)preview{
    if(!_preview){
        _preview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100 - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
        _preview.backgroundColor = [UIColor blackColor];
    }
    return _preview;
}
-(UIButton *)rePhotoBtn{
    if(!_rePhotoBtn){
        _rePhotoBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_rePhotoBtn setTitle:@"重拍" forState:UIControlStateNormal];
        _rePhotoBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_rePhotoBtn addTarget:self action:@selector(rePhotoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rePhotoBtn;
}

-(UILabel *)timeLab{
    if(!_timeLab){
        _timeLab = [[UILabel alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 100)/2, CGRectGetMaxY(self.preview.frame)-30, 100, 30)];
        _timeLab.textColor      = [UIColor whiteColor];
        _timeLab.textAlignment  = NSTextAlignmentCenter;
    }
    return _timeLab;
}
-(NSString *)getTimeStrWithCount:(NSInteger)count{
    NSString * timeStr =@"00:00";
    NSInteger ss = count % 60;
    NSInteger mm = count / 60 % 60;
    NSInteger hh = count / 60 / 60;
    timeStr = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hh,mm,ss];
    return timeStr;
}

-(void)dealloc{
    if(self.videoView && self.videoView.recording){
        [self.videoView stopRecord];
//        self.videoView.delegate = nil;
    }
}

@end
