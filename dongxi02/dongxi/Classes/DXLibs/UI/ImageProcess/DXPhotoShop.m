//
//  DXPhotoFilter.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <GLKit/GLKit.h>

#import "DXPhotoShop.h"
#import "DXImageKit.h"
#import "DXPSBrightnessLayer.h"
#import "DXPSTemperatureLayer.h"
#import "DXPSVignettingEffectLayer.h"
#import "DXPSRadialTiltShiftLayer.h"
#import "DXPSLinearTiltShiftLayer.h"
#import "DXRadialTiltShiftIndicatorView.h"
#import "DXLinearTiltShiftIndicatorView.h"

@interface DXPhotoShop()<GLKViewDelegate>

@property (nonatomic, strong) EAGLContext * glContext;
@property (nonatomic, strong) CIContext * ciContext;

@property (nonatomic, strong) CIImage * inputCIImage;
@property (nonatomic, strong) NSMutableArray * psLayers;

@property (nonatomic, readonly) NSArray * effectFilterNames;

@property (nonatomic, strong) DXPSBrightnessLayer * brightnessLayer;
@property (nonatomic, strong) DXPSTemperatureLayer * temperatureLayer;
@property (nonatomic, strong) DXPSVignettingEffectLayer * vignettingEffectLayer;
@property (nonatomic, strong) DXPSLinearTiltShiftLayer * linearTiltShiftLayer;
@property (nonatomic, strong) DXPSRadialTiltShiftLayer * radialTiltShiftLayer;
@property (nonatomic, strong) DXPhotoShopLayer * photoEffectLayer;

@property (nonatomic, assign) BOOL showLinearTiltShiftIndicators;
@property (nonatomic, assign) BOOL showRadialTiltShiftIndicators;

@property (nonatomic, strong) DXRadialTiltShiftIndicatorView * radialTiltShiftIndicatorView;
@property (nonatomic, strong) DXLinearTiltShiftIndicatorView * linearTiltShiftIndicatorView;


- (void)setupPSLayers;
- (NSArray *)generateEffectPreviews;
- (void)refreshPreviewView;
- (void)resetTiltShiftMode;

@end


#define kDXPhotoShopTiltShiftDefaultRange 0.5f

@implementation DXPhotoShop {
    UIImage * _inputThumbnail;
    BOOL _inputThumbnailNeedsUpdate;
    NSArray * _effectFilterNames;
    NSArray * _effectDisplayNames;
    NSArray * _effectPreviews;
    
    CGFloat _lastBrightness;
    CGFloat _lastTemperature;
    CGFloat _lastVignettingEffect;
    DXPhotoShopTiltShiftMode _lastTiltShiftMode;
    CGFloat _lastTiltShiftRange;
    CGPoint _lastTiltShiftCenter;
    
    GLKView * _previewView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _selectedEffectIndex = 0;
        _effectPreviewSize = CGSizeMake(150, 150);
        
        
        [self setupSubviews];
        [self setupPSLayers];
    }
    return self;
}

- (NSMutableArray *)psLayers {
    if (nil == _psLayers) {
        _psLayers = [NSMutableArray array];
    }
    return _psLayers;
}

#pragma mark -

- (NSArray *)effectFilterNames {
    if (nil == _effectFilterNames) {
        _effectFilterNames = @[
                               [NSNull null],
                               @"CIPhotoEffectProcess",
                               @"CIPhotoEffectFade",
                               @"CIPhotoEffectInstant",
                               @"CIPhotoEffectTransfer",
                               @"CIPhotoEffectChrome",
                               @"CIPhotoEffectMono",
                               @"CIPhotoEffectTonal",
                               @"CIPhotoEffectNoir"
                               ];
    }
    return _effectFilterNames;
}

- (NSArray *)effectDisplayNames {
    if (nil == _effectDisplayNames) {
        _effectDisplayNames = @[
                                @"原图",
                                @"冲印",
                                @"褪色",
                                @"怀旧",
                                @"岁月",
                                @"铬黄",
                                @"单色",
                                @"色调",
                                @"黑白"
                                ];
    }
    return _effectDisplayNames;
}

- (NSArray *)effectPreviews {
    return [self generateEffectPreviews];
}

- (UIImage *)outputImage {
    if (self.psLayers.count == 0) {
        return self.inputImage;
    } else {
        UIImage * outputImage = nil;
        
        @autoreleasepool {
            CIImage * image = [self outputCIImage];
            CGImageRef outputImageRef = [self.ciContext createCGImage:image fromRect:image.extent];
            outputImage = [UIImage imageWithCGImage:outputImageRef scale:self.inputImage.scale orientation:self.inputImage.imageOrientation];
            CGImageRelease(outputImageRef);
        }

        return outputImage;
    }
}

- (CIImage *)outputCIImage {
    CIImage * image = [self inputCIImage];
    
    for (DXPhotoShopLayer * psLayer in self.psLayers) {
        psLayer.inputImage = image;
        image = psLayer.outputImage;
    }
    return image;
}

- (void)setNeedsUpdateEffectPreviews {
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectPreviewNeedsRefreshInPhotoshop:)]) {
        [self.delegate effectPreviewNeedsRefreshInPhotoshop:self];
    }
}

- (void)saveState {
    _lastBrightness = self.brightness;
    _lastTemperature = self.temperature;
    _lastVignettingEffect = self.vignettingEffect;
    _lastTiltShiftMode = self.tiltShiftMode;
    _lastTiltShiftRange = self.tiltShiftRange;
    _lastTiltShiftCenter = self.tiltShiftCenter;

    [self setNeedsUpdateEffectPreviews];
}

- (void)restoreState {
    self.brightness = _lastBrightness;
    self.temperature = _lastTemperature;
    self.vignettingEffect = _lastVignettingEffect;
    self.tiltShiftMode = _lastTiltShiftMode;
    self.tiltShiftRange = _lastTiltShiftRange;
    self.tiltShiftCenter = _lastTiltShiftCenter;
}

- (void)releaseResources {
    _previewView = nil;
}

- (void)displayPreview {
    [self refreshPreviewView];
}


#pragma mark -

- (void)setInputImage:(UIImage *)inputImage {
    _inputImage = inputImage;
    self.inputCIImage = [CIImage imageWithCGImage:inputImage.CGImage];
}

- (void)setSelectedEffectIndex:(NSInteger)selectedEffectIndex {
    _selectedEffectIndex = selectedEffectIndex;
    
    if (selectedEffectIndex < 0 || selectedEffectIndex >= self.effectFilterNames.count) {
        self.photoEffectLayer.filterName = nil;
    } else {
        self.photoEffectLayer.filterName = [self.effectFilterNames objectAtIndex:selectedEffectIndex];
    }
    
    [self refreshPreviewView];
}

- (void)setBrightness:(CGFloat)brightness {
    brightness = round(brightness * 100)/100;
    if (ABS(_brightness - brightness) < FLT_EPSILON) {
        return;
    }

    _brightness = brightness;
    
    self.brightnessLayer.brightness = brightness;
    [self refreshPreviewView];
}

- (void)setTemperature:(CGFloat)temperature {
    temperature = round(temperature * 100)/100;
    if (ABS(_temperature-temperature) < FLT_EPSILON) {
        return;
    }
    
    _temperature = temperature;
    
    self.temperatureLayer.warmth = temperature;
    [self refreshPreviewView];
}

- (void)setVignettingEffect:(CGFloat)vignettingEffect {
    vignettingEffect = round(vignettingEffect * 100)/100;
    if (ABS(_vignettingEffect-vignettingEffect) < FLT_EPSILON) {
        return;
    }
    
    _vignettingEffect = vignettingEffect;
    
    self.vignettingEffectLayer.intensity = vignettingEffect;
    [self refreshPreviewView];
}

- (void)setTiltShiftMode:(DXPhotoShopTiltShiftMode)tiltShiftMode {
    if (tiltShiftMode != _tiltShiftMode) {
        _tiltShiftMode = tiltShiftMode;
        [self resetTiltShiftMode];
    }
}

- (void)setTiltShiftRange:(CGFloat)tiltShiftRange {
    tiltShiftRange = round(tiltShiftRange * 100)/100;
    if (ABS(_tiltShiftRange-tiltShiftRange) < FLT_EPSILON) {
        return;
    }
    
    _tiltShiftRange = tiltShiftRange;
    if (self.tiltShiftMode == DXPhotoShopTiltShiftRadial) {
        self.radialTiltShiftLayer.range = tiltShiftRange;
        [self updateRadialTiltShiftIndicators];
    } else if (self.tiltShiftMode == DXPhotoShopTiltShiftLinear) {
        self.linearTiltShiftLayer.range = tiltShiftRange;
        [self updateLinearTiltShiftIndicators];
    }

    [self refreshPreviewView];
}

- (void)setTiltShiftCenter:(CGPoint)tiltShiftCenter {
    CGPoint center = tiltShiftCenter;
    if (self.tiltShiftMode == DXPhotoShopTiltShiftLinear) {
        center.x = 0;
    } else {
        if (center.x < 0) {
            center.x = 0;
        } else if (center.x > 1) {
            center.x = 1;
        }
    }
    
    if (center.y < 0) {
        center.y = 0;
    } else if (center.y > 1) {
        center.y = 1;
    }
    
    if (CGPointEqualToPoint(_tiltShiftCenter, center)) {
        return;
    }
    
    _tiltShiftCenter = center;

    if (self.tiltShiftMode == DXPhotoShopTiltShiftRadial) {
        self.radialTiltShiftLayer.blurCenter = center;
        [self updateRadialTiltShiftIndicators];
    } else if (self.tiltShiftMode == DXPhotoShopTiltShiftLinear) {
        self.linearTiltShiftLayer.blurCenter = center;
        [self updateLinearTiltShiftIndicators];
    }
    [self refreshPreviewView];
}


- (void)setShowTiltIndicator:(BOOL)showTiltIndicator {
    _showTiltIndicator = showTiltIndicator;

    if (self.tiltShiftMode == DXPhotoShopTiltShiftRadial) {
        [self setShowRadialTiltShiftIndicators:showTiltIndicator];
        [self setShowLinearTiltShiftIndicators:NO];
    } else if (self.tiltShiftMode == DXPhotoShopTiltShiftLinear) {
        [self setShowLinearTiltShiftIndicators:showTiltIndicator];
        [self setShowRadialTiltShiftIndicators:NO];
    } else {
        _showTiltIndicator = NO;
        [self setShowLinearTiltShiftIndicators:NO];
        [self setShowRadialTiltShiftIndicators:NO];
    }
}

- (EAGLContext *)glContext {
    if (_glContext == nil) {
        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return _glContext;
}

- (CIContext *)ciContext {
    if (_ciContext == nil) {
        _ciContext = [CIContext contextWithEAGLContext:self.glContext
                                               options:@{kCIContextWorkingColorSpace: [NSNull null]}];
    }
    return _ciContext;
}

#pragma mark -

- (void)setupSubviews {
    _previewView = [[GLKView alloc] initWithFrame:CGRectZero context:self.glContext];
    _previewView.enableSetNeedsDisplay = YES;
    _previewView.delegate = self;
    _previewView.opaque = NO;
    _previewView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    _radialTiltShiftIndicatorView = [[DXRadialTiltShiftIndicatorView alloc] initWithFrame:CGRectZero];
    _radialTiltShiftIndicatorView.hidden = YES;
    _radialTiltShiftIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [_previewView addSubview:_radialTiltShiftIndicatorView];
    
    [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_radialTiltShiftIndicatorView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_previewView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0]];
    [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_radialTiltShiftIndicatorView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_previewView
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.0
                                                              constant:0]];
    [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_radialTiltShiftIndicatorView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_previewView
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0]];
    [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_radialTiltShiftIndicatorView
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_previewView
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.0
                                                              constant:0]];
    
    
    _linearTiltShiftIndicatorView = [[DXLinearTiltShiftIndicatorView alloc] initWithFrame:CGRectZero];
    _linearTiltShiftIndicatorView.hidden = YES;
    _linearTiltShiftIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [_previewView addSubview:_linearTiltShiftIndicatorView];
    
    [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_linearTiltShiftIndicatorView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_previewView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0]];
    [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_linearTiltShiftIndicatorView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_previewView
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.0
                                                              constant:0]];
    [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_linearTiltShiftIndicatorView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_previewView
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0]];
    [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_linearTiltShiftIndicatorView
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_previewView
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.0
                                                              constant:0]];
}

- (void)setupPSLayers {
    self.temperatureLayer = [[DXPSTemperatureLayer alloc] init];
    self.brightnessLayer = [[DXPSBrightnessLayer alloc] init];
    self.vignettingEffectLayer = [[DXPSVignettingEffectLayer alloc] init];
    self.photoEffectLayer = [[DXPhotoShopLayer alloc] init];
    self.linearTiltShiftLayer = [[DXPSLinearTiltShiftLayer alloc] init];
    self.radialTiltShiftLayer = [[DXPSRadialTiltShiftLayer alloc] init];
    
    _lastBrightness = self.brightnessLayer.brightness;
    _lastTemperature = self.temperatureLayer.warmth;
    _lastVignettingEffect = self.vignettingEffectLayer.intensity;
    
    self.linearTiltShiftLayer.disabled = YES;
    self.radialTiltShiftLayer.disabled = YES;
    _lastTiltShiftMode = DXPhotoShopTiltShiftNone;
    
    [self.psLayers addObject:self.temperatureLayer];
    [self.psLayers addObject:self.brightnessLayer];
    [self.psLayers addObject:self.vignettingEffectLayer];
    [self.psLayers addObject:self.photoEffectLayer];
    [self.psLayers addObject:self.linearTiltShiftLayer];
    [self.psLayers addObject:self.radialTiltShiftLayer];
}

- (NSArray *)generateEffectPreviews {
//    if (_inputThumbnailNeedsUpdate || _inputThumbnail == nil) {
//        _inputThumbnail = [DXImageKit getThumbnailForImage:self.inputImage andSize:self.effectPreviewSize];
//        _inputThumbnailNeedsUpdate = NO;
//    }
//    
//    NSMutableArray * previewPhotos = [NSMutableArray array];
//    
//    NSString * currentFilter = self.photoEffectLayer.filterName;
//    UIImage * currentImage = self.inputImage;
//    
//    _inputImage = _inputThumbnail;
//    
//    int i = 0;
//    for (NSString * filterName in self.effectFilterNames) {
//        self.photoEffectLayer.filterName = filterName;
//        UIImage * image = [self outputImage];
//        [previewPhotos addObject:image];
//        i++;
//    }
//    
//    _inputImage = currentImage;
//    self.photoEffectLayer.filterName = currentFilter;
//    
//    return previewPhotos;
    return [NSArray array];
}

- (void)setShowRadialTiltShiftIndicators:(BOOL)showRadialTiltShiftIndicators {
    _showRadialTiltShiftIndicators = showRadialTiltShiftIndicators;
    self.radialTiltShiftIndicatorView.hidden = !showRadialTiltShiftIndicators;
}

- (void)setShowLinearTiltShiftIndicators:(BOOL)showLinearTiltShiftIndicators {
    _showLinearTiltShiftIndicators = showLinearTiltShiftIndicators;
    self.linearTiltShiftIndicatorView.hidden = !showLinearTiltShiftIndicators;
}

- (void)updateRadialTiltShiftIndicators {
    self.radialTiltShiftIndicatorView.radius = self.radialTiltShiftLayer.radius0ScaleOfMaxLength;
    self.radialTiltShiftIndicatorView.cirlceCenter = self.radialTiltShiftLayer.blurCenter;
}

- (void)updateLinearTiltShiftIndicators {
    self.linearTiltShiftIndicatorView.distance = self.linearTiltShiftLayer.rangeScaleOfHeight;
    self.linearTiltShiftIndicatorView.middleLineY = self.linearTiltShiftLayer.blurCenter.y;
}

#pragma mark -

- (void)refreshPreviewView {
    [self.previewView setNeedsDisplay];
}

- (void)resetTiltShiftMode {
    switch (self.tiltShiftMode) {
        case DXPhotoShopTiltShiftLinear:
            self.linearTiltShiftLayer.disabled = NO;
            self.radialTiltShiftLayer.disabled = YES;
    
            [self.linearTiltShiftLayer resetBlurInputs];
            _tiltShiftCenter = self.linearTiltShiftLayer.blurCenter;
            _tiltShiftRange = self.linearTiltShiftLayer.range;
            [self updateLinearTiltShiftIndicators];
            break;
        case DXPhotoShopTiltShiftRadial:
            self.linearTiltShiftLayer.disabled = YES;
            self.radialTiltShiftLayer.disabled = NO;
            [self.radialTiltShiftLayer resetBlurInputs];

            _tiltShiftCenter = self.radialTiltShiftLayer.blurCenter;
            _tiltShiftRange = self.radialTiltShiftLayer.range;
            [self updateRadialTiltShiftIndicators];
            break;
        default:
            self.linearTiltShiftLayer.disabled = YES;
            self.radialTiltShiftLayer.disabled = YES;
            break;
    }

    [self refreshPreviewView];
}

#pragma mark -

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    CGFloat red, green, blue, alpha;
    [view.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    glClearColor(red, green, blue, alpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glFlush();

    CIImage * image = [self outputCIImage];
    CGFloat imageAspectRatio = image.extent.size.width / image.extent.size.height;
    CGFloat viewAspectRatio = view.drawableWidth / view.drawableHeight;
    
    CGPoint drawOrigin = CGPointZero;
    CGSize drawSize = CGSizeMake(view.drawableWidth, view.drawableHeight);
    
    // 图像的宽高比 > 视图的宽高比，上下需要留白
    if (imageAspectRatio > viewAspectRatio) {
        drawSize.height = view.drawableWidth / imageAspectRatio;
        drawOrigin.y = (view.drawableHeight - drawSize.height) / 2;
    }
    
    // 图像的宽高比 < 视图的宽高比，左右需要留白
    if (imageAspectRatio < viewAspectRatio) {
        drawSize.width = view.drawableWidth * imageAspectRatio;
        drawOrigin.x = (view.drawableWidth - drawSize.width) / 2;
    }
    
    
    [self.ciContext drawImage:image
                       inRect:CGRectMake(drawOrigin.x, drawOrigin.y, drawSize.width, drawSize.height)
                     fromRect:image.extent];
}


@end