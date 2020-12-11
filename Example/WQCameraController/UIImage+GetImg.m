//
//  UIImage+GetImg.m
//  TestDemo
//
//  Created by 祺祺 on 2020/7/6.
//  Copyright © 2020 祺祺. All rights reserved.
//

#import "UIImage+GetImg.h"

@implementation UIImage (GetImg)
+(UIImage *)getImgWithBundleImgName:(NSString *)imgName{
    NSBundle * bundle = [NSBundle bundleForClass:NSClassFromString(@"WQCameraViewController")];
    NSInteger scale = [UIScreen mainScreen].scale;
    NSString * imgN = [NSString stringWithFormat:@"%@@%ldx",imgName,(long)scale];
    NSString * path = [bundle pathForResource:imgN ofType:@"png"];
    if(!path.length){
        path = [bundle pathForResource:imgName ofType:@"png"];
    }
    return [UIImage imageWithContentsOfFile:path];
    
}
@end
