//
//  DXImageKit.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXImageKit : NSObject

+ (UIImage *)getThumbnailForPhoto:(NSURL *)photoURL andSize:(CGSize)size;
+ (UIImage *)getThumbnailForImage:(UIImage *)image andSize:(CGSize)size;

+ (UIImage *)getImageFromCIImage:(CIImage *)image;

+ (UIImage *)transformedImageFromImage:(UIImage *)image transform:(CGAffineTransform)transform;

+ (UIImage *)drawWatermark:(UIImage *)watermarkImage withFrame:(CGRect)frame onImage:(UIImage *)image;

/**
 *  根据一幅图像创建一幅进行了缩放的图像
 *
 *  @param imageRef 原图像
 *  @param scale    缩放比例
 *
 *  @return 返回新创建的进行了缩放的图像。**重要**你需要负责对已经创建的图像进行CGImageRelease。
 */
+ (CGImageRef)newScaledImageFromImage:(CGImageRef)imageRef scale:(CGFloat)scale;

/**
 *  根据一幅图像创建一幅进行了移除了旋转的图像
 *
 *  @param imageRef    原图像
 *  @param orientation 原图像的旋转方向
 *
 *  @return 返回新创建的图像。**重要**你需要负责对已经创建的图像进行CGImageRelease。
 */
+ (CGImageRef)newUnrotatedImageFromImage:(CGImageRef)imageRef withOrientation:(UIImageOrientation)orientation;

@end
