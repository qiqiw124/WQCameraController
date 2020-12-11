//
//  WQCameraForVideoView.h
//  WQCameraController_Example
//
//  Created by 祺祺 on 2020/12/9.
//  Copyright © 2020 YUER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

NS_ASSUME_NONNULL_BEGIN
@class WQCameraForVideoView;
@protocol WQCameraForVideoViewDelegate <NSObject>

-(void)cameraForVideo:(WQCameraForVideoView *)videoView videoRecordingTime:(NSInteger)timeCount;
-(void)cameraForVideoEndRecording:(WQCameraForVideoView *)videoView outputFileURL:(NSURL *)outputFileURL error:(NSError *)error;
@end

@interface WQCameraForVideoView : UIView
@property(nonatomic,weak)id<WQCameraForVideoViewDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame
       defaultDevicePosition:(AVCaptureDevicePosition)devicePostion
                   frameRate:(int32_t)frameRate;

-(void)startRecord;
-(void)stopRecord;
-(void)openTorch;
-(void)closeTorch;
//正在录制的情况下，无法切换
-(void)changeCaptureDevice;




-(BOOL)recording;
-(BOOL)backCameraSupported;
-(BOOL)frontCameraSupported;
-(BOOL)torchSupported;
-(BOOL)torchActiving;












@end

NS_ASSUME_NONNULL_END
