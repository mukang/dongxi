//
//  DXPhotoTakerViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXPhotoTakerController.h"
#import "DXPhotoDefinitions.h"


@interface DXPhotoTakerViewController : UIViewController

@property (nonatomic, assign) DXPhotoTakerMode mode;
@property (nonatomic, assign) BOOL allowPhotoAdjusting;
@property (nonatomic, assign) BOOL enableCameraOpenAnimation;

@property (nonatomic, assign) BOOL enableFixedPhotoScale;
@property (nonatomic, assign) DXPhotoScale fixedPhotoScale;

@end
