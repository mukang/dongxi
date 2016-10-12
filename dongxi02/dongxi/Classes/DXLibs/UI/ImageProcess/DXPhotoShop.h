//
//  DXPhotoShop.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

@class CIImage;

#import "DXPhotoShopLayer.h"

@protocol DXPhotoShopDelegate;


typedef enum : NSUInteger {
    DXPhotoShopTiltShiftNone = 0,
    DXPhotoShopTiltShiftLinear,
    DXPhotoShopTiltShiftRadial,
} DXPhotoShopTiltShiftMode;


@interface DXPhotoShop : NSObject

/*------------ 照片效果 ------------*/
@property (nonatomic, readonly) NSArray * effectDisplayNames;
@property (nonatomic, readonly) NSArray * effectPreviews;
@property (nonatomic, assign) CGSize effectPreviewSize;
@property (nonatomic, assign) NSInteger selectedEffectIndex;
/*------------ 照片调节 ------------*/
@property (nonatomic, assign) CGFloat brightness;
@property (nonatomic, assign) CGFloat temperature;
@property (nonatomic, assign) CGFloat vignettingEffect;
/*------------ 移轴模式 ------------*/
@property (nonatomic, assign) DXPhotoShopTiltShiftMode tiltShiftMode;
@property (nonatomic, assign) CGFloat tiltShiftRange;
@property (nonatomic, assign) CGPoint tiltShiftCenter;
@property (nonatomic, assign) BOOL showTiltIndicator;
/*------------ 照片预览 ------------*/
@property (nonatomic, readonly) GLKView * previewView;

@property (nonatomic, strong) UIImage * inputImage;
@property (nonatomic, readonly) UIImage * outputImage;
@property (nonatomic, weak) id<DXPhotoShopDelegate> delegate;

- (void)saveState;
- (void)restoreState;
- (void)releaseResources;

- (void)displayPreview;

@end



@protocol DXPhotoShopDelegate <NSObject>

@optional
- (void)effectPreviewNeedsRefreshInPhotoshop:(DXPhotoShop *)photoShop;

@end
