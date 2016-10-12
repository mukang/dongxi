//
//  DXPhotoTakerController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXPhotoDefinitions.h"

@protocol DXPhotoTakerControllerDelegate;

typedef enum : NSInteger {
    DXPhotoTakerModeCameraAndAlbum = 0,
    DXPhotoTakerModeCameraOnly,
    DXPhotoTakerModeAlbumOnly,
} DXPhotoTakerMode;



@interface DXPhotoTakerController : UINavigationController

@property (nonatomic, weak) id <DXPhotoTakerControllerDelegate, UINavigationControllerDelegate> delegate;
@property (nonatomic, assign) BOOL allowPhotoAdjusting;
@property (nonatomic, assign) DXPhotoTakerMode mode;

@property (nonatomic, assign) BOOL enableFixedPhotoScale;
@property (nonatomic, assign) DXPhotoScale fixedPhotoScale;

@property (nonatomic, readonly, strong) NSString * topicID;
@property (nonatomic, readonly, strong) NSString * topicTitle;

@end


@protocol DXPhotoTakerControllerDelegate <NSObject>

@optional
- (void)photoTaker:(DXPhotoTakerController *)photoTaker didFinishPhoto:(UIImage *)photo;

@end