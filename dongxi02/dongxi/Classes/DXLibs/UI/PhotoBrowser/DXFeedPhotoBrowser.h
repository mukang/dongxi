//
//  DXFeedPhotoBrowser.h
//  dongxi
//
//  Created by 穆康 on 16/3/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXFeedPhoto.h"

@class DXFeedPhotoBrowser;

@protocol DXFeedPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(DXFeedPhotoBrowser *)photoBrowser;
- (id <DXFeedPhoto>)photoBrowser:(DXFeedPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (id <DXFeedPhoto>)photoBrowser:(DXFeedPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(DXFeedPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(DXFeedPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(DXFeedPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;

@end

@interface DXFeedPhotoBrowser : UIView

@property (nonatomic, weak) id<DXFeedPhotoBrowserDelegate> delegate;

@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic) CGRect sourceImageViewFrame;
@property (nonatomic, weak) UIView *sourceImageContainerView;

@property (nonatomic, assign) BOOL zoomPhotosToFill;
@property (nonatomic, readonly) NSUInteger currentIndex;

- (void)show;

// Init
- (instancetype)initWithPhotos:(NSArray *)photosArray;
- (instancetype)initWithDelegate:(id <DXFeedPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

@end
