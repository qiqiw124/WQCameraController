//
//  WQCameraForVideoView.m
//  WQCameraController_Example
//
//  Created by 祺祺 on 2020/12/9.
//  Copyright © 2020 YUER. All rights reserved.
//

#import "WQCameraForVideoView.h"

@interface WQCameraForVideoView()<AVCaptureFileOutputRecordingDelegate>
{
    NSInteger _timeCount;
    int32_t   _frameRate;
}
@property(nonatomic,strong)AVCaptureSession      * captureSession;
@property(nonatomic,strong)AVCaptureDeviceInput  * videoDeviceInput;
@property(nonatomic,strong)AVCaptureMovieFileOutput * movieFileOutput;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer * preViewLayer;

@property(nonatomic,assign)BOOL isBackCameraSupported;
@property(nonatomic,assign)BOOL isTorchSupported;
@property(nonatomic,assign)BOOL isFrontCameraSupported;

@property(nonatomic,weak)NSTimer * recordTimer;



@end

@implementation WQCameraForVideoView
-(instancetype)initWithFrame:(CGRect)frame
       defaultDevicePosition:(AVCaptureDevicePosition)devicePostion
                   frameRate:(int32_t)frameRate{
    if(self = [super initWithFrame:frame]){
        _frameRate = frameRate;
        if(_frameRate == 0){
            _frameRate = 25;
        }
        [self initCapture:devicePostion];
    }
    return self;
}
-(void)initCapture:(AVCaptureDevicePosition)defaultPosition
{
    _timeCount = 0;
    self.captureSession = [[AVCaptureSession alloc]init];
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
        
        if ([backCamera hasTorch]) {
            self.isTorchSupported = YES;
        } else {
            self.isTorchSupported = NO;
        }
    }
    
    if (!frontCamera) {
        self.isFrontCameraSupported = NO;
    } else {
        self.isFrontCameraSupported = YES;
    }
    
    
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    [backCamera unlockForConfiguration];
    if(frontCamera.position == defaultPosition){
        self.videoDeviceInput =  [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:nil];
    }else{
        self.videoDeviceInput =  [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
    }
    
    AVCaptureDeviceInput *audioDeviceInput =[AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    
    [_captureSession addInput:_videoDeviceInput];
    [_captureSession addInput:audioDeviceInput];

    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [_captureSession addOutput:_movieFileOutput];
    
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    [self changeCaptureRate];

    self.preViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [_captureSession startRunning];
    self.preViewLayer.frame = self.bounds;
    [self.layer addSublayer:self.preViewLayer];
}
-(void)startRecord{
    [_movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self tmpPath]] recordingDelegate:self];
    
}
-(void)stopRecord{
    [_movieFileOutput stopRecording];

}
-(void)openTorch{
    AVCaptureDevice * device = self.videoDeviceInput.device;
    NSError * error;
    if(self.isTorchSupported && device.position == AVCaptureDevicePositionBack){
        if([device lockForConfiguration:&error]){
            device.torchMode = AVCaptureTorchModeOn;
            [device unlockForConfiguration];
        }else{
            NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
        }
        
    }
}
-(void)closeTorch{
    AVCaptureDevice * device = self.videoDeviceInput.device;
    NSError * error;
    if(self.isTorchSupported && device.position == AVCaptureDevicePositionBack){
        if([device lockForConfiguration:&error]){
            device.torchMode = AVCaptureTorchModeOff;
            [device unlockForConfiguration];
        }else{
            NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
        }
        
    }
}


- (void)changeCaptureDevice
{
    if([self recording]){
        return;
    }
    AVCaptureDevice *currentDevice=[self.videoDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront){
        toChangePosition=AVCaptureDevicePositionBack;
    }else{
        [self closeTorch];
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    [self.captureSession beginConfiguration];
    
    [self.captureSession removeInput:self.videoDeviceInput];
 
    if ([self.captureSession canAddInput:toChangeDeviceInput]){
        [self.captureSession addInput:toChangeDeviceInput];
        self.videoDeviceInput=toChangeDeviceInput;
    }
    [self changeCaptureRate];
    [self.captureSession commitConfiguration];
    
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
-(void)changeCaptureRate{
    AVCaptureDevice * currentDevice = self.videoDeviceInput.device;
    if ([currentDevice respondsToSelector:@selector(activeVideoMinFrameDuration)]) {
            [currentDevice lockForConfiguration:nil];
            currentDevice.activeVideoMinFrameDuration = CMTimeMake(1, _frameRate);
            currentDevice.activeVideoMaxFrameDuration = CMTimeMake(1, _frameRate);
            [currentDevice unlockForConfiguration];
   
        }else{
            AVCaptureConnection *conn = [[_captureSession.outputs lastObject] connectionWithMediaType:AVMediaTypeVideo];
            if (conn.supportsVideoMinFrameDuration)
                conn.videoMinFrameDuration = CMTimeMake(1,_frameRate);
            if (conn.supportsVideoMaxFrameDuration)
                conn.videoMaxFrameDuration = CMTimeMake(1,_frameRate);
   
        }
    
}


-(void)recordTimerEvent:(NSTimer *)timer{
    _timeCount ++;
    if(self.delegate && [self.delegate respondsToSelector:@selector(cameraForVideo:videoRecordingTime:)]){
        [self.delegate cameraForVideo:self videoRecordingTime:_timeCount];
    }
    
}

-(void)startTimer{
    if(self.recordTimer){
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordTimerEvent:) userInfo:nil repeats:YES];
}
-(void)endTimer{
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}




-(BOOL)recording{
    return _movieFileOutput.recording;
}
-(BOOL)backCameraSupported{
    return self.isBackCameraSupported;
}
-(BOOL)frontCameraSupported{
    return self.isFrontCameraSupported;
}
-(BOOL)torchSupported{
    if(self.videoDeviceInput.device.position == AVCaptureDevicePositionBack && self.isTorchSupported){
        return YES;
    }
    return NO;
}
-(BOOL)torchActiving{
    return self.videoDeviceInput.device.torchActive;
}

#pragma mark AVCaptureFileOutputRecordingDelegate
-(void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    [self startTimer];
}

-(void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    [self endTimer];
    _timeCount = 0;
    if(self.delegate && [self.delegate respondsToSelector:@selector(cameraForVideoEndRecording:outputFileURL:error:)]){
        if(error && [error.localizedDescription isEqualToString:@"Recording Stopped"]){
            [self.delegate cameraForVideoEndRecording:self outputFileURL:outputFileURL error:nil];
        }else{
            [self.delegate cameraForVideoEndRecording:self outputFileURL:outputFileURL error:error];
        }
        
    }
}










-(NSString *)tmpPath{
    return [NSTemporaryDirectory() stringByAppendingFormat:@"/cameraVideoTmp.mp4"];
}

-(void)dealloc{
    if([self recording]){
        [self stopRecord];
    }
    [self endTimer];
}
@end

