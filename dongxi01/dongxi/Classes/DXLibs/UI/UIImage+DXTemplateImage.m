//
//  UIImage+DXTemplateImage.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "UIImage+DXTemplateImage.h"

@implementation UIImage (DXTemplateImage)

+ (UIImage *)templateImageNamed:(NSString *)name {
    UIImage * image = [self imageNamed:name];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
