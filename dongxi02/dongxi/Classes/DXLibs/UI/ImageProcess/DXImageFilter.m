//
//  DXImageFilter.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXImageFilter.h"
#import "DXImageKit.h"

@implementation DXImageFilter {
    CIContext * _context;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _context = [CIContext contextWithOptions:nil];
    }
    return self;
}

- (UIImage *)filterImage:(UIImage *)image {
    NSAssert(NO, @"必须通过继承改类并重写该方法来使用");
    
    return nil;
}

- (NSString *)filterName {
    NSAssert(NO, @"必须通过继承改类并重写该方法来使用");
    
    return nil;
}

- (CIContext *)sharedContext {
    static CIContext * context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [CIContext contextWithOptions:nil];
    });
    return context;
}

- (UIImage *)filterImage:(UIImage *)inputImage withBultinFilter:(NSString *)filterName andInputParams:(NSDictionary *)params {
    NSAssert(inputImage != nil, @"inputImage不能为nil");
    NSAssert(filterName != nil, @"filterName不能为nil");
    
    CIImage * inputCIImage = [CIImage imageWithCGImage:inputImage.CGImage];
    CIFilter * filter = [CIFilter filterWithName:filterName];
    [filter setValue:inputCIImage forKey:kCIInputImageKey];
    for (NSString * key in params) {
        id value = [params objectForKey:key];
        [filter setValue:value forKey:key];
    }
    CIImage * outputCIImage = [filter outputImage];
    UIImage * outputImage = nil;
    @autoreleasepool {
        CGImageRef outputImageRef = [_context createCGImage:outputCIImage fromRect:outputCIImage.extent];
        outputImage = [UIImage imageWithCGImage:outputImageRef];
        CGImageRelease(outputImageRef);
    }
    return outputImage;
}

@end
