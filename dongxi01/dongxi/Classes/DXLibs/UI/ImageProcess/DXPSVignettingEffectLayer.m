//
//  DXPSVignettingEffectLayer.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/26.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPSVignettingEffectLayer.h"

@implementation DXPSVignettingEffectLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        _intensity = 0;
    }
    return self;
}

- (NSString *)filterName {
    return @"CIVignetteEffect";
}

- (CIFilter *)filter {
    CIFilter * filter = [super filter];
    if (filter) {
        CGRect extent = self.inputImage.extent;
        CGFloat w = CGRectGetWidth(extent);
        CGFloat h = CGRectGetHeight(extent);
        
        CIVector * center = [CIVector vectorWithX:w*0.5 Y:h*0.5];
        [filter setValue:center forKey:kCIInputCenterKey];
        [filter setValue:@(self.intensity * 0.7) forKey:kCIInputIntensityKey];
        [filter setValue:@(w * 0.6) forKey:kCIInputRadiusKey];
    }
    return filter;
}

@end
