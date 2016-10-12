//
//  DXPhotoEditorViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//
#import <GLKit/GLKit.h>

#import "DXPhotoEditorViewController.h"
#import "DXPhotoTakerViewController.h"
#import "DXTabBarView.h"
#import "DXPublishPhotoFilterCell.h"
#import "DXPublishWatermarkCell.h"
#import "DXImageKit.h"
#import "DXImageWatermarkView.h"
#import "DXPhotoShop.h"
#import "DXPhotoToolPanel.h"
#import "DXPhotoFilterIntensityBar.h"
#import <pop/POP.h>
#import "DXWatermark.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>

#pragma mark - DXFilterCollectionViewLayout
#pragma mark -

/**
 *  DXFilterCollectionViewLayout
 *
 *  自定义CollectionView布局，单元格顶部对齐
 */
@interface DXFilterCollectionViewLayout : UICollectionViewFlowLayout

@end


@implementation DXFilterCollectionViewLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray * customLayoutAttributes = [NSMutableArray array];
    NSArray * layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes * att in layoutAttributes) {
        UICollectionViewLayoutAttributes * customAtt = [att copy];
        if (customAtt.representedElementCategory == UICollectionElementCategoryCell) {
            CGRect frame = customAtt.frame;
            frame.origin.y = 0;
            customAtt.frame = frame;
        }
        [customLayoutAttributes addObject:customAtt];
    }
    return [customLayoutAttributes copy];
}

@end



#pragma mark - DXPhotoEditorViewController
#pragma mark -



typedef enum : NSUInteger {
    DXPhotoEditorStateFilter                            = 0,
    DXPhotoEditorStateWatermark                         = 1,
    DXPhotoEditorStateMicroFilterList                   = 2,
    DXPhotoEditorStateMicroFilterBrightness             = 3,
    DXPhotoEditorStateMicroFilterColorTemperature       = 4,
    DXPhotoEditorStateMicroFilterVignetting             = 5,
    DXPhotoEditorStateTiltShiftNone                     = 6,
    DXPhotoEditorStateTiltShiftCircle                   = 7,
    DXPhotoEditorStateTiltShiftHorizonal                = 8
} DXPhotoEditorState;


/**
 *  DXPhotoEditorViewController
 *
 *  照片编辑控制器
 */
@interface DXPhotoEditorViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DXTabBarViewDelegate, DXPhotoToolPanelDelegate, DXPhotoFilterIntensityBarDelegate, DXPhotoShopDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView * photoPreviewView;
@property (nonatomic, strong) UIView * watermarkPreviewView;
@property (nonatomic, strong) UILabel * filterNameLabel;
@property (nonatomic, strong) DXTabBarView * tabBarView;
@property (nonatomic, strong) UIView * functionsContainer;
@property (nonatomic, strong) UIToolbar * bottomToolbar;

@property (nonatomic, strong) UICollectionView * filterCollectionView;
@property (nonatomic, strong) UICollectionView * watermarkCollectionView;
@property (nonatomic, strong) DXPhotoToolPanel * toolPanel;
@property (nonatomic, strong) DXPhotoToolPanel * tiltShiftPanel;
@property (nonatomic, strong) UIPinchGestureRecognizer * tiltShiftPinchGesture;
@property (nonatomic, strong) UIPanGestureRecognizer * tiltShiftPanGesture;
@property (nonatomic, strong) DXPhotoFilterIntensityBar * intensityBar;
@property (nonatomic, assign) CGSize cachedFilterCellSize;

@property (nonatomic, strong) UIBarButtonItem * commitButtonItem;
@property (nonatomic, strong) UIBarButtonItem * cancelButtonItem;

@property (nonatomic, strong) UIBarButtonItem * previousStepItem;
@property (nonatomic, strong) UIBarButtonItem * flexibleSpaceItem;
@property (nonatomic, strong) UIBarButtonItem * nextStepItem;

@property (nonatomic, assign) NSUInteger selectedWatermarkIndex;
@property (nonatomic, strong) DXImageWatermarkView * selectedWatermarkView;

@property (nonatomic, strong) NSArray * filterNames;
@property (nonatomic, assign) CGSize thumbnailSize;
@property (nonatomic, strong) NSArray * filteredThumbnails;
@property (nonatomic, assign) BOOL filterLoaded;

@property (nonatomic, strong) NSMutableArray * watermarks;

@property (nonatomic, assign) DXPhotoEditorState editorState;

@property (nonatomic, strong) DXPhotoShop * photoShop;

@property (nonatomic, strong) DXScreenNotice * screenNotice;


- (void)loadWatermarks;
- (CGRect)frameForWatermark:(UIImage *)watermarkImage config:(DXWatermark *)config andSuperView:(UIView *)superView;

@end

@implementation DXPhotoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dt_pageName = DXDataTrackingPage_CaptureEdit;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.thumbnailSize = CGSizeMake(DXRealValue(310.0/3), DXRealValue(310.0/3));
    self.photoShop = [[DXPhotoShop alloc] init];
    self.photoShop.effectPreviewSize = self.thumbnailSize;
    self.photoShop.delegate = self;
    
    [self setupSubviews];

    [self.bottomToolbar setItems:@[
                                   self.previousStepItem,
                                   self.flexibleSpaceItem,
                                   self.nextStepItem
                                   ]];
    
    [self.filterCollectionView registerClass:[DXPublishPhotoFilterCell class] forCellWithReuseIdentifier:@"DXPublishPhotoFilterCell"];
    self.filterCollectionView.delegate = self;
    self.filterCollectionView.dataSource = self;
    
    [self.watermarkCollectionView registerClass:[DXPublishWatermarkCell class] forCellWithReuseIdentifier:@"DXPublishWatermarkCell"];
    self.watermarkCollectionView.delegate = self;
    self.watermarkCollectionView.dataSource = self;
    
    self.photoShop.inputImage = self.photo;
    
    self.tabBarView.delegate = self;
    
    [self loadWatermarks];
    [self.watermarkCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    
    self.screenNotice = [[DXScreenNotice alloc] initWithMessage:@"加载滤镜中" fromController:self];
    [self.screenNotice setDisableAutoDismissed:YES];
    [self.screenNotice show];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.filterLoaded == NO) {
        self.filterNames = self.photoShop.effectDisplayNames;
        
        NSMutableArray * sampleImages = [NSMutableArray array];
        NSArray * sampleImageNames = @[@"filter_0",
                                       @"filter_1",
                                       @"filter_2",
                                       @"filter_3",
                                       @"filter_4",
                                       @"filter_5",
                                       @"filter_6",
                                       @"filter_7",
                                       @"filter_8",
                                       ];
        for (NSString * imageName in sampleImageNames) {
            UIImage * sampleImage = nil;
            NSString * path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@3x", imageName] ofType:@"png"];
            if (path) {
                sampleImage = [UIImage imageWithContentsOfFile:path];
            } else {
                sampleImage = [UIImage imageNamed:imageName];
            }
            
            if (sampleImage) {
                [sampleImages addObject:sampleImage];
            }
        }
        
        self.filteredThumbnails = sampleImages;
        self.filterLoaded = YES;
        
        [self.photoShop displayPreview];
        [self.filterCollectionView reloadData];
        if (self.filteredThumbnails.count > 0) {
            [self.filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
        [self.screenNotice dismiss:NO];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)setupSubviews {
    _photoPreviewView = self.photoShop.previewView;
    [_photoPreviewView setFrame:CGRectMake(0, 0, DXScreenWidth, DXScreenWidth)];
    _photoPreviewView.backgroundColor = DXRGBColor(72, 72, 72);
    _photoPreviewView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat photoWidth = self.photo.size.width;
    CGFloat photoHeight = self.photo.size.height;
    CGFloat photoScale = photoWidth / photoHeight;
    CGSize previewSize = CGSizeMake(DXScreenWidth, DXScreenWidth);
    CGFloat previewX = 0, previewY = 0, previewWidth, previewHeight;
    if (photoScale >= 1) {
        previewWidth = previewSize.width;
        previewHeight = previewSize.width / photoScale;
        previewY = (previewSize.height - previewHeight) / 2;
    } else {
        previewWidth = previewSize.height * photoScale;
        previewHeight = previewSize.height;
        previewX = (previewSize.width - previewWidth) / 2;
    }
    _watermarkPreviewView = [[UIView alloc] initWithFrame:CGRectMake(previewX, previewY, previewWidth, previewHeight)];
    _watermarkPreviewView.clipsToBounds = NO;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnWatermarkHolder:)];
    [_watermarkPreviewView setUserInteractionEnabled:YES];
    [_watermarkPreviewView addGestureRecognizer:tapGesture];
    
    _tiltShiftPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleTiltShiftPinchGesture:)];
    _tiltShiftPinchGesture.delegate = self;
    _tiltShiftPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTiltShiftPanGesture:)];
    _tiltShiftPanGesture.delegate = self;
    
    _filterNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _filterNameLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
    _filterNameLabel.font = [DXFont dxDefaultFontWithSize:121.0/3];
    _filterNameLabel.hidden = YES;
    
    _selectedWatermarkView = [[DXImageWatermarkView alloc] initWithFrame:CGRectZero];
    _selectedWatermarkView.minScale = 0.2;
    _selectedWatermarkView.maxScale = 1;
    _selectedWatermarkView.hidden = YES;
    UIGestureRecognizer * tappGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnWatermark:)];
    [_selectedWatermarkView addGestureRecognizer:tappGesture];
    
    CGFloat tabBarHeight = DXScreenHeight > 480 ? DXRealValue(176.0/3) : DXRealValue(50);
    _tabBarView = [[DXTabBarView alloc] initWithFrame:CGRectMake(0, DXScreenWidth, DXScreenWidth, tabBarHeight) tabCount:3 names:@[@"滤镜", @"水印", @"调整"]];
    _tabBarView.backgroundColor = [UIColor whiteColor];
    _tabBarView.contentInsets = UIEdgeInsetsMake(0, DXRealValue(182.0/3), 0, DXRealValue(182.0/3));
    _tabBarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView * tabBarTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, 0.5)];
    tabBarTopBorder.backgroundColor = DXRGBColor(222, 222, 222);
    tabBarTopBorder.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [_tabBarView addSubview:tabBarTopBorder];
    
    _functionsContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _functionsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    _bottomToolbar = [[UIToolbar alloc] init];
    _bottomToolbar.translucent = NO;
    _bottomToolbar.clipsToBounds = YES;
    _bottomToolbar.translatesAutoresizingMaskIntoConstraints = NO;

    DXFilterCollectionViewLayout * filterLayout = [[DXFilterCollectionViewLayout alloc] init];
    filterLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:filterLayout];
    _filterCollectionView.backgroundColor = [UIColor whiteColor];
    _filterCollectionView.alwaysBounceHorizontal = YES;
    _filterCollectionView.showsHorizontalScrollIndicator = NO;
    _filterCollectionView.showsVerticalScrollIndicator = NO;
    _filterCollectionView.clipsToBounds =  NO;
    _filterCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    DXFilterCollectionViewLayout * watermarkLayout = [[DXFilterCollectionViewLayout alloc] init];
    watermarkLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _watermarkCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:watermarkLayout];
    _watermarkCollectionView.backgroundColor = [UIColor whiteColor];
    _watermarkCollectionView.alwaysBounceHorizontal = YES;
    _watermarkCollectionView.showsHorizontalScrollIndicator = NO;
    _watermarkCollectionView.showsVerticalScrollIndicator = NO;
    _watermarkCollectionView.clipsToBounds =  NO;
    _watermarkCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _watermarkCollectionView.hidden = YES;
    
    _toolPanel = [[DXPhotoToolPanel alloc] initWithFrame:CGRectZero];
    _toolPanel.delegate = self;
    _toolPanel.itemSpace = DXRealValue(40);
    _toolPanel.translatesAutoresizingMaskIntoConstraints = NO;
    _toolPanel.hidden = YES;
    [self setupItemsForPhotoFilterToolPanel:_toolPanel];
    
    _tiltShiftPanel = [[DXPhotoToolPanel alloc] initWithFrame:CGRectZero];
    _tiltShiftPanel.delegate = self;
    _tiltShiftPanel.itemSpace = DXRealValue(60);
    _tiltShiftPanel.translatesAutoresizingMaskIntoConstraints = NO;
    _tiltShiftPanel.hidden = YES;
    [self setupItemsForTiltShiftToolPanel:_tiltShiftPanel];
    
    _intensityBar = [[DXPhotoFilterIntensityBar alloc] init];
    _intensityBar.minValue = -100;
    _intensityBar.maxValue = 100;
    _intensityBar.delegate = self;
    _intensityBar.hidden = YES;
    _intensityBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_photoPreviewView];
    [_watermarkPreviewView addSubview:_selectedWatermarkView];
    [_watermarkPreviewView addSubview:_filterNameLabel];
    [self.view addSubview:_watermarkPreviewView];
    [self.view addSubview:_tabBarView];
    [_functionsContainer addSubview:_filterCollectionView];
    [_functionsContainer addSubview:_watermarkCollectionView];
    [_functionsContainer addSubview:_toolPanel];
    [_functionsContainer addSubview:_intensityBar];
    [_functionsContainer addSubview:_tiltShiftPanel];
    [self.view addSubview:_functionsContainer];
    [self.view addSubview:_bottomToolbar];
    
    UIButton * previousStepButton = [[UIButton alloc] init];
    previousStepButton.titleLabel.font = [DXFont dxDefaultFontWithSize:50.0/3];
    [previousStepButton setTitle:@"上一步" forState:UIControlStateNormal];
    [previousStepButton setTitleColor:DXRGBColor(143, 143, 143) forState:UIControlStateNormal];
    [previousStepButton setTitleColor:DXRGBColor(48, 48, 48) forState:UIControlStateHighlighted];
    [previousStepButton addTarget:self action:@selector(previousStepButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [previousStepButton sizeToFit];
    
    UIButton * nextStepButton = [[UIButton alloc] init];
    nextStepButton.titleLabel.font = [DXFont dxDefaultFontWithSize:50.0/3];
    [nextStepButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextStepButton setTitleColor:DXRGBColor(109, 197, 255) forState:UIControlStateNormal];
    [nextStepButton setTitleColor:DXRGBColor(55, 94, 126) forState:UIControlStateHighlighted];
    [nextStepButton addTarget:self action:@selector(nextStepButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [nextStepButton sizeToFit];
    
    _flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _previousStepItem = [[UIBarButtonItem alloc] initWithCustomView:previousStepButton];
    _nextStepItem = [[UIBarButtonItem alloc] initWithCustomView:nextStepButton];
    
    CGFloat screenHeight = DXScreenHeight;
    CGFloat filterTopMargin = screenHeight > 480 ? DXRealValue(85) : tabBarHeight + 5;
    CGFloat watermarkTopMargin = screenHeight > 480 ? DXRealValue(85) : tabBarHeight + 5;
    CGFloat toolPanelTopMargin = screenHeight > 480 ? DXRealValue(85 + 25) : tabBarHeight + 5;
    
    NSDictionary * views = @{
                             @"photoPreviewView"        : _photoPreviewView,
                             @"tabBarView"              : _tabBarView,
                             @"functionsContainer"      : _functionsContainer,
                             @"bottomToolbar"           : _bottomToolbar,
                             @"filterCollectionView"    : _filterCollectionView,
                             @"watermarkCollectionView" : _watermarkCollectionView,
                             @"photoToolPanel"          : _toolPanel,
                             @"intensityBar"            : _intensityBar,
                             @"tiltShiftPanel"          : _tiltShiftPanel
                             };
    NSDictionary * metrics = @{
                               @"photoPreviewHeight"    : @(DXScreenWidth),
                               @"tabBarHeight"          : @(tabBarHeight),
                               @"bottomToolBarHeight"   : @(DXRealValue(150.0/3)),
                               @"filterTopMargin"       : @(filterTopMargin),
                               @"watermarkTopMargin"    : @(watermarkTopMargin),
                               @"toolPanelTopMargin"    : @(toolPanelTopMargin),
                               @"toolPanelHeight"       : @(DXRealValue(85))
                               };
    
    NSArray * visualFormats = @[
                                @"H:|[photoPreviewView]|",
                                @"H:|[tabBarView]|",
                                @"H:|[functionsContainer]|",
                                @"H:|[filterCollectionView]|",
                                @"H:|[watermarkCollectionView]|",
                                @"H:|[photoToolPanel]|",
                                @"H:|[tiltShiftPanel]|",
                                @"H:|[bottomToolbar]|",
                                @"V:|[photoPreviewView(==photoPreviewHeight)][tabBarView(==tabBarHeight)][functionsContainer][bottomToolbar(==bottomToolBarHeight)]|",
                                @"V:[photoPreviewView]-filterTopMargin-[filterCollectionView]|",
                                @"V:[photoPreviewView]-watermarkTopMargin-[watermarkCollectionView]|",
                                @"V:[photoPreviewView]-toolPanelTopMargin-[photoToolPanel(==toolPanelHeight)]",
                                @"V:[photoPreviewView]-toolPanelTopMargin-[intensityBar]",
                                @"V:[photoPreviewView]-toolPanelTopMargin-[tiltShiftPanel(==toolPanelHeight)]"
                                ];
    
    for (NSString * vf in visualFormats) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views]];
    }
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_intensityBar
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_functionsContainer
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)enterFilterEdit:(BOOL)enter {
    if (enter) {
        self.tabBarView.userInteractionEnabled = NO;
        self.intensityBar.hidden = NO;
        [self.bottomToolbar setItems:@[
                                       self.cancelButtonItem,
                                       self.flexibleSpaceItem,
                                       self.commitButtonItem
                                       ]];
    } else {
        self.tabBarView.userInteractionEnabled = YES;
        self.intensityBar.hidden = YES;
        [self.intensityBar revert];
        [self.bottomToolbar setItems:@[
                                       self.previousStepItem,
                                       self.flexibleSpaceItem,
                                       self.nextStepItem
                                       ]];
        
        if (self.photoShop.brightness != 0) {
            [self.toolPanel selectItemAtIndex:0];
        }
        
        if (self.photoShop.temperature != 0) {
            [self.toolPanel selectItemAtIndex:1];
        }
        
        if (self.photoShop.vignettingEffect != 0) {
            [self.toolPanel selectItemAtIndex:2];
        }
        
        if (self.photoShop.tiltShiftMode != DXPhotoShopTiltShiftNone) {
            [self.toolPanel selectItemAtIndex:3];
        }
    }
}

- (void)enterTiltShiftPanel:(BOOL)enter {
    if (enter) {
        self.selectedWatermarkView.hideBorderAndButton = YES;
        self.selectedWatermarkView.userInteractionEnabled = NO;
        [self.watermarkPreviewView addGestureRecognizer:self.tiltShiftPinchGesture];
        [self.watermarkPreviewView addGestureRecognizer:self.tiltShiftPanGesture];

        if (self.photoShop.tiltShiftMode == DXPhotoShopTiltShiftLinear) {
            [self.tiltShiftPanel selectItemAtIndex:2];
            [self photoToolPanel:self.tiltShiftPanel didSelectAtIndex:2];
        } else if (self.photoShop.tiltShiftMode == DXPhotoShopTiltShiftRadial) {
            [self.tiltShiftPanel selectItemAtIndex:1];
            [self photoToolPanel:self.tiltShiftPanel didSelectAtIndex:1];
        } else {
            [self.tiltShiftPanel selectItemAtIndex:0];
            [self photoToolPanel:self.tiltShiftPanel didSelectAtIndex:0];
        }

        self.tabBarView.userInteractionEnabled = NO;
        self.tiltShiftPanel.hidden = NO;
        [self.bottomToolbar setItems:@[
                                       self.cancelButtonItem,
                                       self.flexibleSpaceItem,
                                       self.commitButtonItem
                                       ]];
    } else {
        self.photoShop.showTiltIndicator = NO;
        self.selectedWatermarkView.userInteractionEnabled = YES;
        [self.watermarkPreviewView removeGestureRecognizer:self.tiltShiftPinchGesture];
        [self.watermarkPreviewView removeGestureRecognizer:self.tiltShiftPanGesture];

        self.tabBarView.userInteractionEnabled = YES;
        self.tiltShiftPanel.hidden = YES;
        [self.bottomToolbar setItems:@[
                                       self.previousStepItem,
                                       self.flexibleSpaceItem,
                                       self.nextStepItem
                                       ]];
        
    }
}

#pragma mark - Properties

- (UIBarButtonItem *)commitButtonItem {
    if (nil == _commitButtonItem) {
        UIButton * commitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, DXRealValue(170.0/3), DXRealValue(100.0/3))];
        [commitButton addTarget:self action:@selector(filterCommitTapped:) forControlEvents:UIControlEventTouchUpInside];
        [commitButton setImage:[UIImage imageNamed:@"photo_ok_level_2"] forState:UIControlStateNormal];
        _commitButtonItem = [[UIBarButtonItem alloc] initWithCustomView:commitButton];
    }
    return _commitButtonItem;
}

- (UIBarButtonItem *)cancelButtonItem {
    if (nil == _cancelButtonItem) {
        UIButton * cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, DXRealValue(70.0/3), DXRealValue(71.0/3))];
        [cancelButton addTarget:self action:@selector(filterCancelTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setImage:[UIImage imageNamed:@"photo_close_level_2"] forState:UIControlStateNormal];
        _cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    }
    return _cancelButtonItem;
}

- (NSMutableArray *)watermarks {
    if (nil == _watermarks) {
        _watermarks = [NSMutableArray array];
    }
    return _watermarks;
}


#pragma mark - Button Actions & Gesture

- (IBAction)previousStepButtonTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextStepButtonTapped:(UIButton *)sender {
    
    UIImage * photo = self.photoShop.outputImage;
    DXWatermark * watermark = nil;
    
    if (self.selectedWatermarkIndex > 0) {
        CGFloat scale = photo.size.width / CGRectGetWidth(self.watermarkPreviewView.frame);
        UIImage * selectedWatermark = nil;
        @autoreleasepool {
            watermark = [self.watermarks objectAtIndex:self.selectedWatermarkIndex-1];
            CGFloat initialScale = watermark.initial_scale;
            CGAffineTransform transform = self.selectedWatermarkView.transform;
            transform = CGAffineTransformScale(transform, initialScale*scale, initialScale*scale);
            selectedWatermark = [DXImageKit transformedImageFromImage:self.selectedWatermarkView.image transform:transform];
        }
        CGRect frame = self.selectedWatermarkView.frame;
        frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(scale, scale));
        photo = [DXImageKit drawWatermark:selectedWatermark withFrame:frame onImage:photo];
    }    

    NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:photo forKey:@"photo"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DXPublishUserDidFinishEditPhoto" object:self userInfo:userInfo];
}

- (void)tappedOnWatermark:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.selectedWatermarkView.hideBorderAndButton = !self.selectedWatermarkView.hideBorderAndButton;
    }
}

- (void)tappedOnWatermarkHolder:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.selectedWatermarkView.hideBorderAndButton = YES;
    }
}

- (void)filterCommitTapped:(UIButton *)sender {
    [self.photoShop saveState];
    
    self.editorState = DXPhotoEditorStateMicroFilterList;
    self.toolPanel.hidden = NO;
    [self enterFilterEdit:NO];
    [self enterTiltShiftPanel:NO];
}

- (void)filterCancelTapped:(UIButton *)sender {
    [self.photoShop restoreState];
    
    self.editorState = DXPhotoEditorStateMicroFilterList;
    self.toolPanel.hidden = NO;
    [self enterFilterEdit:NO];
    [self enterTiltShiftPanel:NO];
}

- (void)handleTiltShiftPinchGesture:(UIPinchGestureRecognizer *)gesture {
    if (self.editorState != DXPhotoEditorStateTiltShiftNone) {
        static CGFloat startShiftRange = 0;
        if (gesture.state == UIGestureRecognizerStateBegan) {
            startShiftRange = self.photoShop.tiltShiftRange;
        } else {
            CGFloat range = startShiftRange + (gesture.scale - 1);
            if (range <= 0) {
                range = 0;
            } else if (range > 1) {
                range = 1;
            }
            [self changeTiltShiftRange:range];
        }
    }
}

- (void)handleTiltShiftPanGesture:(UIPanGestureRecognizer *)gesture {
    if (self.editorState != DXPhotoEditorStateTiltShiftNone) {
        static CGPoint startCenter;
        if (gesture.state == UIGestureRecognizerStateBegan) {
            startCenter = self.photoShop.tiltShiftCenter;
        } else {
            CGPoint translation = [gesture translationInView:self.watermarkPreviewView];
            translation.x /= CGRectGetWidth(self.watermarkPreviewView.bounds);
            translation.y /= CGRectGetHeight(self.watermarkPreviewView.bounds);
            CGPoint center;
            center.x = startCenter.x + translation.x;
            center.y = startCenter.y + translation.y;
            self.photoShop.tiltShiftCenter = center;
        }
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.tiltShiftPanGesture && otherGestureRecognizer == self.tiltShiftPinchGesture) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.filterCollectionView) {
        return self.filteredThumbnails.count;
    } else if (collectionView == self.watermarkCollectionView) {
        return self.watermarks.count + 1;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = nil;
    
    if (collectionView == self.filterCollectionView) {
        DXPublishPhotoFilterCell * filterCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishPhotoFilterCell" forIndexPath:indexPath];
        
        filterCell.filterNameLabel.text = [self.filterNames objectAtIndex:indexPath.item];
        filterCell.previewImageView.image  = [self.filteredThumbnails objectAtIndex:indexPath.item];

        cell = filterCell;
    }
    
    if (collectionView == self.watermarkCollectionView) {
        DXPublishWatermarkCell * watermarkCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishWatermarkCell" forIndexPath:indexPath];
        if (indexPath.item == 0) {
            watermarkCell.previewImageView.image = [UIImage imageNamed:@"Watermark_Thumbnail_0"];
        } else {
            DXWatermark * watermark = [self.watermarks objectAtIndex:indexPath.item-1];
            if (watermark.sourceType == DXWatermarkSourceLocal) {
                watermarkCell.previewImageView.image = [UIImage imageNamed:watermark.thumbName];
            } else {
                [watermarkCell.previewImageView sd_setImageWithURL:watermark.thumbURLForCurrentScreen];
            }
            if (watermark.topic_id) {
                watermarkCell.showTopicMark = YES;
            } else {
                watermarkCell.showTopicMark = NO;
            }
        }
        cell = watermarkCell;
    }
    
    return cell;
}


#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat collectionViewHeight = CGRectGetHeight(collectionView.bounds);
    CGFloat cellWidth = DXRealValue(310.0/3) < collectionViewHeight - 20 ? DXRealValue(310.0/3) : collectionViewHeight - 20;
    
    if (collectionView == self.filterCollectionView) {
        if (CGSizeEqualToSize(self.cachedFilterCellSize, CGSizeZero)) {
            DXPublishPhotoFilterCell * cell = [[DXPublishPhotoFilterCell alloc] initWithFrame:CGRectMake(0, 0, cellWidth, 0)];
            cell.filterNameLabel.text = @"原图";
            self.cachedFilterCellSize = [cell systemLayoutSizeFittingSize:CGSizeMake(cellWidth, DXScreenHeight)];
        }
        
        return self.cachedFilterCellSize;
    } else if (collectionView == self.watermarkCollectionView) {
        return CGSizeMake(cellWidth, cellWidth);
    } else {
        return CGSizeZero;
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return DXRealValue(39./3);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return DXRealValue(39.0/3);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, DXRealValue(39.0/3), 0, DXRealValue(39.0/3));
}

-  (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if (collectionView == self.filterCollectionView) {
        NSString * filterName = [self.photoShop.effectDisplayNames objectAtIndex:indexPath.item];
        [self animatedShowFilterNameLabelWithName:filterName];
        if (indexPath.item != self.photoShop.selectedEffectIndex) {
            self.photoShop.selectedEffectIndex = indexPath.item;
        }
    }
    
    if (collectionView == self.watermarkCollectionView) {
        
        if (indexPath.item == 0) {
            self.selectedWatermarkView.hidden = YES;
            self.selectedWatermarkView.image = nil;
        } else {
            DXWatermark * watermark = [self.watermarks objectAtIndex:indexPath.item - 1];
            if (watermark.sourceType == DXWatermarkSourceLocal) {
                UIImage * watermarkImage = [UIImage imageNamed:watermark.imageName];
                self.selectedWatermarkView.image = watermarkImage;
                self.selectedWatermarkView.hidden = NO;
                self.selectedWatermarkView.frame = [self frameForWatermark:watermarkImage config:watermark andSuperView:self.watermarkPreviewView];
                self.selectedWatermarkView.initialScale = watermark.initial_scale;
                self.selectedWatermarkView.hideBorderAndButton = NO;
            } else {
                typeof(self) __weak weakSelf = self;
                
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
                hud.labelText = @"加载水印";
                [manager downloadImageWithURL:watermark.imageURLForCurrentScreen options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        hud.progress = receivedSize * 1.0 / expectedSize;
                    });
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (image) {
                        NSInteger scale = [UIScreen mainScreen].scale;
                        if (scale < 2) {
                            scale = 2;
                        }
                        UIImage * watermarkImage = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            hud.progress = 1;
                            [hud hide:YES];
                            weakSelf.selectedWatermarkView.hidden = NO;
                            weakSelf.selectedWatermarkView.image = watermarkImage;
                            weakSelf.selectedWatermarkView.frame = [weakSelf frameForWatermark:watermarkImage config:watermark andSuperView:weakSelf.watermarkPreviewView];
                            weakSelf.selectedWatermarkView.initialScale = watermark.initial_scale;
                            weakSelf.selectedWatermarkView.hideBorderAndButton = NO;
                        });
                    }
                }];
            }
            
            self.selectedWatermarkIndex = indexPath.item;
        }
    }
}

#pragma mark - Photo Filter

- (void)loadWatermarks  {
    typeof(self) __weak weakSelf = self;
    
    [[DXWatermarkManager sharedManager] loadWatermarks:^(NSArray *watermarks, DXWatermarkSourceType sourceType, NSError *error) {
        if (watermarks) {
            if (sourceType == DXWatermarkSourceServer) {
                NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, watermarks.count)];
                [weakSelf.watermarks insertObjects:watermarks atIndexes:indexSet];
            } else {
                [weakSelf.watermarks addObjectsFromArray:watermarks];
            }
            
            [weakSelf.watermarkCollectionView reloadData];
        }
    }];
}

- (CGRect)frameForWatermark:(UIImage *)watermarkImage config:(DXWatermark *)watermark andSuperView:(UIView *)superView {
    CGSize viewSize = superView.bounds.size;
    
    CGRect frame;
    
    CGFloat initialScale = watermark.initial_scale;
    CGPoint origin = CGPointZero;
    if ([watermark.origin count] == 2) {
        origin = CGPointMake([watermark.origin[0] floatValue], [watermark.origin[1] floatValue]);
    }
    origin.x *= viewSize.width;
    origin.y *= viewSize.height;
    frame.origin = origin;
    frame.size = CGSizeMake(watermarkImage.size.width * initialScale,
                            watermarkImage.size.height * initialScale);
    CGSize offset = CGSizeZero;
    if ([watermark.offset count] == 2) {
        offset = CGSizeMake([watermark.offset[0] floatValue], [watermark.offset[1] floatValue]);
    }
    frame.origin.x += offset.width * frame.size.width;
    frame.origin.y += offset.height * frame.size.height;
    
    return frame;
}

- (void)setupItemsForPhotoFilterToolPanel:(DXPhotoToolPanel *)panel {
    NSArray * images = @[
                         [UIImage imageNamed:@"icon_brightness_1"],
                         [UIImage imageNamed:@"icon_temperature_1"],
                         [UIImage imageNamed:@"icon_dark_1"],
                         [UIImage imageNamed:@"icon_Shift_1"]
                         ];
    NSArray * selectedImages = @[
                                 [UIImage imageNamed:@"icon_brightness_2"],
                                 [UIImage imageNamed:@"icon_temperature_2"],
                                 [UIImage imageNamed:@"icon_dark_2"],
                                 [UIImage imageNamed:@"icon_Shift_2"]
                                 ];
    NSArray * titles = @[
                         @"明度", @"色温", @"暗角", @"移轴"
                         ];
    
    for (int i = 0; i < images.count; i++) {
        UIImage * image = images[i];
        UIImage * selectedImage = selectedImages[i];
        NSString * title = titles[i];
        
        [panel addItemWithImage:image selectedImage:selectedImage title:title];
    }
}

- (void)setupItemsForTiltShiftToolPanel:(DXPhotoToolPanel *)panel {
    NSArray * images = @[
                         [UIImage imageNamed:@"icon_Shift_delete"],
                         [UIImage imageNamed:@"icon_Shift_Round_1"],
                         [UIImage imageNamed:@"icon_Shift_Strip_1"]
                         ];
    NSArray * selectedImages = @[
                                 [UIImage imageNamed:@"icon_Shift_delete_H"],
                                 [UIImage imageNamed:@"icon_Shift_Round_2"],
                                 [UIImage imageNamed:@"icon_Shift_Strip_2"]
                                 ];
    NSArray * titles = @[@"关闭", @"中心", @"平移" ];
    
    for (int i = 0; i < images.count; i++) {
        UIImage * image = images[i];
        UIImage * selectedImage = selectedImages[i];
        NSString * title = titles[i];
        
        [panel addItemWithImage:image selectedImage:selectedImage title:title];
    }
}

- (void)animatedShowFilterNameLabelWithName:(NSString *)filterName{
    self.filterNameLabel.text = filterName;
    [self.filterNameLabel sizeToFit];
    self.filterNameLabel.center = CGPointMake(DXScreenWidth/2, DXScreenWidth/2);
    
    self.filterNameLabel.hidden = NO;
    self.filterNameLabel.alpha = 1;
    [self.filterNameLabel pop_removeAllAnimations];
    POPBasicAnimation * animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    animation.fromValue = @(1);
    animation.beginTime = CACurrentMediaTime() + 0.5;
    animation.toValue = @(0);
    animation.duration = 0.7;

    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.filterNameLabel pop_addAnimation:animation forKey:nil];
}

- (void)changeTiltShiftRange:(CGFloat)range {
    self.photoShop.tiltShiftRange = range;
}

#pragma mark - <DXTabBarViewDelegate>

- (void)tabBarView:(DXTabBarView *)view didTapButtonAtIndex:(NSUInteger)index {
    if (index == 0) {
        self.filterCollectionView.hidden = NO;
        self.editorState = DXPhotoEditorStateFilter;
    } else {
        self.filterCollectionView.hidden = YES;
    }
    
    if (index == 1) {
        self.watermarkCollectionView.hidden = NO;
        self.selectedWatermarkView.hideBorderAndButton = NO;
        self.editorState = DXPhotoEditorStateWatermark;
    } else {
        self.watermarkCollectionView.hidden = YES;
    }
    
    if (index == 2) {
        self.toolPanel.hidden = NO;
        self.editorState = DXPhotoEditorStateMicroFilterList;
    } else {
        self.toolPanel.hidden = YES;
    }
}


#pragma mark - <DXPhotoToolPanelDelegate>

- (void)photoToolPanel:(DXPhotoToolPanel *)panel didSelectAtIndex:(NSInteger)index {
    if (panel == self.toolPanel) {
        [panel deselectItemAtIndex:index];
        
        if (index < panel.itemCount - 1) {
            switch (index) {
                case 0:
                    self.editorState = DXPhotoEditorStateMicroFilterBrightness;
                    self.intensityBar.minValue = -100;
                    self.intensityBar.maxValue = 100;
                    self.intensityBar.initialValue = 0;
                    self.intensityBar.value = [self valueFromFilterIntensityBarIntensity:self.photoShop.brightness];
                    break;
                case 1:
                    self.editorState = DXPhotoEditorStateMicroFilterColorTemperature;
                    self.intensityBar.minValue = -100;
                    self.intensityBar.maxValue = 100;
                    self.intensityBar.initialValue = 0;
                    self.intensityBar.value = [self valueFromFilterIntensityBarIntensity:self.photoShop.temperature];
                    break;
                case 2:
                    self.editorState = DXPhotoEditorStateMicroFilterVignetting;
                    self.intensityBar.minValue = 0;
                    self.intensityBar.maxValue = 100;
                    self.intensityBar.initialValue = 0;
                    self.intensityBar.value = [self valueFromFilterIntensityBarIntensity:self.photoShop.vignettingEffect];
                    break;
                default:
                    break;
            }
            [self enterFilterEdit:YES];
        } else {
            [self enterTiltShiftPanel:YES];
        }
        panel.hidden = YES;
    } else {
        if (index == 0) {
            self.editorState = DXPhotoEditorStateTiltShiftNone;
            self.photoShop.tiltShiftMode = DXPhotoShopTiltShiftNone;
            self.photoShop.showTiltIndicator = NO;
            [panel deselectItemAtIndex:1];
            [panel deselectItemAtIndex:2];
        } else if (index == 1) {
            self.editorState = DXPhotoEditorStateTiltShiftCircle;
            self.photoShop.tiltShiftMode = DXPhotoShopTiltShiftRadial;
            self.photoShop.showTiltIndicator = YES;
            [panel deselectItemAtIndex:0];
            [panel deselectItemAtIndex:2];
        } else {
            self.editorState = DXPhotoEditorStateTiltShiftHorizonal;
            self.photoShop.tiltShiftMode = DXPhotoShopTiltShiftLinear;
            self.photoShop.showTiltIndicator = YES;
            [panel deselectItemAtIndex:0];
            [panel deselectItemAtIndex:1];
        }
    }
}


#pragma mark - <DXPhotoFilterIntensityBarDelegate>

- (CGFloat)intensityFromFilterIntensityBarValue:(CGFloat)value {
    return (value - self.intensityBar.initialValue) / (self.intensityBar.maxValue - self.intensityBar.initialValue);
}

- (CGFloat)valueFromFilterIntensityBarIntensity:(CGFloat)intensity {
    return intensity * (self.intensityBar.maxValue - self.intensityBar.initialValue) + self.intensityBar.initialValue;
}

- (void)intensityBar:(DXPhotoFilterIntensityBar *)intensityBar didChangeValue:(CGFloat)value {
    CGFloat intensity  = [self intensityFromFilterIntensityBarValue:value];
    switch (self.editorState) {
        case DXPhotoEditorStateMicroFilterBrightness:
            self.photoShop.brightness = intensity;
            break;
        case DXPhotoEditorStateMicroFilterColorTemperature:
            self.photoShop.temperature = intensity;
            break;
        case DXPhotoEditorStateMicroFilterVignetting:
            self.photoShop.vignettingEffect = intensity;
            break;
        default:
            break;
    }
}

#pragma mark - <DXPhotoShopDelegate>

- (void)effectPreviewNeedsRefreshInPhotoshop:(DXPhotoShop *)photoShop {
//    self.filteredThumbnails = self.photoShop.effectPreviews;
//    [self.filterCollectionView reloadData];
//    
//    [self.filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.photoShop.selectedEffectIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

@end

