//
//  UIImage+Extension.h
//  dongxi
//
//  Created by 穆康 on 15/8/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

/**
 *  根据颜色生成一张尺寸为1*1的相同颜色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  根据颜色生成一张尺寸为1*0.5的相同颜色图片(用于阴影线)
 */
+ (UIImage *)shadowImageWithColor:(UIColor *)color;

/**
 *  生成一张占位图
 *
 *  @param name 名字
 *  @param size 生成的占位图尺寸
 *
 *  @return 占位图
 */
+ (UIImage *)placeholderImageWithImageNamed:(NSString *)name imageSize:(CGSize)size;

@end
