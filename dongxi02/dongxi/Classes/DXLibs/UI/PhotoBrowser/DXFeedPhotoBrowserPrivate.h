//
//  DXFeedPhotoBrowserPrivate.h
//  dongxi
//
//  Created by 穆康 on 16/3/2.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "DXFeedZoomingScrollView.h"
#import "DXFeedPhoto.h"

@interface DXFeedPhotoBrowser () {
    
    // Data
    NSUInteger _photoCount;
    NSMutableArray *_photos;
    NSMutableArray *_thumbPhotos;
    NSArray *_fixedPhotosArray; // Provided via init
    
    // Views
    UIScrollView *_pagingScrollView;
    /** 过渡动画视图 */
    UIImageView *_transitionImageView;
    /** 照片容器视图 */
    UIView *_photoContainerView;
    UIPageControl *_pageControl;
    
    // Paging & layout
    NSMutableSet *_visiblePages, *_recycledPages;
    NSUInteger _currentPageIndex;
    NSUInteger _previousPageIndex;
    CGRect _previousLayoutBounds;
    
    // Misc
    BOOL _performingLayout;
    BOOL _viewIsActive;
    NSUInteger _beginPhotoIndex;
    CGRect _beginTransitionFrame;
}

// Layout
- (void)layoutVisiblePages;
- (void)performLayout;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (DXFeedZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (DXFeedZoomingScrollView *)pageDisplayingPhoto:(id<DXFeedPhoto>)photo;
- (DXFeedZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(DXFeedZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;

// Data
- (NSUInteger)numberOfPhotos;
- (id<DXFeedPhoto>)photoAtIndex:(NSUInteger)index;
- (id<DXFeedPhoto>)thumbPhotoAtIndex:(NSUInteger)index;
- (UIImage *)imageForPhoto:(id<DXFeedPhoto>)photo;
- (void)loadAdjacentPhotosIfNecessary:(id<DXFeedPhoto>)photo;
- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent;

// Dismiss
- (void)toggleDismiss;

@end