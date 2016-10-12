//
//  DXPhotoTakerController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPhotoTakerController.h"
#import "DXPhotoTakerViewController.h"


@interface DXPhotoTakerController ()

@property (nonatomic, weak) DXPhotoTakerViewController * photoTakerViewController;

@end

@implementation DXPhotoTakerController

@synthesize delegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _mode = DXPhotoTakerModeCameraAndAlbum;
        _allowPhotoAdjusting = YES;
        self.navigationBarHidden = YES;
        
        DXPhotoTakerViewController * photoTakerViewController = [[DXPhotoTakerViewController alloc] init];
        [self pushViewController:photoTakerViewController animated:NO];
        
        self.photoTakerViewController = photoTakerViewController;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidFinishEditPhoto:) name:@"DXPublishUserDidFinishEditPhoto" object:nil];
    }
    return self;
}

- (void)setMode:(DXPhotoTakerMode)mode {
    _mode = mode;
    
    self.photoTakerViewController.mode = mode;
}

- (void)setAllowPhotoAdjusting:(BOOL)allowPhotoAdjusting {
    _allowPhotoAdjusting = allowPhotoAdjusting;
    
    self.photoTakerViewController.allowPhotoAdjusting = allowPhotoAdjusting;
}

- (void)setEnableFixedPhotoScale:(BOOL)enableFixedPhotoScale {
    _enableFixedPhotoScale = enableFixedPhotoScale;
    
    self.photoTakerViewController.enableFixedPhotoScale = enableFixedPhotoScale;
}

- (void)setFixedPhotoScale:(DXPhotoScale)fixedPhotoScale {
    _fixedPhotoScale = fixedPhotoScale;
    
    self.photoTakerViewController.fixedPhotoScale = fixedPhotoScale;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    NSAssert(NO, @"不可以调用该方法，请直接调用init");
    return nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Finshi Photo Edit

- (void)userDidFinishEditPhoto:(NSNotification *)noti {
    UIImage * photo = [noti.userInfo objectForKey:@"photo"];
    if (photo) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoTaker:didFinishPhoto:)]) {
            [self.delegate photoTaker:self didFinishPhoto:photo];
        }
    }
}


@end
