//
//  DXPhotoShopLayer.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPhotoShopLayer.h"
#import <CoreImage/CoreImage.h>


@implementation DXPhotoShopLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        _disabled = NO;
        _tag = -1;
    }
    return self;
}

- (CIImage *)outputImage {
    CIFilter * filter = [self filter];
    if (filter && !self.disabled) {
        return filter.outputImage;
    } else {
        return self.inputImage;
    }
}

- (CIFilter *)filter {
    if (nil == self.filterName || nil == self.inputImage || self.disabled) {
        return nil;
    } else {
        CIFilter * filter = [CIFilter filterWithName:self.filterName keysAndValues:kCIInputImageKey, self.inputImage, nil];
        for (NSString * attributeKey in self.attributes) {
            id attributeValue = [self.attributes objectForKey:attributeKey];
            [filter setValue:attributeValue forKey:attributeKey];
        }
        return filter;
    }
}

- (void)setFilterName:(NSString *)filterName {
    if ([filterName isKindOfClass:[NSString class]]) {
        _filterName = filterName;
    } else {
        _filterName = nil;
    }
}


@end
