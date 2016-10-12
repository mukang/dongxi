//
//  DXPhotoTakerViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <pop/POP.h>
#import <CoreMotion/CoreMotion.h>

#import "DXPhotoTakerViewController.h"
#import "DXPhotoEditorViewController.h"
#import "DXPhotoCropperViewController.h"
#import "DXImageKit.h"
#import "DXCameraCaptureButton.h"
#import "DXScreenNotice.h"
#import "DXPhotoTakerController.h"
#import "DXExtendButton.h"

@interface DXPhotoTakerViewController () <UIToolbarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIView * topToolbar;
@property (nonatomic, strong) DXExtendButton * flashModeButton;
@property (nonatomic, strong) DXExtendButton * cameraScaleButton;
@property (nonatomic, strong) DXExtendButton * showGridButton;

@property (nonatomic, strong) UIView * bottomToolBar;
@property (nonatomic, strong) UIButton * closeButton;
@property (nonatomic, strong) UIButton * albumPreviewView;
@property (nonatomic, strong) UIView * extraOverlayView;

@property (nonatomic, strong) UIView * cameraPreviewView;
@property (nonatomic, strong) UIImageView * cameraGrid1x1View;
@property (nonatomic, strong) UIImageView * cameraGrid3x4View;
@property (nonatomic, strong) UIView * cameraCoverView;
@property (nonatomic, strong) DXCameraCaptureButton * captureButton;

/* Camera Related */
@property (nonatomic, assign) BOOL cameraLoaded;
@property (nonatomic, strong) AVCaptureSession * captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput * captureInput;
@property (nonatomic, strong) AVCaptureStillImageOutput * captureImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * cameraPreviewViewlayer;
@property (nonatomic, strong) AVCaptureConnection * captureConnection;
@property (nonatomic, strong) dispatch_queue_t imageProcessQueue;
@property (nonatomic, assign, getter=isPhotoCapturing) BOOL photoCapturing;
@property (nonatomic, assign) UIImageOrientation imageOrientation;
@property (nonatomic, assign) DXPhotoScale cameraScale;
@property (nonatomic, assign) BOOL showGrid;

/* Motion Manager */
@property (nonatomic, strong) NSOperationQueue * accelerometerQueue;
@property (nonatomic, strong) CMMotionManager * motionManager;

- (void)playCameraOpenAnimation;
//- (void)showLastAlbumPhotoInView:(UIButton *)albumPreviewView;
- (void)capturePhoto:(void(^)(UIImage * photo, NSError * error))resultBlock;
- (void)cropImageWithData:(NSData *)imageData inAspectRect:(CGRect)aspectRect result:(void(^)(UIImage * croppedImage))resultBlock;

@end

@implementation DXPhotoTakerViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _mode = DXPhotoTakerModeCameraAndAlbum;
        _allowPhotoAdjusting = YES;
        _showGrid = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dt_pageName = DXDataTrackingPage_CaptureCamera;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.mode == DXPhotoTakerModeAlbumOnly) {
        [self showAlbum:YES];
    }
    
    [self setupSubviews];
    [self setupTouchEvents];
    
    // 如果启用固定一个比例，隐藏比例调整按钮，切换到该比例
    if (self.enableFixedPhotoScale) {
        self.cameraScaleButton.hidden = YES;
        self.cameraScale = self.fixedPhotoScale;
    }
    
    self.imageProcessQueue = dispatch_queue_create("com.juyi.PhotoTakerViewController", DISPATCH_QUEUE_CONCURRENT);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if (self.mode == DXPhotoTakerModeCameraAndAlbum) {
//        [self showLastAlbumPhotoInView:self.albumPreviewView];
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.mode != DXPhotoTakerModeAlbumOnly) {
        if (!self.cameraLoaded) {
            NSError * cameraError = nil;
            AVCaptureFlashMode flashMode = AVCaptureFlashModeAuto;
            
            [self loadCamera:&cameraError inView:self.cameraPreviewView withFrame:self.cameraPreviewView.bounds flashMode:&flashMode];
            if (cameraError) {
                DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"无法打开摄像头" fromController:self];
                [notice setDisableAutoDismissed:YES];
                [notice setTapToDismissEnabled:YES completion:nil];
                [notice show];
            } else {
                [self setFlashMode:flashMode];
                if (self.enableCameraOpenAnimation) {
                    [self playCameraOpenAnimation];
                } else {
                    self.cameraCoverView.hidden = YES;
                }
            }
            self.cameraLoaded = YES;
        } else {
            [self.cameraPreviewViewlayer connection].enabled = YES;
        }
    }
    
    [self registerNotifications];
    [self startAccelerometer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.cameraPreviewViewlayer connection].enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self unregisterNotifications];
    [self stopAccelerometer];
}

- (void)setupSubviews {
    [self setupCameraPreviewView];
    [self setupCameraOverlayViews];
}

- (void)setupTouchEvents {
    [self.flashModeButton addTarget:self action:@selector(flashModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraScaleButton addTarget:self action:@selector(cameraScaleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.showGridButton addTarget:self action:@selector(showGridButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.captureButton addTarget:self action:@selector(captureButtonTapped:) forControlEvents:UIControlEventTouchDown];
    [self.albumPreviewView addTarget:self action:@selector(albumPreviewTapped:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)setupCameraPreviewView {
    CGFloat screenWidth = DXScreenWidth;
    CGFloat previewWidth = screenWidth;
    CGFloat previewHeight = roundf(previewWidth * 4 / 3);
    
    _cameraPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, previewWidth, previewHeight)];
    _cameraPreviewView.backgroundColor = [UIColor blackColor];
    _cameraPreviewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:_cameraPreviewView];
}

- (void)setupCameraOverlayViews {
    CGFloat screenWidth = DXScreenWidth;
    CGFloat screenHeight = DXScreenHeight;

    // ------------------------- 创建顶部工具栏 -------------------------
    
    CGFloat topToolBarWidth = screenWidth;
    CGFloat topToolBarHeight = roundf(DXRealValue(63));
    CGFloat topToolBarCenterYOffset = -roundf(DXRealValue(5));
    CGFloat topToolBarLeftPadding = roundf(DXRealValue(17));
    CGFloat topToolBarRightPadding = roundf(DXRealValue(17));
    
    _topToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topToolBarWidth, topToolBarHeight)];
    _topToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _topToolbar.backgroundColor = [UIColor clearColor];
    
    UIImage * flashModeImage = [UIImage imageNamed:@"button_photo_light_automatically"];
    CGFloat flashButtonWidth = roundf(DXRealValue(flashModeImage.size.width));
    CGFloat flashButtonHeight = roundf(DXRealValue(flashModeImage.size.height));
    
    _flashModeButton = [[DXExtendButton alloc] init];
    _flashModeButton.hitTestSlop = UIEdgeInsetsMake(0, 0, -10, 0); //可点击区域向下延伸10个point
    _flashModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_flashModeButton setImage:flashModeImage forState:UIControlStateNormal];
    
    UIImage * cameraScale34Image = [UIImage imageNamed:@"camera_scale_34"];
    CGFloat cameraScaleButtonWidth = roundf(DXRealValue(cameraScale34Image.size.width));
    CGFloat cameraScaleButtonHeight = roundf(DXRealValue(cameraScale34Image.size.height));
    
    _cameraScaleButton = [[DXExtendButton alloc] init];
    _cameraScaleButton.hitTestSlop = UIEdgeInsetsMake(0, 0, -10, 0); //可点击区域向下延伸10个point
    _cameraScaleButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cameraScaleButton setImage:cameraScale34Image forState:UIControlStateNormal];
    
    UIImage * hideGridImage = [UIImage imageNamed:@"camera_grid_disable"];
    CGFloat showGridButtonWidth = roundf(DXRealValue(hideGridImage.size.width));
    CGFloat showGridButtonHeight = roundf(DXRealValue(hideGridImage.size.height));
    
    _showGridButton = [[DXExtendButton alloc] init];
    _showGridButton.hitTestSlop = UIEdgeInsetsMake(0, 0, -10, 0); //可点击区域向下延伸10个point
    _showGridButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_showGridButton setImage:(self.showGrid ? [UIImage imageNamed:@"camera_grid_enable"] : hideGridImage)
                     forState:UIControlStateNormal];
    
    [_topToolbar addSubview:_flashModeButton];
    [_topToolbar addSubview:_cameraScaleButton];
    [_topToolbar addSubview:_showGridButton];
    [self.view addSubview:_topToolbar];
    // 闪光模式按钮约束
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_flashModeButton
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0 constant:flashButtonWidth]];
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_flashModeButton
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0 constant:flashButtonHeight]];
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_flashModeButton
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_topToolbar
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0 constant:topToolBarLeftPadding]];
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_flashModeButton
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_topToolbar
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0 constant:topToolBarCenterYOffset]];
    // 图像比例按钮约束
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_cameraScaleButton
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0 constant:cameraScaleButtonWidth]];
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_cameraScaleButton
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0 constant:cameraScaleButtonHeight]];
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_cameraScaleButton
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_topToolbar
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0 constant:0]];
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_cameraScaleButton
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_flashModeButton
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0 constant:0]];
    // 显示网格按钮约束
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_showGridButton
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0 constant:showGridButtonWidth]];
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_showGridButton
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0 constant:showGridButtonHeight]];
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_showGridButton
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_topToolbar
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0 constant:-topToolBarRightPadding]];
    [_topToolbar addConstraint:[NSLayoutConstraint constraintWithItem:_showGridButton
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_flashModeButton
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0 constant:0]];
    
    
    // ------------------------- 创建网格视图 -------------------------
    
    CGFloat grid1x1Top = topToolBarHeight;
    CGFloat grid1x1Height = screenWidth;
    CGFloat grid1x1Width = screenWidth;
    _cameraGrid1x1View = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_grid_1x1"]];
    _cameraGrid1x1View.frame = CGRectMake(0, grid1x1Top, grid1x1Width, grid1x1Height);
    _cameraGrid1x1View.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _cameraGrid1x1View.alpha = self.showGrid && (self.cameraScale == DXPhotoScale1x1);
    [self.view addSubview:_cameraGrid1x1View];
    
    CGFloat grid3x4Height = roundf(screenWidth * 4 / 3);
    CGFloat grid3x4Width = screenWidth;
    _cameraGrid3x4View = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_grid_3x4"]];
    _cameraGrid3x4View.frame = CGRectMake(0, 0, grid3x4Width, grid3x4Height);
    _cameraGrid3x4View.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _cameraGrid3x4View.alpha = self.showGrid && (self.cameraScale != DXPhotoScale1x1);
    [self.view addSubview:_cameraGrid3x4View];
    
    // ------------------------- 创建额外的覆盖视图 -------------------------
    
    CGFloat extraOverlayViewWidth = screenWidth;
    CGFloat extraOverlayViewHeight = screenHeight - topToolBarHeight - screenWidth;
    CGFloat extraOverlayViewTop = topToolBarHeight + screenWidth;
    
    _extraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, extraOverlayViewTop, extraOverlayViewWidth, extraOverlayViewHeight)];
    _extraOverlayView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_extraOverlayView];
    
    // ------------------------- 创建底部工具栏 -------------------------
    
    CGFloat bottomBarWidth = screenWidth;
    CGFloat bottomBarHeight = screenHeight - roundf(screenWidth * 4 / 3);
    CGFloat bottomBarTop = screenHeight - bottomBarHeight;
    
    _bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, bottomBarTop, bottomBarWidth, bottomBarHeight)];
    _bottomToolBar.clipsToBounds = NO;
    _bottomToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _bottomToolBar.backgroundColor = [UIColor whiteColor];
    
    CGFloat viewScale = 1;
    
    CGFloat captureButtonWidth = roundf(DXRealValue(87));
    CGFloat captureButtonHeight = roundf(DXRealValue(87));
    CGFloat captureButtonMargin = roundf(DXRealValue(14));
    
    // 检查在显示1x1取景时，拍照按钮是否会超出顶部栏的边界，如果超出则重新调整大小
    if (captureButtonHeight + captureButtonMargin * 2 > bottomBarHeight) {
        CGFloat originHeight = captureButtonHeight;
        captureButtonMargin = roundf(DXRealValue(2));
        captureButtonHeight = bottomBarHeight - captureButtonMargin * 2;
        captureButtonWidth = captureButtonHeight;
        viewScale = captureButtonHeight / originHeight;
    }
    
    _captureButton = [[DXCameraCaptureButton alloc] init];
    _captureButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    /*
    CGFloat albumPreviewHeight = roundf(DXRealValue(63) * viewScale);
    CGFloat albumPreviewWidth = albumPreviewHeight;
    CGFloat albumPreviewTrailing = roundf(DXRealValue(6.67));
    CGFloat albumPreivewBottom = viewScale < 1 ? (bottomBarHeight-albumPreviewHeight)/2 : albumPreviewTrailing;
     */
    
    UIImage *albumImage = [UIImage imageNamed:@"camera_album"];
    CGFloat albumPreviewHeight = roundf(DXRealValue(albumImage.size.width));
    CGFloat albumPreviewWidth = albumPreviewHeight;
    CGFloat albumPreviewTrailing = roundf(DXRealValue(17));
    CGFloat albumPreivewBottom = viewScale < 1 ? (bottomBarHeight-albumPreviewHeight)/2 : albumPreviewTrailing;
    
    _albumPreviewView = [[UIButton alloc] initWithFrame:CGRectZero];
    _albumPreviewView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_albumPreviewView setImage:albumImage forState:UIControlStateNormal];
    _albumPreviewView.translatesAutoresizingMaskIntoConstraints = NO;
    _albumPreviewView.hidden = (self.mode == DXPhotoTakerModeCameraOnly);
    
    UIImage * closeButtonImage = [UIImage imageNamed:@"photo_close"];
    CGFloat closeButtonWidth = roundf(DXRealValue(closeButtonImage.size.width));
    CGFloat closeButtonHeight = roundf(DXRealValue(closeButtonImage.size.height));
    CGFloat closeButtonLeading = roundf(DXRealValue(71/3.0));
    
    _closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    
    [_bottomToolBar addSubview:_closeButton];
    [_bottomToolBar addSubview:_albumPreviewView];
    [_bottomToolBar addSubview:_captureButton];
    
    [self.view addSubview:_bottomToolBar];
    
    // 使用Auto Layout约束
    // 相册预览按钮
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_albumPreviewView
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_bottomToolBar
                                                               attribute:NSLayoutAttributeTrailing
                                                              multiplier:1.0 constant:-albumPreviewTrailing]];
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_albumPreviewView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_bottomToolBar
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0 constant:-albumPreivewBottom]];
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_albumPreviewView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0 constant:albumPreviewWidth]];
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_albumPreviewView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0 constant:albumPreviewHeight]];
    
    // 关闭按钮
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_closeButton
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_bottomToolBar
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0 constant:closeButtonLeading]];
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_closeButton
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_albumPreviewView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0 constant:0]];
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_closeButton
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0 constant:closeButtonWidth]];
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_closeButton
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0 constant:closeButtonHeight]];
    
    // 拍照按钮
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_captureButton
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0 constant:captureButtonWidth]];
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_captureButton
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0 constant:captureButtonHeight]];
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_captureButton
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_bottomToolBar
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0 constant:0]];
    [_bottomToolBar addConstraint:[NSLayoutConstraint constraintWithItem:_captureButton
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_bottomToolBar
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0 constant:captureButtonMargin]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI status control

- (void)setFlashMode:(AVCaptureFlashMode)mode {
    switch (mode) {
        case AVCaptureFlashModeOn:
            [self.flashModeButton setImage:[UIImage imageNamed:@"button_photo_light_open"] forState:UIControlStateNormal];
            break;
        case AVCaptureFlashModeOff:
            [self.flashModeButton setImage:[UIImage imageNamed:@"button_photo_light_close"] forState:UIControlStateNormal];
            break;
        default:
            [self.flashModeButton setImage:[UIImage imageNamed:@"button_photo_light_automatically"] forState:UIControlStateNormal];
            break;
    }
}

- (void)setCameraScale:(DXPhotoScale)cameraScale {
    _cameraScale = cameraScale;
    
    UIImage * cameraScaleButtonImage = nil;
    
    switch (cameraScale) {
        case DXPhotoScale1x1:
            cameraScaleButtonImage = [UIImage imageNamed:@"camera_scale_11"];
            break;
        case DXPhotoScale3x4:
            cameraScaleButtonImage = [UIImage imageNamed:@"camera_scale_34"];
            break;
        case DXPhotoScale4x3:
            cameraScaleButtonImage = [UIImage imageNamed:@"camera_scale_43"];
            break;
        default:
            break;
    }
    
    if (cameraScaleButtonImage) {
        [self.cameraScaleButton setImage:cameraScaleButtonImage forState:UIControlStateNormal];
        [self show1x1ScaleUI:(cameraScale == DXPhotoScale1x1)];
    }
}

- (void)show1x1ScaleUI:(BOOL)show {
    if (show) {
        if (self.showGrid) {
            self.cameraGrid1x1View.alpha = 1;
            self.cameraGrid3x4View.alpha = 0;
        }
        self.topToolbar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
        self.extraOverlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
    } else {
        if (self.showGrid) {
            self.cameraGrid1x1View.alpha = 0;
            self.cameraGrid3x4View.alpha = 1;
        }
        self.topToolbar.backgroundColor = [UIColor clearColor];
        self.extraOverlayView.backgroundColor = [UIColor clearColor];
    }
}

- (void)rotateUIByImageOrientation:(UIImageOrientation)orientation {
    [self rotateUIByImageOrientation:orientation forceUpdate:NO];
}

- (void)rotateUIByImageOrientation:(UIImageOrientation)orientation forceUpdate:(BOOL)force {
    if (self.imageOrientation == orientation && !force) {
        return;
    }
    
    CGFloat angleInRadian = 0;
    
    switch (orientation) {
            // 图片被顺时针旋转90度
        case UIImageOrientationLeft:
            angleInRadian = -M_PI_2;
            if (self.cameraScale == DXPhotoScale3x4) {
                self.cameraScale = DXPhotoScale4x3;
            }
            break;
            // 图片被逆时针旋转90度
        case UIImageOrientationRight:
            angleInRadian = M_PI_2;
            if (self.cameraScale == DXPhotoScale3x4) {
                self.cameraScale = DXPhotoScale4x3;
            }
            break;
        default:
            angleInRadian = 0;
            if (self.cameraScale == DXPhotoScale4x3) {
                self.cameraScale = DXPhotoScale3x4;
            }
            break;
    }
    
    [self rotateUIToAngle:angleInRadian];
    
    self.imageOrientation = orientation;
}

- (void)rotateUIToAngle:(CGFloat)angleInRadian {
    NSString * const animationKey = @"pop.layer.rotation";
    POPBasicAnimation * rotateAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotateAnimation.toValue = @(angleInRadian);
    rotateAnimation.duration = 0.5;
    
    [self.flashModeButton.layer pop_removeAnimationForKey:animationKey];
    [self.flashModeButton.layer pop_addAnimation:rotateAnimation forKey:animationKey];
    
    [self.cameraScaleButton.layer pop_removeAnimationForKey:animationKey];
    [self.cameraScaleButton.layer pop_addAnimation:rotateAnimation forKey:animationKey];
    
    [self.showGridButton.layer pop_removeAnimationForKey:animationKey];
    [self.showGridButton.layer pop_addAnimation:rotateAnimation forKey:animationKey];
    
    [self.closeButton.layer pop_removeAnimationForKey:animationKey];
    [self.closeButton.layer pop_addAnimation:rotateAnimation forKey:animationKey];
    
    [self.albumPreviewView.layer pop_removeAnimationForKey:animationKey];
    [self.albumPreviewView.layer pop_addAnimation:rotateAnimation forKey:animationKey];
}

- (CGRect)getCameraVisibleRectInScale {
    CGFloat screenWidth = DXScreenWidth;
    if (self.cameraScale == DXPhotoScale1x1) {
        CGFloat topBarHeight = CGRectGetHeight(self.topToolbar.bounds);
        CGFloat cameraHeightFor3x4 = roundf(screenWidth*4/3);
        return CGRectMake(0, topBarHeight/cameraHeightFor3x4, 1, screenWidth/cameraHeightFor3x4);
    } else {
        return CGRectMake(0, 0, 1, 1);
    }
}

- (void)setShowGrid:(BOOL)showGrid {
    [self setShowGrid:showGrid animated:YES];
}

- (void)setShowGrid:(BOOL)showGrid animated:(BOOL)animated {
    _showGrid = showGrid;
    
    if (showGrid) {
        [self.showGridButton setImage:[UIImage imageNamed:@"camera_grid_enable"] forState:UIControlStateNormal];
    } else {
        [self.showGridButton setImage:[UIImage imageNamed:@"camera_grid_disable"] forState:UIControlStateNormal];
    }
    
    UIView * gridView = nil;
    if (self.cameraScale == DXPhotoScale1x1) {
        gridView = self.cameraGrid1x1View;
    } else {
        gridView = self.cameraGrid3x4View;
    }
    
    if (animated) {
        POPBasicAnimation * showAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        showAnimation.duration = 0.4;
        showAnimation.toValue = @(showGrid ? 1 : 0);
        [gridView pop_removeAllAnimations];
        [gridView pop_addAnimation:showAnimation forKey:@"gridView.alpha"];
    } else {
        gridView.alpha = showGrid ? 1 : 0;
    }
}


#pragma mark - Button Actions

- (IBAction)flashModeButtonTapped:(UIButton *)sender {
    AVCaptureFlashMode currentFlashMode = self.captureInput.device.flashMode;
    NSError * lockError = nil;
    if (self.captureInput.device) {
        if ([self.captureInput.device lockForConfiguration:&lockError]) {
            AVCaptureFlashMode nextFlashMode;
            switch (currentFlashMode) {
                case AVCaptureFlashModeAuto:
                    nextFlashMode = AVCaptureFlashModeOn;
                    break;
                case AVCaptureFlashModeOn:
                    nextFlashMode = AVCaptureFlashModeOff;
                    break;
                default:
                    nextFlashMode = AVCaptureFlashModeAuto;
                    break;
            }
            [self.captureInput.device setFlashMode:nextFlashMode];
            [self.captureInput.device unlockForConfiguration];
            
            [self setFlashMode:nextFlashMode];
        } else {
            NSLog(@"尝试锁定摄像设备失败，原因: %@", lockError.localizedDescription);
        }
    } else {
        NSLog(@"未找到可用拍照设备");
    }
}

- (IBAction)captureButtonTapped:(UIControl *)sender {
    if (!self.isPhotoCapturing) {
        self.photoCapturing = YES;
        sender.enabled = NO;
        [self.cameraPreviewViewlayer connection].enabled = NO;
        
        __weak DXPhotoTakerViewController * weakSelf = self;
        __weak UIControl * weakSender = sender;
        
        [self capturePhoto:^(UIImage *photo, NSError *error) {
            if (photo) {
                if (weakSelf.allowPhotoAdjusting) {
                    DXPhotoEditorViewController * photoEditorVC = [[DXPhotoEditorViewController alloc] init];
                    photoEditorVC.photo = photo;
                    [weakSelf.navigationController pushViewController:photoEditorVC animated:YES];
                } else {
                    NSDictionary * userInfo = @{ @"photo" : photo };
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DXPublishUserDidFinishEditPhoto" object:self userInfo:userInfo];
                }
            }
            
            weakSelf.photoCapturing = NO;
            weakSender.enabled = YES;
            [weakSelf.cameraPreviewViewlayer connection].enabled = YES;
        }];
    }
    
}

- (IBAction)closeButtonTapped:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)albumPreviewTapped:(UIButton *)sender {
    [self showAlbum:YES];
}

- (IBAction)cameraScaleButtonTapped:(UIButton *)sender {
    DXPhotoScale nextScale;
    switch (self.cameraScale) {
        case DXPhotoScale1x1:
            if (self.imageOrientation == UIImageOrientationUp) {
                nextScale = DXPhotoScale3x4;
            } else {
                nextScale = DXPhotoScale4x3;
            }
            break;
        case DXPhotoScale3x4:
        case DXPhotoScale4x3:
        default:
            nextScale = DXPhotoScale1x1;
            break;
    }
    
    self.cameraScale = nextScale;
}

- (IBAction)showGridButtonTapped:(id)sender {
    self.showGrid = !self.showGrid;
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    @autoreleasepool {
        NSURL * photoAssetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        DXPhotoTakerController * photoTaker = (DXPhotoTakerController *)self.navigationController;
        DXPhotoCropperViewController * photoCropper = [[DXPhotoCropperViewController alloc] init];
        photoCropper.sourceType = DXPhotoCropperViewControllerSourceTypeAlbum;
        photoCropper.photoAssetURL = photoAssetURL;
        photoCropper.allowPhotoAdjusting = photoTaker.allowPhotoAdjusting;
        photoCropper.enableFixedPhotoScale = self.enableFixedPhotoScale;
        photoCropper.fixedPhotoScale = self.fixedPhotoScale;
        [picker pushViewController:photoCropper animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.mode == DXPhotoTakerModeAlbumOnly) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Camera

- (void)showAlbum:(BOOL)animated {
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = NO;
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePickerController.delegate = self;
    imagePickerController.dt_pageName = DXDataTrackingPage_CaptureAlbum;
    [self presentViewController:imagePickerController animated:animated completion:nil];
}

- (BOOL)loadCamera:(NSError **)error inView:(UIView *)view withFrame:(CGRect)frame flashMode:(AVCaptureFlashMode *)mode {
    _captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        [_captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    }

    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError * deviceError = nil;
    if (device) {
        if ([device lockForConfiguration:&deviceError]) {
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [device setFlashMode:AVCaptureFlashModeAuto];
            }
            [device unlockForConfiguration];
        } else {
            NSLog(@"尝试锁定摄像头失败，原因: %@", deviceError.localizedDescription);
        }
    } else {
        NSLog(@"未发现摄像头");
        return NO;
    }
        
    _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:error];
    if (_captureInput) {
        [_captureSession addInput:_captureInput];

        _captureImageOutput = [[AVCaptureStillImageOutput alloc] init];
        _captureImageOutput.outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG };
        [_captureSession addOutput:_captureImageOutput];
        
        if ([_captureImageOutput isStillImageStabilizationSupported]) {
            _captureImageOutput.automaticallyEnablesStillImageStabilizationWhenAvailable = YES;
        }
        
        for (AVCaptureConnection *connection in _captureImageOutput.connections) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                    _captureConnection = connection;
                    break;
                }
            }
        }
        
        if ([device hasFlash]) {
            *mode = device.flashMode;
        }
        
        _cameraPreviewViewlayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        _cameraPreviewViewlayer.frame = frame;
        _cameraPreviewViewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [view.layer addSublayer:_cameraPreviewViewlayer];
        
        [self.captureSession startRunning];
        
        return YES;
    } else {
        return NO;
    }
}

- (void)capturePhoto:(void(^)(UIImage *, NSError *))resultBlock {
    if (self.captureImageOutput && self.captureSession.isRunning) {
        
        __weak typeof(self) weakSelf = self;
        [self.captureImageOutput captureStillImageAsynchronouslyFromConnection:self.captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (CMSampleBufferIsValid(imageDataSampleBuffer)) {
                if (!error) {
                    @autoreleasepool {
                        NSData * photoData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                        CGRect photoAspectRect = [weakSelf.cameraPreviewViewlayer metadataOutputRectOfInterestForRect:weakSelf.cameraPreviewViewlayer.frame];
                        [weakSelf cropImageWithData:photoData inAspectRect:photoAspectRect result:^(UIImage *croppedImage) {
                            resultBlock(croppedImage, nil);
                        }];
                    }
                } else {
                    resultBlock(nil, error);
                }
            } else {
                resultBlock(nil, nil);
            }
        }];
    } else {
        resultBlock(nil, nil);
    }
}

- (void)cropImageWithData:(NSData *)imageData inAspectRect:(CGRect)aspectRect result:(void(^)(UIImage *))resultBlock {
    
    if (resultBlock == nil) {
        return;
    }
    
    if (imageData == nil) {
        resultBlock(nil);
        return;
    }
    
    dispatch_async(self.imageProcessQueue, ^{
        
        @autoreleasepool {
            UIImage * image = [UIImage imageWithData:imageData];
            
            CGImageRef imageRef = image.CGImage;
            size_t imageWidth = CGImageGetWidth(imageRef);
            size_t imageHeight = CGImageGetHeight(imageRef);
            
            size_t width = roundf(imageWidth * aspectRect.size.width);
            size_t height = roundf(imageHeight * aspectRect.size.height);
            size_t x = roundf(imageWidth * aspectRect.origin.x);
            size_t y = roundf(imageHeight * aspectRect.origin.y);
            CGRect cropRect = CGRectMake(x, y, width, height);
            if (self.cameraScale == DXPhotoScale1x1) {
                CGRect visibleRect = [self getCameraVisibleRectInScale];
                CGFloat realWidth = 0;
                CGFloat realHeight = 0;
                if ((image.size.height >= image.size.width) && (height >= width)) {
                    realWidth = cropRect.size.width;
                    realHeight = cropRect.size.height;
                } else {
                    realWidth = cropRect.size.height;
                    realHeight = cropRect.size.width;
                }
                
                if (realWidth != width) {
                    cropRect.origin.y += roundf(visibleRect.origin.x * realWidth);
                    cropRect.origin.x += roundf(visibleRect.origin.y * realHeight);
                    cropRect.size.height = roundf(visibleRect.size.width * realWidth);
                    cropRect.size.width = roundf(visibleRect.size.height * realHeight);
                } else {
                    cropRect.origin.x += roundf(visibleRect.origin.x * realWidth);
                    cropRect.origin.y += roundf(visibleRect.origin.y * realHeight);
                    cropRect.size.width = roundf(visibleRect.size.width * realWidth);
                    cropRect.size.height = roundf(visibleRect.size.height * realHeight);
                }
            }
            
            CGImageRef cropedImageRef = CGImageCreateWithImageInRect(imageRef, cropRect);
            
            CGFloat scale = 1080.0 / MIN(width, height);
            CGImageRef scaledImageRef = [DXImageKit newScaledImageFromImage:cropedImageRef scale:scale];
            
            UIImageOrientation imageOrientation = self.imageOrientation;
            if (image.imageOrientation == UIImageOrientationRight) {
                switch (self.imageOrientation) {
                    case UIImageOrientationRight:
                        imageOrientation = UIImageOrientationUp;
                        break;
                    case UIImageOrientationLeft:
                        imageOrientation = UIImageOrientationDown;
                        break;
                    default:
                        imageOrientation = UIImageOrientationRight;
                        break;
                }
            }
            if (image.imageOrientation == UIImageOrientationLeft) {
                switch (self.imageOrientation) {
                    case UIImageOrientationRight:
                        imageOrientation = UIImageOrientationDown;
                        break;
                    case UIImageOrientationLeft:
                        imageOrientation = UIImageOrientationUp;
                        break;
                    default:
                        imageOrientation = UIImageOrientationLeft;
                        break;
                }
            }
            
            CGImageRef unrotatedImageRef = [DXImageKit newUnrotatedImageFromImage:scaledImageRef
                                                                  withOrientation:imageOrientation];
            UIImage * unrotatedImage = [UIImage imageWithCGImage:unrotatedImageRef
                                                           scale:[UIScreen mainScreen].scale
                                                     orientation:UIImageOrientationUp];
            CGImageRelease(unrotatedImageRef);
            CGImageRelease(cropedImageRef);
            CGImageRelease(scaledImageRef);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(unrotatedImage);
            });
        }

    });
}

/*
- (void)showLastAlbumPhotoInView:(UIButton *)albumPreviewView {
    
    ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                CGImageRef thumbnailRef = [result aspectRatioThumbnail];
                UIImage * lastPhotoThumnail = [UIImage imageWithCGImage:thumbnailRef];
                [albumPreviewView setImage:lastPhotoThumnail forState:UIControlStateNormal];
                *stop = YES;
            }
        }];
    } failureBlock:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"访问相册出错" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];

}
 */

- (void)playCameraOpenAnimation {
    CGRect bounds = self.cameraCoverView.bounds;
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = CGRectGetHeight(bounds);
    
    CGMutablePathRef pathBegin = CGPathCreateMutable();
    CGPoint startPoint = CGPointMake(0, height/2);
    CGPoint endPoint = CGPointMake(width, height/2);
    CGPoint cp = CGPointMake(width/2, height/2-1);
    CGPathMoveToPoint(pathBegin, nil, startPoint.x, startPoint.y);
    CGPathAddQuadCurveToPoint(pathBegin, nil, cp.x, cp.y, endPoint.x, endPoint.y);
    cp.y = height/2+1;
    CGPathAddQuadCurveToPoint(pathBegin, nil, cp.x, cp.y, startPoint.x, startPoint.y);
    CGPathCloseSubpath(pathBegin);
    CGPathAddRect(pathBegin, nil, bounds);
    
    CGMutablePathRef pathEnd = CGPathCreateMutable();
    startPoint = CGPointMake(-width/2, height/2);
    endPoint = CGPointMake(width+width/2, height/2);
    cp.x = width/2;
    cp.y = -height;
    CGPathMoveToPoint(pathEnd, nil, startPoint.x, startPoint.y);
    CGPathAddQuadCurveToPoint(pathEnd, nil, cp.x, cp.y, endPoint.x, endPoint.y);
    cp.y = height+height;
    CGPathAddQuadCurveToPoint(pathEnd, nil, cp.x, cp.y, startPoint.x, startPoint.y);
    CGPathCloseSubpath(pathEnd);
    CGPathAddRect(pathEnd, nil, bounds);
    
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.fillColor = [UIColor whiteColor].CGColor;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.path = pathBegin;
    self.cameraCoverView.layer.mask = maskLayer;

    CABasicAnimation * pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = 0.4f;
    pathAnimation.fromValue = (__bridge id)pathBegin;
    pathAnimation.toValue = (__bridge id)pathEnd;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    maskLayer.path = pathEnd;
    [maskLayer addAnimation:pathAnimation forKey:@"pathAnimation"];
    
    CGPathRelease(pathBegin);
    CGPathRelease(pathEnd);
}


#pragma mark - Core Motion

- (void)startAccelerometer {
    if (self.motionManager == nil) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = 0.5;
    }
    
    if (self.accelerometerQueue == nil) {
        self.accelerometerQueue = [[NSOperationQueue alloc] init];
    }
    
    typeof(self) __weak weakSelf = self;
    
    [self.motionManager startAccelerometerUpdatesToQueue:self.accelerometerQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        
        // 如果手机转入平放状态，不进行旋转
        if (ABS(accelerometerData.acceleration.z) < 0.9) {
            // 计算左右倾斜角度，小于0为向左倾斜，反之为向右倾斜
            UIImageOrientation orientation = UIImageOrientationUp;
            double radian = atan(accelerometerData.acceleration.x / accelerometerData.acceleration.y);
            int angle = ABS(radian * 180 * M_1_PI);
            angle = accelerometerData.acceleration.x < 0 ? -angle : angle;
            // 当左右倾斜角度大于60度时才进行旋转
            if (ABS(angle) > 45) {
                if (angle > 0) {
                    orientation = UIImageOrientationLeft;
                } else {
                    orientation = UIImageOrientationRight;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf rotateUIByImageOrientation:orientation];
            });
        }
    }];
}

- (void)stopAccelerometer {
    [self.motionManager stopAccelerometerUpdates];
}


#pragma mark - Notifications

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)unregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)noti {
    [self startAccelerometer];
    // 解决应用进入到后台时动画会中止的问题
    [self rotateUIByImageOrientation:self.imageOrientation forceUpdate:YES];
}

- (void)applicationDidEnterBackground:(NSNotification *)noti {
    [self stopAccelerometer];
}


@end
