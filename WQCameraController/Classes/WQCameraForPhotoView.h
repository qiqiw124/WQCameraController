//
//  WQCameraForPhotoView.h
//  WQCameraController_Example
//
//  Created by 祺祺 on 2020/12/9.
//  Copyright © 2020 YUER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@class WQCameraForPhotoView;
@protocol WQCameraForPhotoViewDelegate <NSObject>
-(void)cameraForPhoto:(WQCameraForPhotoView *)photoView
            takePhoto:(UIImage *__nullable)photo
            photoData:(NSData *__nullable)imageData
                error:(NSError * __nullable)error;

@end



@interface WQCameraForPhotoView : UIView
@property(nonatomic,weak)id<WQCameraForPhotoViewDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame
       defaultDevicePosition:(AVCaptureDevicePosition)devicePostion;

-(void)changeCaptureDevice;
-(void)openFlash;
-(void)closeFlash;

-(void)start;
-(void)stop;

-(void)takePhoto;


-(BOOL)flashActiving;
-(BOOL)flashSupported;
-(BOOL)running;
-(BOOL)backCameraSupported;
-(BOOL)frontCameraSupported;
@end

NS_ASSUME_NONNULL_END
