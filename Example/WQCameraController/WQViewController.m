//
//  WQViewController.m
//  WQCameraController
//
//  Created by YUER on 12/11/2020.
//  Copyright (c) 2020 YUER. All rights reserved.
//

#import "WQViewController.h"
#import "WQCameraViewController.h"
@interface WQViewController ()<WQCameraViewControllerDelegate>

@end

@implementation WQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
    [btn setTitle:@"相机" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
-(void)showCamera{
    WQCameraViewController * controller = [[WQCameraViewController alloc]init];
    controller.delegate = self;
//    [self.navigationController pushViewController:controller animated:YES];
    controller.showPresentBackBtn = YES;
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}
-(void)mediaFinish:(WQCameraViewController *)cameraView mediaType:(MediaTypeEnum)mediaType videoFileURL:(NSURL *)videoFileUrl photo:(UIImage *)photo photoData:(NSData *)imageData error:(NSError *)error{
    if(mediaType == MediaTypeEnum_Video && !error){
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoFileUrl];
        } completionHandler:^(BOOL success, NSError * _Nullable errora) {
            if(success){
                NSLog(@"保存成功");
            }else{
                NSLog(@"%@",errora.localizedDescription);
            }
        }];
    }else if(mediaType == MediaTypeEnum_Photo && !error){
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:photo];
        } completionHandler:^(BOOL success, NSError * _Nullable errora) {
            if(success){
                NSLog(@"保存成功");
            }else{
                NSLog(@"%@",errora.localizedDescription);
            }
        }];
    }else if(error){
        NSLog(@"%@",error.localizedDescription);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
