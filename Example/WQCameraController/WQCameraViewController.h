//
//  WQCameraViewController.h
//  WQCameraController_Example
//
//  Created by 祺祺 on 2020/12/9.
//  Copyright © 2020 YUER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,MediaTypeEnum){
    MediaTypeEnum_Photo = 0,
    MediaTypeEnum_Video = 1,
};


@class WQCameraViewController;
@protocol WQCameraViewControllerDelegate <NSObject>

/**
 视频或者照片拍摄完毕
 @param cameraView 拍照页面
 @param mediaType 拍照类型 视频还是拍照
 @param videoFileUrl 视频情况下会有
 @param photo 照片 拍照情况下会有
 @param imageData 照片的data 拍照情况下会有
 @param error error
 */
-(void)mediaFinish:(WQCameraViewController *)cameraView
         mediaType:(MediaTypeEnum)mediaType
      videoFileURL:(NSURL * __nullable)videoFileUrl
             photo:(UIImage * __nullable)photo
         photoData:(NSData * __nullable)imageData
             error:(NSError * __nullable)error;
@end



@interface WQCameraViewController : UIViewController
@property(nonatomic,weak)id<WQCameraViewControllerDelegate>delegate;
//视频录制帧率 默认25
@property(nonatomic,assign)int32_t frameRate;
@property(nonatomic,assign)BOOL showPresentBackBtn;
@end


NS_ASSUME_NONNULL_END
