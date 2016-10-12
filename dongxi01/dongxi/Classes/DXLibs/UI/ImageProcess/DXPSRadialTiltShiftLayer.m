//
//  DXPSRadialTiltShiftLayer.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPSRadialTiltShiftLayer.h"

@implementation DXPSRadialTiltShiftLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        _range = 0.5;
        _blurCenter = CGPointMake(0.5, 0.5);
    }
    return self;
}

- (CIFilter *)filter {
    if (self.inputImage && !self.disabled) {
        CGFloat h = CGRectGetHeight(self.inputImage.extent);
        CGFloat w = CGRectGetWidth(self.inputImage.extent);
        
        CIFilter * extendFilter = [CIFilter filterWithName:@"CIAffineClamp"];
        [extendFilter setValue:self.inputImage forKey:kCIInputImageKey];
        [extendFilter setValue:[NSValue valueWithCGAffineTransform:CGAffineTransformIdentity] forKey:@"inputTransform"];
        CIImage * extendedInputImage = extendFilter.outputImage;
        
        CGFloat blurRadius = 5;
        CIFilter * blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [blurFilter setValue:extendedInputImage forKey:kCIInputImageKey];
        [blurFilter setValue:@(blurRadius) forKey:kCIInputRadiusKey];
        CIImage * blurredImage = [blurFilter.outputImage imageByCroppingToRect:self.inputImage.extent];
        
        CIFilter * gradientFilter = [CIFilter filterWithName:@"CIRadialGradient"];
        [gradientFilter setValue:[CIVector vectorWithX:w*self.blurCenter.x Y:h*(1-self.blurCenter.y)] forKey:@"inputCenter"];
        [gradientFilter setValue:@(MIN(w, h)*self.radius0ScaleOfMaxLength) forKey:@"inputRadius0"];
        [gradientFilter setValue:@(MIN(w, h)*0.5) forKey:@"inputRadius1"];
        [gradientFilter setValue:[CIColor colorWithRed:0 green:1 blue:0 alpha:0] forKey:@"inputColor0"];
        [gradientFilter setValue:[CIColor colorWithRed:0 green:1 blue:0 alpha:1] forKey:@"inputColor1"];
        CIImage * gradientImage = gradientFilter.outputImage;

        CIFilter * blendMaskFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
        [blendMaskFilter setValue:blurredImage forKey:kCIInputImageKey];
        [blendMaskFilter setValue:gradientImage forKey:kCIInputMaskImageKey];
        [blendMaskFilter setValue:self.inputImage forKey:kCIInputBackgroundImageKey];
        
        return blendMaskFilter;
    }
    return nil;
}

- (CGFloat)radius0ScaleOfMaxLength {
    return 0.05 + self.range * 0.4;
}

- (void)resetBlurInputs {
    self.blurCenter = CGPointMake(0.5, 0.5);
    self.range = 0.5;
}

@end
