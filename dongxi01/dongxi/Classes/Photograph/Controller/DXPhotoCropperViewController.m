//
//  DXPhotoCropperViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPhotoCropperViewController.h"
#import "DXPhotoEditorViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <pop/POP.h>
#import "DXImageKit.h"
#import "DXExtendButton.h"

typedef NS_ENUM(NSInteger, DXRotateRadian) {
    DXRotateRadian0Degrees = 0,
    DXRotateRadian90Degrees,
    DXRotateRadian180Degrees,
    DXRotateRadian270Degrees
};

@interface DXPhotoCropperViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) ALAssetsLibrary * assetsLibrary;

@property (nonatomic, strong) UIView * photoBgView;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIView * overlayView;
@property (nonatomic, strong) CAShapeLayer * maskLayer;

@property (nonatomic, strong) UIView * bottomBar;
@property (nonatomic, strong) DXExtendButton * previousStepButton;
@property (nonatomic, strong) DXExtendButton * rotateButton;
@property (nonatomic, strong) DXExtendButton * scaleButton;
@property (nonatomic, strong) DXExtendButton * fillButton;
@property (nonatomic, strong) DXExtendButton * nextStepButton;

@property (nonatomic, assign) DXPhotoScale photoScale;
@property (nonatomic, assign) BOOL enableAutoAttach;
@property (nonatomic, assign) BOOL doubleTapToApectFill;
@property (nonatomic, assign) BOOL singleTapToWhiteBg;
@property (nonatomic, assign) BOOL allowPinchAndPanSimultaneously;
@property (nonatomic, assign) CGRect imageViewRect;
@property (nonatomic, assign) CGRect maskRect;
/** 旋转弧度 */
@property (nonatomic, assign) DXRotateRadian rotateRadian;

@end

@implementation DXPhotoCropperViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _allowPhotoAdjusting = YES;
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        _enableAutoAttach = YES;
        _doubleTapToApectFill = NO;
        _singleTapToWhiteBg = NO;
        _allowPinchAndPanSimultaneously = YES;
        _rotateRadian = DXRotateRadian0Degrees;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dt_pageName = DXDataTrackingPage_CaptureCrop;
    self.view.backgroundColor = DXRGBColor(72, 72, 72);
    
    [self setupSubviews];
    [self setupViewEvents];
    
    if (self.enableFixedPhotoScale) {
        [self setPhotoScale:self.fixedPhotoScale animated:NO];
        self.scaleButton.enabled = NO;
    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:NO];
    hud.mode = MBProgressHUDModeIndeterminate;
    [self loadResources:^(BOOL ok) {
        if (ok) {
            [hud hide:YES];
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"无法加载此图片";
            [hud hide:YES afterDelay:2];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self clearResources];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Resources

- (void)loadResources:(void(^)(BOOL ok))completionBlock {
    if (self.photoAssetURL) {
        typeof(self) __weak weakSelf = self;
        
        [self.assetsLibrary assetForURL:self.photoAssetURL resultBlock:^(ALAsset *asset) {
            if (asset) {
                ALAssetRepresentation * rep = [asset defaultRepresentation];
                /**
                 *  高能预警：此处有坑！！！
                 *  rep有两个属性：fullScreenImage和fullResolutionImage
                 *  fullScreenImage已被调整过方向，可直接使用
                 *  使用fullResolutionImage要自己调整方法
                 *  fullResolutionImage尺寸太大，在手机端显示推荐用fullScreenImage
                 */
                weakSelf.originPhoto = [UIImage imageWithCGImage:rep.fullScreenImage scale:rep.scale orientation:UIImageOrientationUp];
                
                if (completionBlock) {
                    completionBlock(YES);
                }
            } else {
                [weakSelf loadResourceFromMyPhotoStream:completionBlock];
            }
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(NO);
                }
            });
        }];
    }
}

- (void)loadResourceFromMyPhotoStream:(void(^)(BOOL ok))completionBlock {
    typeof(self) __weak weakSelf = self;
    
    __block BOOL foundAsset = NO;
    // 此枚举遍历是异步的，解决了在iOS8以上（含8）读取“我的照片流”相册中的照片时会返回nil的问题
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        __block BOOL foundInGroup = NO;
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if ([result.defaultRepresentation.url isEqual:self.photoAssetURL]) {
                ALAssetRepresentation * rep = [result defaultRepresentation];
                if (rep) {
                    foundInGroup = YES;
                    /**
                     *  高能预警：此处有坑！！！
                     *  rep有两个属性：fullScreenImage和fullResolutionImage
                     *  fullScreenImage已被调整过方向，可直接使用
                     *  使用fullResolutionImage要自己调整方法
                     *  fullResolutionImage尺寸太大，在手机端显示推荐用fullScreenImage
                     */
                    weakSelf.originPhoto = [UIImage imageWithCGImage:rep.fullScreenImage scale:rep.scale orientation:UIImageOrientationUp];
                    
                    if (completionBlock) {
                        completionBlock(YES);
                    }
                }
                *stop = YES;
            }
        }];
        
        if (foundInGroup) {
            foundAsset = YES;
            *stop = YES;
        }
        
        // 当group为nil时，表示enumerateGroupsWithTypes的遍历结束了
        if (group == nil) {
            if (foundAsset == NO && completionBlock) {
                completionBlock(NO);
            }
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"fail to enumurate asset library: %@", error.localizedDescription);
        if (completionBlock) {
            completionBlock(NO);
        }
    }];
}

- (void)clearResources {
    self.imageViewRect = self.imageView.frame;
    self.imageView.image = nil;
    self.originPhoto = nil;
}


#pragma mark - Views

- (void)setupSubviews {
    [self setupBottomBar];
    [self setupPhotoView];
    [self setupOverlayView];
    [self.view insertSubview:self.imageView belowSubview:self.bottomBar];
    [self.view insertSubview:self.photoBgView belowSubview:self.imageView];
}

- (void)setupViewEvents {
    
    [self.previousStepButton addTarget:self
                                action:@selector(previousStepButtonTapped:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [self.rotateButton addTarget:self
                          action:@selector(rotateButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.scaleButton addTarget:self
                         action:@selector(scaleButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.fillButton addTarget:self
                        action:@selector(fillButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.nextStepButton addTarget:self
                            action:@selector(nextStepButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.overlayView addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer * pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    [self.overlayView addGestureRecognizer:pinchGesture];
    
    UITapGestureRecognizer * doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.overlayView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer * singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [self.overlayView addGestureRecognizer:singleTapGesture];
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
}

- (void)setupBottomBar {
    CGFloat bottomBarWidth = DXScreenWidth;
    CGFloat bottomBarHeight = 40;
    CGFloat bottomBarTop = DXScreenHeight - bottomBarHeight;
    
    _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, bottomBarTop, bottomBarWidth, bottomBarHeight)];
    _bottomBar.backgroundColor = [UIColor whiteColor];
    _bottomBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    CGFloat previousButtonLeading = roundf(DXRealValue(34));
    CGFloat previousButtonWidth = roundf(DXRealValue(73/3.0));
    CGFloat previousButtonHeight = previousButtonWidth;
    
    _previousStepButton = [[DXExtendButton alloc] init];
    _previousStepButton.translatesAutoresizingMaskIntoConstraints = NO;
    _previousStepButton.hitTestSlop = UIEdgeInsetsMake(-5, -5, -5, -5);
    _previousStepButton.titleLabel.font = [DXFont dxDefaultFontWithSize:50.0/3];
    [_previousStepButton setImage:[UIImage imageNamed:@"photo_close_Choose"] forState:UIControlStateNormal];
    
    CGFloat rotateButtonLeading = roundf(DXRealValue(117));
    CGFloat rotateButtonWidth = round(DXRealValue(68/3.0));
    CGFloat rotateButtonHeight = round(DXRealValue(62/3.0));
    
    _rotateButton = [[DXExtendButton alloc] init];
    _rotateButton.translatesAutoresizingMaskIntoConstraints = NO;
    _rotateButton.hitTestSlop = UIEdgeInsetsMake(-5, -5, -5, -5);
    [_rotateButton setImage:[UIImage imageNamed:@"camera_rotate"] forState:UIControlStateNormal];
    
    CGFloat scaleButtonWidth = roundf(DXRealValue(29));
    CGFloat scaleButtonHeight = roundf(DXRealValue(29));
    CGFloat scaleButtonCenterX = roundf(DXRealValue(205));
    
    _scaleButton = [[DXExtendButton alloc] init];
    _scaleButton.hitTestSlop = UIEdgeInsetsMake(-5, -5, -5, -5);
    _scaleButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_scaleButton setImage:[UIImage imageNamed:@"camera_scale_34"] forState:UIControlStateNormal];
    
    UIImage * fillButtonImage = [UIImage imageNamed:@"button_aspect_fill"];
    CGFloat fillButtonWidth = roundf(DXRealValue(fillButtonImage.size.width));
    CGFloat fillButtonHeight = roundf(DXRealValue(fillButtonImage.size.height));
    CGFloat fillButtonLeading = roundf(DXRealValue(815/3.0));
    
    _fillButton = [[DXExtendButton alloc] init];
    _fillButton.hitTestSlop = UIEdgeInsetsMake(-5, -5, -5, -5);
    _fillButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_fillButton setImage:fillButtonImage forState:UIControlStateNormal];
    
    CGFloat nextButtonTrailing = roundf(DXRealValue(13));
    CGFloat nextButtonWidth = roundf(DXRealValue(60));
    CGFloat nextButtonHeight = roundf(DXRealValue(29));
    
    _nextStepButton = [[DXExtendButton alloc] init];
    _nextStepButton.hitTestSlop = UIEdgeInsetsMake(-5, -5, -5, -5);
    _nextStepButton.translatesAutoresizingMaskIntoConstraints = NO;
    _nextStepButton.titleLabel.font = [DXFont dxDefaultFontWithSize:50.0/3];
    [_nextStepButton setTitle:@"下一步" forState:UIControlStateNormal];
    [_nextStepButton setTitleColor:DXRGBColor(109, 197, 255) forState:UIControlStateNormal];
    [_nextStepButton setTitleColor:DXRGBColor(55, 94, 126) forState:UIControlStateHighlighted];
    
    [_bottomBar addSubview:_previousStepButton];
    [_bottomBar addSubview:_rotateButton];
    [_bottomBar addSubview:_scaleButton];
    [_bottomBar addSubview:_fillButton];
    [_bottomBar addSubview:_nextStepButton];
    [self.view addSubview:_bottomBar];
    
    // 建立约束: 取消按钮
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_previousStepButton
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_bottomBar
                                                           attribute:NSLayoutAttributeLeading
                                                          multiplier:1.0 constant:previousButtonLeading]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_previousStepButton
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_bottomBar
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0 constant:0]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_previousStepButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0 constant:previousButtonWidth]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_previousStepButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0 constant:previousButtonHeight]];
    
    // 建立约束: 旋转按钮
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_rotateButton
                                                           attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeLeading multiplier:1.0
                                                            constant:rotateButtonLeading]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_rotateButton
                                                           attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomBar attribute:NSLayoutAttributeCenterY multiplier:1.0
                                                            constant:0]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_rotateButton
                                                           attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0 constant:rotateButtonWidth]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_rotateButton
                                                           attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0 constant:rotateButtonHeight]];
    
    // 建立约束: 比例按钮
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_scaleButton
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_bottomBar
                                                           attribute:NSLayoutAttributeLeading
                                                          multiplier:1.0 constant:scaleButtonCenterX]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_scaleButton
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_bottomBar
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0 constant:0]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_scaleButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0 constant:scaleButtonWidth]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_scaleButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0 constant:scaleButtonHeight]];
    
    // 建立约束: 自动填充按钮
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_fillButton
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_bottomBar
                                                           attribute:NSLayoutAttributeLeading
                                                          multiplier:1.0 constant:fillButtonLeading]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_fillButton
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_bottomBar
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0 constant:0]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_fillButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0 constant:fillButtonWidth]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_fillButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0 constant:fillButtonHeight]];
    
    // 建立约束: 下一步按钮
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_nextStepButton
                                                           attribute:NSLayoutAttributeTrailing
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_bottomBar
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1.0 constant:-nextButtonTrailing]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_nextStepButton
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_bottomBar
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0 constant:0]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_nextStepButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0 constant:nextButtonWidth]];
    [_bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:_nextStepButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0 constant:nextButtonHeight]];
}

- (void)setupPhotoView {
    CGRect photoBgViewRect = [self getMaskRectForScale:self.photoScale];
    
    _photoBgView = [[UIView alloc] initWithFrame:photoBgViewRect];
    _photoBgView.backgroundColor = [UIColor whiteColor];
    
    _imageView = [[UIImageView alloc] init];
    
    [self.view addSubview:_imageView];
    [self.view addSubview:_photoBgView];
}

- (void)setupOverlayView {
    CGFloat overlayViewWidth = DXScreenWidth;
    CGFloat overlayViewHeight = DXScreenHeight - CGRectGetHeight(self.bottomBar.bounds);
    
    _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, overlayViewWidth, overlayViewHeight)];
    _overlayView.backgroundColor = [UIColor colorWithWhite:0.28 alpha:0.75];

    CGRect maskLayerRect = [self getMaskRectForScale:self.photoScale];
    CGMutablePathRef maskLayerPath = CGPathCreateMutable();
    CGPathAddRect(maskLayerPath, NULL, _overlayView.bounds);
    CGPathAddRect(maskLayerPath, NULL, maskLayerRect);
    CGPathCloseSubpath(maskLayerPath);
    _maskLayer = [[CAShapeLayer alloc] init];
    _maskLayer.fillColor = [UIColor whiteColor].CGColor;
    _maskLayer.fillRule = kCAFillRuleEvenOdd;
    _maskLayer.path = maskLayerPath;
    _overlayView.layer.mask = _maskLayer;
    CGPathRelease(maskLayerPath);
    
    [self.view addSubview:_overlayView];
}

- (CGRect)getMaskRectForScale:(DXPhotoScale)scale {
    CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.bounds);
    CGFloat screenHeight = DXScreenHeight;
    CGFloat width = DXScreenWidth;
    CGFloat height = 0;
    CGFloat top = 0;
    switch (scale) {
        case DXPhotoScale1x1:
            height = width;
            break;
        case DXPhotoScale4x3:
            height = width * 3 / 4;
            break;
        case DXPhotoScale3x4:
        default:
            height = width * 4 / 3;
            break;
    }
    top = (screenHeight - bottomBarHeight - height) / 2;
    return CGRectMake(0, top, width, height);
}

- (void)updateUIWithImage:(UIImage *)image {
    if (self.enableFixedPhotoScale) {
        [self setPhotoScale:self.fixedPhotoScale animated:NO];
    } else {
        CGSize imageSize = [self getPhotoSize:image];
        CGFloat imageWidth = imageSize.width;
        CGFloat imageHeight = imageSize.height;
        if (imageWidth - imageHeight > 2 ) {
            [self setPhotoScale:DXPhotoScale4x3 animated:NO];
        } else if (imageWidth - imageHeight < -2) {
            [self setPhotoScale:DXPhotoScale3x4 animated:NO];
        } else {
            [self setPhotoScale:DXPhotoScale1x1 animated:NO];
        }
    }

    [self scaleImageViewToApectFill:YES animated:NO];
}

- (void)updateUIForScale:(DXPhotoScale)scale animated:(BOOL)animated {
    // 更新比例按钮
    NSString * scaleButtonImageName = nil;
    switch (scale) {
        case DXPhotoScale1x1:
            scaleButtonImageName = @"camera_scale_11";
            break;
        case DXPhotoScale4x3:
            scaleButtonImageName = @"camera_scale_43";
            break;
        case DXPhotoScale3x4:
        default:
            scaleButtonImageName = @"camera_scale_34";
            break;
    }
    [self.scaleButton setImage:[UIImage imageNamed:scaleButtonImageName] forState:UIControlStateNormal];
    
    // 更新photoBgView
    CGRect photoBgViewRect = [self getMaskRectForScale:scale];
    BOOL becomeLarger = CGRectContainsRect(photoBgViewRect, self.photoBgView.frame);
    NSString * const frameAnimationName = @"photoBgView.frame";
    [self.photoBgView pop_removeAnimationForKey:frameAnimationName];
    // 无论是否animated，photoBgView在变大时不执行动画，避免与maskLayer动画有细微差别导致控制器视图的背景透出
    if (animated && !becomeLarger) {
        POPBasicAnimation * bgViewFrameAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
        bgViewFrameAnimation.duration = 1.2f;
        bgViewFrameAnimation.toValue = [NSValue valueWithCGRect:photoBgViewRect];
        [self.photoBgView pop_addAnimation:bgViewFrameAnimation forKey:frameAnimationName];
    } else {
        self.photoBgView.frame = photoBgViewRect;
    }
    
    // 更新maskLayer
    CGRect maskRect = photoBgViewRect;
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathAddRect(maskPath, NULL, self.overlayView.bounds);
    CGPathAddRect(maskPath, NULL, maskRect);
    CGPathCloseSubpath(maskPath);
    NSString * const pathAnimationName = @"maskLayer.path";
    if (animated) {
        CABasicAnimation * pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = 0.2f;
        pathAnimation.fromValue = (__bridge id)self.maskLayer.path;
        pathAnimation.toValue = (__bridge id)maskPath;
        self.maskLayer.path = maskPath;
        [self.maskLayer addAnimation:pathAnimation forKey:pathAnimationName];
    } else {
        self.maskLayer.path = maskPath;
    }
    CGPathRelease(maskPath);
}

- (CGSize)getPhotoSize:(UIImage *)photo {
    @autoreleasepool {
        UIImageView * imageView = [[UIImageView alloc] initWithImage:photo];
        [imageView sizeToFit];
        imageView.transform = CGAffineTransformMakeRotation(M_PI_2 * self.rotateRadian);
        return CGSizeMake(imageView.width, imageView.height);
    }
}

- (void)autoAttachEdges {
    const CGFloat attachDistance = 3;
    CGRect photoFrame = self.imageView.frame;
    CGRect maskFrame = self.maskRect;
    
    const CGFloat photoLeftEdge = photoFrame.origin.x;
    const CGFloat photoTopEdge = photoFrame.origin.y;
    const CGFloat photoRightEdge = photoFrame.origin.x + photoFrame.size.width;
    const CGFloat photoBottomEdge = photoFrame.origin.y + photoFrame.size.height;
    const CGFloat photoCenterX = self.imageView.center.x;
    const CGFloat photoCenterY = self.imageView.center.y;
    
    const CGFloat maskLeftEdge = maskFrame.origin.x;
    const CGFloat maskTopEdge = maskFrame.origin.y;
    const CGFloat maskRightEdge = maskFrame.origin.x + maskFrame.size.width;
    const CGFloat maskBottomEdge = maskFrame.origin.y + maskFrame.size.height;
    const CGFloat maskCenterX = maskFrame.origin.x + maskFrame.size.width / 2;
    const CGFloat maskCenterY = maskFrame.origin.y + maskFrame.size.height / 2;
    
    BOOL needsToAttach = NO;
    CGPoint origin = photoFrame.origin;
    
    const CGFloat leftDistance = ABS(photoLeftEdge - maskLeftEdge);
    const CGFloat rightDistance = ABS(photoRightEdge - maskRightEdge);

    if (leftDistance <= attachDistance) {
        // 左侧吸附
        needsToAttach = YES;
        origin.x = maskLeftEdge;
    } else if (rightDistance <= attachDistance) {
        // 右侧吸附
        needsToAttach = YES;
        origin.x = maskRightEdge - photoFrame.size.width;
    } else if (ABS(photoCenterX-maskCenterX) <= attachDistance) {
        // X轴中线吸附
        needsToAttach = YES;
        origin.x = maskCenterX - photoFrame.size.width / 2;
    }
    
    const CGFloat topDistance = ABS(photoTopEdge - maskTopEdge);
    const CGFloat bottomDistance = ABS(photoBottomEdge - maskBottomEdge);
    
    if (topDistance <= attachDistance) {
        // 上侧吸附
        needsToAttach = YES;
        origin.y = maskTopEdge;
    } else if (bottomDistance <= attachDistance) {
        // 下侧吸附
        needsToAttach = YES;
        origin.y = maskBottomEdge - photoFrame.size.height;
    } else if (ABS(photoCenterY-maskCenterY) <= attachDistance) {
        // Y轴中线吸附
        needsToAttach = YES;
        origin.y = maskCenterY - photoFrame.size.height / 2;
    }
    
    if (needsToAttach) {
        photoFrame.origin = origin;
        self.imageView.frame = photoFrame;
    }
}

- (void)autoScaleSize {
    const CGFloat attachDistance = 5.0;
    CGPoint photoCenter = self.imageView.center;
    CGRect photoFrame = self.imageView.frame;
    CGRect maskFrame = self.maskRect;
    
    CGFloat photoWidth = photoFrame.size.width;
    CGFloat photoHeight = photoFrame.size.height;
    CGFloat photoScale = photoWidth / photoHeight;
    CGFloat maskWidth = maskFrame.size.width;
    CGFloat maskHeight = maskFrame.size.height;
    
    CGSize size = photoFrame.size;
    BOOL needsToScale = NO;
    
    if (photoWidth > maskWidth && ABS(photoWidth-maskWidth) <= attachDistance) {
        size.width = maskWidth;
        size.height = maskWidth / photoScale;
        needsToScale = YES;
    } else if (photoHeight > maskHeight && ABS(photoHeight-maskHeight) <= attachDistance) {
        size.height = maskHeight;
        size.width = maskHeight * photoScale;
        needsToScale = YES;
    }
    
    if (needsToScale) {
        photoFrame.size = size;
        self.imageView.frame = photoFrame;
        self.imageView.center = photoCenter;
    }
}

- (void)scaleImageViewToApectFill:(BOOL)aspectFill animated:(BOOL)animated {
    self.doubleTapToApectFill = !aspectFill;
    if (aspectFill) {
        [self.fillButton setImage:[UIImage imageNamed:@"button_aspect_fit"] forState:UIControlStateNormal];
    } else {
        [self.fillButton setImage:[UIImage imageNamed:@"button_aspect_fill"] forState:UIControlStateNormal];
    }
    
    CGSize imageSize = [self getPhotoSize:self.originPhoto];
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    CGRect visibleRect = [self getMaskRectForScale:self.photoScale];
    CGFloat visibleWidth = CGRectGetWidth(visibleRect);
    CGFloat visibleHeight = CGRectGetHeight(visibleRect);
    CGFloat visibleScale = visibleWidth / visibleHeight;
    CGFloat imageScale = imageWidth / imageHeight;
    
    __block CGFloat imageViewWidth, imageViewHeight, imageViewLeft, imageViewTop;
    
    dispatch_block_t fetch_params_with_same_height = ^{
        imageViewHeight = visibleHeight;
        imageViewWidth = imageViewHeight * imageScale;
        imageViewLeft = CGRectGetMinX(visibleRect) - (imageViewWidth - visibleWidth) / 2;
        imageViewTop = CGRectGetMinY(visibleRect);
    };
    
    dispatch_block_t fetch_params_with_same_width = ^{
        imageViewWidth = visibleWidth;
        imageViewHeight = imageViewWidth / imageScale;
        imageViewLeft = CGRectGetMinX(visibleRect);
        imageViewTop = CGRectGetMinY(visibleRect) - (imageViewHeight - visibleHeight) / 2;
    };
    
    if (imageScale > visibleScale) {
        if (aspectFill) {
            fetch_params_with_same_height();
        } else {
            fetch_params_with_same_width();
        }
    } else if (imageScale < visibleScale) {
        if (aspectFill) {
            fetch_params_with_same_width();
        } else {
            fetch_params_with_same_height();
        }
    } else {
        imageViewWidth = visibleWidth;
        imageViewHeight = visibleHeight;
        imageViewLeft = CGRectGetMinX(visibleRect);
        imageViewTop = CGRectGetMinY(visibleRect);
    }
    
    [self.imageView pop_removeAllAnimations];
    CGRect frame = CGRectMake(imageViewLeft, imageViewTop, imageViewWidth, imageViewHeight);
    if (animated) {
        NSString * const imageViewFrameAnimation = @"imageView.frame";
        POPBasicAnimation * frameAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
        frameAnimation.duration = 0.4;
        frameAnimation.toValue = [NSValue valueWithCGRect:frame];
        [self.imageView pop_addAnimation:frameAnimation forKey:imageViewFrameAnimation];
    } else {
        self.imageView.frame = frame;
    }
}

#pragma mark - Image

- (UIImage *)getCroppedImage {
    // 清除旋转
    UIImageOrientation orientation = [self imageOrientationForOriginPhoto];
    CGImageRef unrotatedImageRef = [DXImageKit newUnrotatedImageFromImage:self.originPhoto.CGImage
                                                             withOrientation:orientation];
    // 计算背景大小
    CGRect bgRect = [self getMaskRectForScale:self.photoScale];
    CGFloat bgWidth = CGRectGetWidth(bgRect);
    CGFloat bgHeight = CGRectGetHeight(bgRect);
    CGFloat scale = 1080 / MIN(bgWidth, bgHeight);
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    bgWidth = bgWidth * scale / screenScale;
    bgHeight = bgHeight * scale / screenScale;
    
    // 计算图片位置
    CGRect imageRect = [self.view convertRect:self.imageView.frame toView:self.photoBgView];
    CGFloat imageX = imageRect.origin.x * scale / screenScale;
    CGFloat imageY = imageRect.origin.y * scale / screenScale;
    imageRect.size.width *= scale / screenScale;
    imageRect.size.height *= scale / screenScale;
    imageRect.origin.x = imageX;
    imageRect.origin.y = bgHeight - imageRect.size.height - imageY; //根据UI和CG的坐标关系进行一次转换
    
    // 绘制图像
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(bgWidth, bgHeight), YES, screenScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.photoBgView.backgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, bgWidth, bgHeight));
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, bgHeight);
    CGContextConcatCTM(context, flipVertical); //根据UI和CG的坐标关系将空间进行垂直翻转
    CGContextDrawImage(context, imageRect, unrotatedImageRef);
    CGImageRef croppedImageRef = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    UIImage * croppedImage = [[UIImage alloc] initWithCGImage:croppedImageRef scale:screenScale orientation:UIImageOrientationUp];
    
    CGImageRelease(unrotatedImageRef);
    CGImageRelease(croppedImageRef);

    return croppedImage;
}

#pragma mark - Properties Accesors

- (void)setPhotoScale:(DXPhotoScale)photoScale {
    [self setPhotoScale:photoScale animated:YES];
}

- (void)setPhotoScale:(DXPhotoScale)photoScale animated:(BOOL)animated {
    _photoScale = photoScale;
    self.maskRect = [self getMaskRectForScale:photoScale];
    [self updateUIForScale:photoScale animated:animated];
}

- (void)setOriginPhoto:(UIImage *)originPhoto {
    _originPhoto = originPhoto;
    
    [self.imageView setImage:originPhoto];
    
    if (originPhoto == nil) {
        return;
    }
    
    if (CGRectEqualToRect(self.imageViewRect, CGRectZero)) {
        [self updateUIWithImage:originPhoto];
    }
}

#pragma mark - Button Actions

- (IBAction)previousStepButtonTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rotateButtonTapped:(UIButton *)sender {
    
    self.rotateRadian += 1;
    if (self.rotateRadian > DXRotateRadian270Degrees) {
        self.rotateRadian = DXRotateRadian0Degrees;
    }
    
    NSString * const animationKey = @"pop.layer.rotation";
    POPBasicAnimation *rotateAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    
    rotateAnimation.fromValue = @(M_PI_2 * (self.rotateRadian - 1));
    rotateAnimation.toValue = @(M_PI_2 * self.rotateRadian);
    rotateAnimation.duration = 0.5;
    
//    [self.imageView.layer pop_removeAnimationForKey:animationKey];
    [self.imageView.layer pop_addAnimation:rotateAnimation forKey:animationKey];
    
}

- (IBAction)scaleButtonTapped:(UIButton *)sender {
    DXPhotoScale nextScale = DXPhotoScale3x4;
    switch (self.photoScale) {
        case DXPhotoScale1x1:
            nextScale = DXPhotoScale4x3;
            break;
        case DXPhotoScale4x3:
            nextScale = DXPhotoScale3x4;
            break;
        case DXPhotoScale3x4:
            nextScale = DXPhotoScale1x1;
            break;
        default:
            nextScale = DXPhotoScale3x4;
            break;
    }
    self.photoScale = nextScale;
}

- (IBAction)fillButtonTapped:(UIButton *)sender {
    if (self.doubleTapToApectFill) {
        [self scaleImageViewToApectFill:YES animated:YES];
    } else {
        [self scaleImageViewToApectFill:NO animated:YES];
    }
}

- (IBAction)nextStepButtonTapped:(UIButton *)sender {

    @autoreleasepool {
        UIImage * croppedImage = [self getCroppedImage];
        
        if (self.allowPhotoAdjusting) {
            DXPhotoEditorViewController * photoEditorVC = [[DXPhotoEditorViewController alloc] init];
            photoEditorVC.photo = croppedImage;
            [self.navigationController pushViewController:photoEditorVC animated:YES];
        } else {
            NSDictionary * userInfo = @{ @"photo" : croppedImage };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DXPublishUserDidFinishEditPhoto" object:self userInfo:userInfo];
        }
    }
}


#pragma mark - Gestures

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    static CGPoint imageViewCenter;
    CGPoint translation = [gesture translationInView:self.overlayView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            imageViewCenter = self.imageView.center;
            break;
        case UIGestureRecognizerStateChanged:
            self.imageView.center = CGPointMake(imageViewCenter.x + translation.x, imageViewCenter.y + translation.y);
            
            if (self.enableAutoAttach) {
                [self autoAttachEdges];
            }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gesture {
    static CGSize lastSize;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            lastSize = CGSizeMake(self.imageView.width, self.imageView.height);
            break;
        case UIGestureRecognizerStateChanged: {
            // 统一规则，无论是双指缩放还是双击缩放，都是通过改变frame，而不是transform
            CGPoint center = self.imageView.center;
            CGSize size = CGSizeMake(lastSize.width * gesture.scale, lastSize.height * gesture.scale);
            CGRect frame = CGRectMake(center.x-size.width/2, center.y-size.height/2, size.width, size.height);
            self.imageView.frame = frame;
            
            if (self.enableAutoAttach) {
                [self autoScaleSize];
            }
        }
            break;
        default:
            break;
    }
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        return;
    }
    
    [self fillButtonTapped:self.fillButton];
}

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        return;
    }
    
    if (self.singleTapToWhiteBg) {
        self.photoBgView.backgroundColor = [UIColor whiteColor];
        self.singleTapToWhiteBg = NO;
    } else {
        self.photoBgView.backgroundColor = [UIColor blackColor];
        self.singleTapToWhiteBg = YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.allowPinchAndPanSimultaneously) {
        if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
            if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - get orientation

- (UIImageOrientation)imageOrientationForOriginPhoto {
    switch (self.rotateRadian) {
        case DXRotateRadian0Degrees:
            return UIImageOrientationUp;
            break;
        case DXRotateRadian90Degrees:
            return UIImageOrientationRight;
            break;
        case DXRotateRadian180Degrees:
            return UIImageOrientationDown;
            break;
        case DXRotateRadian270Degrees:
            return UIImageOrientationLeft;
            break;
            
        default:
            return UIImageOrientationUp;
            break;
    }
}

@end
