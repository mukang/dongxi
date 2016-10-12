//
//  DXPSBrightnessLayer.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/26.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPSBrightnessLayer.h"

@implementation DXPSBrightnessLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        _brightness = 0;
    }
    return self;
}

- (NSString *)filterName {
    return @"CIColorControls";
}

- (CIFilter *)filter {
    CIFilter * filter = [super filter];
    if (filter) {
        [filter setValue:@(self.brightness * 0.2) forKey:kCIInputBrightnessKey];
    }
    return filter;
}

@end
