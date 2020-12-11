//
//  WQCameraForPhotoView.m
//  WQCameraController_Example
//
//  Created by 祺祺 on 2020/12/9.
//  Copyright © 2020 YUER. All rights reserved.
//

#import "WQCameraForPhotoView.h"

@interface WQCameraForPhotoView()
@property(nonatomic,strong)AVCaptureSession * captureSession;
@property(nonatomic,strong)AVCaptureDeviceInput * captureDeviceInput;
@property(nonatomic,strong)AVCaptureStillImageOutput *captureStillImageOutput;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

@property(nonatomic,assign)BOOL isBackCameraSupported;
@property(nonatomic,assign)BOOL isFlashSupported;
@property(nonatomic,assign)BOOL isFrontCameraSupported;

@property(nonatomic,strong)UIView * focusView;
@end


@implementation WQCameraForPhotoView
-(instancetype)initWithFrame:(CGRect)frame defaultDevicePosition:(AVCaptureDevicePosition)devicePostion{
    if(self = [super initWithFrame:frame]){
        [self initCapture:devicePostion];
        [self addGenstureRecognizer];
    }
    return self;
}

-(void)initCapture:(AVCaptureDevicePosition)defaultPosition{
    //初始化会话
    _captureSession=[[AVCaptureSession alloc]init];
    [_captureSession startRunning];

    [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionFront) {
            frontCamera = camera;
        } else {
            backCamera = camera;
        }
    }
    
    if (!backCamera) {
        self.isBackCameraSupported = NO;
        return;
    } else {
        self.isBackCameraSupported = YES;
        
        if ([backCamera hasFlash]) {
            self.isFlashSupported = YES;
        } else {
            self.isFlashSupported = NO;
        }
    }
    
    if (!frontCamera) {
        self.isFrontCameraSupported = NO;
    } else {
        self.isFrontCameraSupported = YES;
    }
    
    NSError *error=nil;
    if(defaultPosition == AVCaptureDevicePositionFront){
        self.captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:frontCamera error:&error];
    }else{
        self.captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:backCamera error:&error];
    }
    _captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    
    [_captureStillImageOutput setOutputSettings:outputSettings];
    
    if ([_captureSession canAddInput:_captureDeviceInput]){
        [_captureSession addInput:_captureDeviceInput];
    }
    
    if ([_captureSession canAddOutput:_captureStillImageOutput]){
        [_captureSession addOutput:_captureStillImageOutput];
    }
    
    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    
    _captureVideoPreviewLayer.frame=self.layer.bounds;
    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:_captureVideoPreviewLayer];
    
    
    self.focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.focusView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.focusView.layer.borderWidth=2;
    self.focusView.layer.cornerRadius = 5;
    self.focusView.alpha=0;
    [self addSubview:self.focusView];
    
    
    

}
-(void)addGenstureRecognizer
{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self addGestureRecognizer:tapGesture];
}
-(void)changeCaptureDevice
{
    
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront){
        toChangePosition=AVCaptureDevicePositionBack;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    NSError *error;
    if([currentDevice lockForConfiguration:&error]){
        AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
        [self.captureSession beginConfiguration];
        
        [self.captureSession removeInput:self.captureDeviceInput];
     
        if ([self.captureSession canAddInput:toChangeDeviceInput]){
            [self.captureSession addInput:toChangeDeviceInput];
            self.captureDeviceInput=toChangeDeviceInput;
        }
        [self.captureSession commitConfiguration];
        [currentDevice unlockForConfiguration];
    }else{
        NSLog(@"%@",error.localizedDescription);
    }
   
    
}
-(void)openFlash{
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    NSError * error;
    if(currentPosition == AVCaptureDevicePositionBack && [currentDevice isFlashModeSupported:AVCaptureFlashModeOn]){
        if([currentDevice lockForConfiguration:&error]){
            [currentDevice setFlashMode:AVCaptureFlashModeOn];
            [currentDevice unlockForConfiguration];
        }else{
            NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
        }
        
    }
    
}

-(void)closeFlash{
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    NSError * error;
    if(currentPosition == AVCaptureDevicePositionBack && [currentDevice isFlashModeSupported:AVCaptureFlashModeOn]){
        if([currentDevice lockForConfiguration:&error]){
            [currentDevice setFlashMode:AVCaptureFlashModeOff];
            [currentDevice unlockForConfiguration];
        }else{
            NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
        }
        
    }
}
-(void)start{
    if (_captureSession){
        [_captureSession startRunning];

    }
}

-(void)stop{
    if (_captureSession){
        [_captureSession stopRunning];
        
    }
}

-(void)takePhoto{
    
    if(!_captureSession.running){
        return;
    }
    AVCaptureConnection *videoConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         if (imageDataSampleBuffer){
             [self stop];
             NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             UIImage *image=[UIImage imageWithData:imageData];
             if(self.delegate && [self.delegate respondsToSelector:@selector(cameraForPhoto:takePhoto:photoData:error:)]){
                 [self.delegate cameraForPhoto:self takePhoto:image photoData:imageData error:nil];
             }
             
         }else{
             if(self.delegate && [self.delegate respondsToSelector:@selector(cameraForPhoto:takePhoto:photoData:error:)]){
                 [self.delegate cameraForPhoto:self takePhoto:nil photoData:nil error:error];
             }
         }
     }];
}

-(BOOL)flashSupported{
    if(self.captureDeviceInput.device.position == AVCaptureDevicePositionBack && self.isFlashSupported){
        return YES;
    }
    return NO;
}

-(BOOL)flashActiving{
    return self.captureDeviceInput.device.flashActive;
}

-(BOOL)running{
    return _captureSession.running;
}

-(BOOL)backCameraSupported{
    return self.isBackCameraSupported;
}
-(BOOL)frontCameraSupported{
    return self.isFrontCameraSupported;
}

-(void)tapScreen:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point= [tapGesture locationInView:self];
    CGPoint cameraPoint= [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}


-(void)setFocusCursorWithPoint:(CGPoint)point
{
    self.focusView.center=point;
    self.focusView.transform=CGAffineTransformIdentity;
    self.focusView.alpha=1.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.focusView.transform=CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished)
     {
         self.focusView.alpha=0;
     }];
}
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point
{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
   
    if ([captureDevice lockForConfiguration:&error]){
        if ([captureDevice isFocusModeSupported:focusMode]){
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]){
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]){
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]){
            [captureDevice setExposurePointOfInterest:point];
        }
        [captureDevice unlockForConfiguration];
    }
    else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}
 
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position
{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras){
        if ([camera position]==position){
            return camera;
        }
    }
    return nil;
}



@end
