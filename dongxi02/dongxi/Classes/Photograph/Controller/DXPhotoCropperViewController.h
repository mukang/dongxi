//
//  DXPhotoCropperViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXPhotoDefinitions.h"

typedef enum : NSUInteger {
    DXPhotoCropperViewControllerSourceTypeCamera,
    DXPhotoCropperViewControllerSourceTypeAlbum
} DXPhotoCropperViewControllerSourceType;


@interface DXPhotoCropperViewController : UIViewController

@property (nonatomic, strong) UIImage * originPhoto;
@property (nonatomic, assign) BOOL allowPhotoAdjusting;

@property (nonatomic, assign) DXPhotoCropperViewControllerSourceType sourceType;
@property (nonatomic, strong) NSURL * photoAssetURL;

@property (nonatomic, assign) BOOL enableFixedPhotoScale;
@property (nonatomic, assign) DXPhotoScale fixedPhotoScale;

@end
