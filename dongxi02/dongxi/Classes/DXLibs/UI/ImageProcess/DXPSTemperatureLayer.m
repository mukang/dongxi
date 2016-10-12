//
//  DXPSTemperatureLayer.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/26.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPSTemperatureLayer.h"

@implementation DXPSTemperatureLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        _warmth = 0;
    }
    return self;
}

- (NSString *)filterName {
    return @"CITemperatureAndTint";
}

- (CIFilter *)filter {
    CIFilter * filter = [super filter];
    if (filter) {
        CGFloat range;
        if (self.warmth >= 0) {
            range = 3000;
        } else {
            range = 8000;
        }
        CIVector *inputNeutral = [CIVector vectorWithX:6500 Y:0];
        CIVector *inputTargetNeutral = [CIVector vectorWithX:6500-self.warmth*range Y:0];
        [filter setValue:inputNeutral forKey:@"inputNeutral"];
        [filter setValue:inputTargetNeutral forKey:@"inputTargetNeutral"];
    }
    return filter;
}

@end
