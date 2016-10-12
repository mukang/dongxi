//
//  DXPSLinearTiltShiftLayer.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPSLinearTiltShiftLayer.h"

@implementation DXPSLinearTiltShiftLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        _range = 0.5;
    }
    return self;
}

- (CIFilter *)filter {
    if (!self.disabled && self.inputImage) {
        CGFloat h = CGRectGetHeight(self.inputImage.extent);
        
        CIFilter * extendFilter = [CIFilter filterWithName:@"CIAffineClamp"];
        [extendFilter setValue:self.inputImage forKey:kCIInputImageKey];
        [extendFilter setValue:[NSValue valueWithCGAffineTransform:CGAffineTransformIdentity] forKey:@"inputTransform"];
        CIImage * extendedInputImage = extendFilter.outputImage;
        
        CGFloat blurRadius = 5;
        CIFilter * blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [blurFilter setValue:extendedInputImage forKey:kCIInputImageKey];
        [blurFilter setValue:@(blurRadius) forKey:kCIInputRadiusKey];
        CIImage * blurredImage = [blurFilter.outputImage imageByCroppingToRect:self.inputImage.extent];
        
        CIFilter * gradientFilter0 = [CIFilter filterWithName:@"CILinearGradient"];
        [gradientFilter0 setValue:[CIVector vectorWithX:0 Y:h * (1 - self.blurCenter.y + 0.4)] forKey:@"inputPoint0"];
        [gradientFilter0 setValue:[CIVector vectorWithX:0 Y:h * (1 - self.blurCenter.y + self.rangeScaleOfHeight)] forKey:@"inputPoint1"];
        [gradientFilter0 setValue:[CIColor colorWithRed:0 green:1 blue:0 alpha:1] forKey:@"inputColor0"];
        [gradientFilter0 setValue:[CIColor colorWithRed:0 green:1 blue:0 alpha:0] forKey:@"inputColor1"];
        CIImage * gradientImage0 = gradientFilter0.outputImage;

        CIFilter * gradientFilter1 = [CIFilter filterWithName:@"CILinearGradient"];
        [gradientFilter1 setValue:[CIVector vectorWithX:0 Y:h * (1 - self.blurCenter.y - 0.4)] forKey:@"inputPoint0"];
        [gradientFilter1 setValue:[CIVector vectorWithX:0 Y:h * (1 - self.blurCenter.y - self.rangeScaleOfHeight)] forKey:@"inputPoint1"];
        [gradientFilter1 setValue:[CIColor colorWithRed:0 green:1 blue:0 alpha:1] forKey:@"inputColor0"];
        [gradientFilter1 setValue:[CIColor colorWithRed:0 green:1 blue:0 alpha:0] forKey:@"inputColor1"];
        CIImage * gradientImage1 = gradientFilter1.outputImage;

        CIFilter * addFilter = [CIFilter filterWithName:@"CIAdditionCompositing"];
        [addFilter setValue:gradientImage0 forKey:kCIInputImageKey];
        [addFilter setValue:gradientImage1 forKey:kCIInputBackgroundImageKey];
        CIImage * maskImage = addFilter.outputImage;
        
        CIFilter * blendMaskFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
        [blendMaskFilter setValue:blurredImage forKey:kCIInputImageKey];
        [blendMaskFilter setValue:maskImage forKey:kCIInputMaskImageKey];
        [blendMaskFilter setValue:self.inputImage forKey:kCIInputBackgroundImageKey];
        
        return blendMaskFilter;
    } else {
        return nil;
    }
}

- (void)resetBlurInputs {
    self.blurCenter = CGPointMake(0, 0.5);
    self.range = 0.5;
}

- (void)setBlurCenter:(CGPoint)blurCenter {
    CGPoint center = blurCenter;
    center.x = 0;
    
    if (center.y < 0) {
        center.y = 0;
    } else if (center.y > 1) {
        center.y = 1;
    }
    
    _blurCenter = center;
}

- (CGFloat)rangeScaleOfHeight {
    return 0.3*self.range + 0.05;
}

@end
