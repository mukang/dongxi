//
//  DXImageKit.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXImageKit.h"
#import <ImageIO/ImageIO.h>

@implementation DXImageKit

+ (UIImage *)imageFromImage:(UIImage *)image limitToMaxLength:(CGFloat)pixelLength {
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        return image;
    }
    
    CGSize imageSize = image.size;
    imageSize.width *= image.scale;
    imageSize.height *= image.scale;
    
    BOOL needFixImageOrientation = image.imageOrientation != UIImageOrientationUp;
    
    BOOL resizeUsingUIKit = NO;
    CGSize resizedImageSize = imageSize;
    
    if (imageSize.width > pixelLength || imageSize.height > pixelLength) {
        if (imageSize.width < pixelLength) {
            pixelLength = imageSize.width;
        } else if (imageSize.height < pixelLength) {
            pixelLength = imageSize.height;
        }
        CGFloat scale = MAX(pixelLength / imageSize.width, pixelLength / imageSize.height);
        
        @autoreleasepool {
            size_t imageWidth = CGImageGetWidth(imageRef) * scale;
            size_t imageHeight = CGImageGetHeight(imageRef) * scale;
            
            if (imageWidth >= imageHeight && imageSize.width >= imageSize.height) {
                resizedImageSize.width = imageWidth;
                resizedImageSize.height = imageHeight;
            } else {
                resizedImageSize.width = imageHeight;
                resizedImageSize.height = imageWidth;
            }
            
            size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
            size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
            CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(imageRef);
            CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
            
            CGContextRef bitmapContextRef = CGBitmapContextCreate(nil, imageWidth, imageHeight, bitsPerComponent, bytesPerRow, colorSpaceRef, bitmapInfo);
            if (bitmapContextRef) {
                CGContextSetInterpolationQuality(bitmapContextRef, kCGInterpolationHigh);
                CGContextDrawImage(bitmapContextRef, CGRectMake(0, 0, imageWidth, imageHeight), imageRef);
                CGImageRef scaledImageRef =  CGBitmapContextCreateImage(bitmapContextRef);
                
                image = [UIImage imageWithCGImage:scaledImageRef scale:image.scale orientation:image.imageOrientation];
                
                CGContextRelease(bitmapContextRef);
                CGImageRelease(scaledImageRef);
            } else {
                UIGraphicsBeginImageContextWithOptions(resizedImageSize, YES, 1);
                [image drawInRect:CGRectMake(0, 0, resizedImageSize.width, resizedImageSize.height)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                resizeUsingUIKit = YES;
            }
        }
    }

    @autoreleasepool {
        if (!resizeUsingUIKit && needFixImageOrientation) {
            UIGraphicsBeginImageContextWithOptions(resizedImageSize, YES, 1);
            [image drawInRect:CGRectMake(0, 0, resizedImageSize.width, resizedImageSize.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    return image;
}

+ (UIImage *)getThumbnailForPhoto:(NSURL *)photoURL andSize:(CGSize)size {
    UIImage * photo = [UIImage imageWithContentsOfFile:photoURL.path];
    return [self getThumbnailForImage:photo andSize:size];
}

+ (UIImage *)getThumbnailForImage:(UIImage *)image andSize:(CGSize)size {
    UIImage * thumbnail = nil;
    @autoreleasepool {
        NSData * imageData = UIImageJPEGRepresentation(image, 0.6);
        CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, nil);
        if (imageSourceRef) {
            CGFloat scale = [[UIScreen mainScreen] scale];
            CFDictionaryRef options = CFBridgingRetain(@{
                                                         (__bridge NSString *)kCGImageSourceThumbnailMaxPixelSize : @(MAX(size.width * scale, size.height * scale)),
                                                         (__bridge NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent : @(YES)
                                                         });
            CGImageRef thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSourceRef, 0, options);
            thumbnail = [UIImage imageWithCGImage:thumbnailRef scale:scale orientation:image.imageOrientation];
            CGImageRelease(thumbnailRef);
            CFRelease(options);
            CFRelease(imageSourceRef);
        }
    }
    return thumbnail;
}

+ (UIImage *)getImageFromCIImage:(CIImage *)image {
    UIImage * outputImage = nil;
    @autoreleasepool {
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef outputImageRef = [context createCGImage:image fromRect:image.extent];
        outputImage = [UIImage imageWithCGImage:outputImageRef];
        CGImageRelease(outputImageRef);
    }
    return outputImage;
}

+ (UIImage *)transformedImageFromImage:(UIImage *)image transform:(CGAffineTransform)transform {
    CGFloat scaleX = sqrtf(transform.a * transform.a + transform.c * transform.c);
    CGFloat scaleY = sqrtf(transform.b * transform.b + transform.d * transform.d);
    CGFloat rotation = atan2f(transform.b, transform.a);
    
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    CGRect imageFrame = CGRectApplyAffineTransform(bounds, transform);

    UIImage * tranformedImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, image.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, imageFrame.size.width*0.5, imageFrame.size.height*0.5);
        CGContextRotateCTM(context, rotation);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, CGRectMake(-image.size.width*0.5*scaleX, -image.size.height*0.5*scaleY, image.size.width*scaleX, image.size.height*scaleY), image.CGImage);
        tranformedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return tranformedImage;
}

+ (UIImage *)drawWatermark:(UIImage *)watermarkImage withFrame:(CGRect)frame onImage:(UIImage *)image {
    UIImage * completedImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawAtPoint:CGPointZero];
        [watermarkImage drawInRect:frame];
        completedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return completedImage;
}

+ (CGImageRef)newScaledImageFromImage:(CGImageRef)imageRef scale:(CGFloat)scale {
    if (!imageRef) {
        return NULL;
    }
    
    scale = scale / [UIScreen mainScreen].scale;
    
    CGSize newSize = CGSizeMake(roundf(CGImageGetWidth(imageRef) * scale), roundf(CGImageGetHeight(imageRef) * scale));
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置缩放质量
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    // 垂直翻转
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    CGContextConcatCTM(context, flipVertical);
    // 将原图绘制到缩放后的context上
    CGContextDrawImage(context, CGRectMake(0, 0, newSize.width, newSize.height), imageRef);
    // 获取绘制后的图像
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    return scaledImageRef;
}

+ (CGImageRef)newUnrotatedImageFromImage:(CGImageRef)imageRef withOrientation:(UIImageOrientation)orientation {
    CGFloat scale = 1 / [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(roundf(CGImageGetWidth(imageRef) * scale), roundf(CGImageGetHeight(imageRef) * scale));
    CGSize contexSize = imageSize;
    CGAffineTransform transform;
    CGFloat tempHeight = 0;
    switch(orientation) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            tempHeight = contexSize.height;
            contexSize.height = contexSize.width;
            contexSize.width = tempHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            tempHeight = contexSize.height;
            contexSize.height = contexSize.width;
            contexSize.width = tempHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            tempHeight = contexSize.height;
            contexSize.height = contexSize.width;
            contexSize.width = tempHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            tempHeight = contexSize.height;
            contexSize.height = contexSize.width;
            contexSize.width = tempHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContextWithOptions(contexSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -1, 1);
        CGContextTranslateCTM(context, -imageSize.height, 0);
    } else {
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -imageSize.height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), imageRef);
    CGImageRef unrotatedImageRef = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    return unrotatedImageRef;
}

@end
