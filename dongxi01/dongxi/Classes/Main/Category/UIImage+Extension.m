//
//  UIImage+Extension.m
//  dongxi
//
//  Created by 穆康 on 15/8/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "UIImage+Extension.h"
#import <SDImageCache.h>

@implementation UIImage (Extension)


+ (UIImage *)imageWithColor:(UIColor *)color {
    
    // 描述矩形
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)shadowImageWithColor:(UIColor *)color {
    
    // 描述矩形
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 0.5f);
    
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)placeholderImageWithImageNamed:(NSString *)name imageSize:(CGSize)size {
    
    NSString *key = [NSString stringWithFormat:@"%@%@", name, NSStringFromCGSize(size)];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    
    UIImage *image = [imageCache imageFromMemoryCacheForKey:key];
    if (image) {     // 缓存里有就从缓存取
        return image;
    } else {         // 缓存里没有就从磁盘取
        image = [imageCache imageFromDiskCacheForKey:key];
        if (image) {
            return image;
        } else {     // 磁盘里没有就创建再存储到缓存和磁盘
            
            UIImage *originalImage = [UIImage imageNamed:name];
            
            CGFloat originalImageW = originalImage.size.width;
            CGFloat originalImageH = originalImage.size.height;
            
            // 自定义的比例
            CGFloat scale = 0.8f;
            CGFloat targetImageW = size.width * scale;
            
            if (originalImageW > targetImageW) {
                originalImageH = originalImageH * (targetImageW / originalImageW);
                originalImageW = targetImageW;
            }
            
            if (originalImageH > size.height) {
                originalImageW = originalImageW * (size.height / originalImageH);
                originalImageH = size.height;
            }
            
            CGFloat originalImageX = (size.width - originalImageW) * 0.5f;
            CGFloat originalImageY = (size.height - originalImageH) * 0.5f;
            CGRect originalImageF = CGRectMake(originalImageX, originalImageY, originalImageW, originalImageH);
            
            UIGraphicsBeginImageContextWithOptions(size, NO, 0);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(ctx, DXRGBColor(222, 222, 222).CGColor);
            CGContextFillRect(ctx, CGRectMake(0.0f, 0.0f, size.width, size.height));
            [originalImage drawInRect:originalImageF];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // 存储到缓存和磁盘
            [imageCache storeImage:image forKey:key];
            
            return image;
        }
    }
}

@end
