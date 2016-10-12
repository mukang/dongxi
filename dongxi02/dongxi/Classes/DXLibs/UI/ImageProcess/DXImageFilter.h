//
//  DXImageFilter.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DXImageFilter <NSObject>

@required

- (UIImage *)filterImage:(UIImage *)image;

- (NSString *)filterName;

@end


@interface DXImageFilter : NSObject <DXImageFilter>


/**
 *  使用系统内建滤镜对图片进行处理
 *
 *  @discussion 为了保证效率，返回的UIImage是不带CGImage属性的，无法直接用于文件保存，需单独做处理
 *
 *  @param inputImage 输入图像
 *  @param filterName 内建滤镜名称，请保证名称正确
 *  @param params     滤镜输入参数
 *
 *  @return 返回处理过后的图像
 */
- (UIImage *)filterImage:(UIImage *)inputImage withBultinFilter:(NSString *)filterName andInputParams:(NSDictionary *)params;


- (CIContext *)sharedContext;


@end



