//
//  DXFeedPhotoBrowser.m
//  dongxi
//
//  Created by 穆康 on 16/3/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import "DXFeedPhotoBrowser.h"
#import "DXFeedPhotoBrowserPrivate.h"
#import "DXFeedTransitionImageView.h"

#define PADDING                  10

@interface DXFeedPhotoBrowser () <UIScrollViewDelegate>

@end

@implementation DXFeedPhotoBrowser

#pragma mark - Init

- (instancetype)initWithDelegate:(id <DXFeedPhotoBrowserDelegate>)delegate {
    if ((self = [self initWithFrame:CGRectZero])) {
        _delegate = delegate;
    }
    return self;
}

- (instancetype)initWithPhotos:(NSArray *)photosArray {
    if ((self = [self initWithFrame:CGRectZero])) {
        _fixedPhotosArray = photosArray;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _initialisation];
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        [self _initialisation];
        [self setupSubviews];
    }
    return self;
}

- (void)_initialisation {
    
    _photoCount = NSNotFound;
    _previousLayoutBounds = CGRectZero;
    _currentPageIndex = 0;
    _previousPageIndex = NSUIntegerMax;
    _zoomPhotosToFill = YES;
    _performingLayout = NO; // Reset on view did appear
    _viewIsActive = NO;
    _visiblePages = [[NSMutableSet alloc] init];
    _recycledPages = [[NSMutableSet alloc] init];
    _photos = [[NSMutableArray alloc] init];
    _thumbPhotos = [[NSMutableArray alloc] init];
    
    // Listen for MWPhoto notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                 name:DXPHOTO_LOADING_DID_END_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

#pragma mark - 创建子控件

- (void)setupSubviews {
    
    // 照片容器视图
    _photoContainerView = [[UIView alloc] init];
    _photoContainerView.hidden = YES;
    [self addSubview:_photoContainerView];
    
    // Setup paging scrolling view
    _pagingScrollView = [[UIScrollView alloc] init];
    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor blackColor];
    [_photoContainerView addSubview:_pagingScrollView];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.hidesForSinglePage = YES;
    [_photoContainerView addSubview:_pageControl];
    
    // 过渡动画视图
    _transitionImageView = [[UIImageView alloc] init];
    _transitionImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_transitionImageView];
}

#pragma mark - show and dismiss

// 展示view
- (void)show {
    
//    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
//    keyWindow.windowLevel = UIWindowLevelStatusBar + 1;
    
    UIWindow *containerWindow = self.sourceImageContainerView.window;
//    containerWindow.windowLevel = UIWindowLevelStatusBar + 1;
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
    self.frame = containerWindow.bounds;
    [containerWindow addSubview:self];
    _viewIsActive = YES;
    
    _photoContainerView.frame = self.bounds;
    _pagingScrollView.frame = [self frameForPagingScrollView];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    _pageControl.numberOfPages = [self numberOfPhotos];
    _pageControl.currentPage = _beginPhotoIndex;
    _pageControl.size = [_pageControl sizeForNumberOfPages:[self numberOfPhotos]];
    _pageControl.centerX = _photoContainerView.width * 0.5;
    _pageControl.y = _photoContainerView.height - 20 - _pageControl.height;
    
    // Update
    [self reloadData];
    
    [self performToShow];
    
    containerWindow.hidden = NO;
}

/**
 *  执行显示
 */
- (void)performToShow {
    
    CGRect rect = [self.sourceImageContainerView convertRect:self.sourceImageViewFrame toView:self];
    _transitionImageView.image = self.sourceImage;
    _transitionImageView.frame = rect;
    
    CGFloat transitionImageW = _transitionImageView.image.size.width;
    CGFloat transitionImageH = _transitionImageView.image.size.height;
    CGFloat targetH = DXScreenWidth / transitionImageW * transitionImageH;
    CGRect targetFrame = CGRectZero;
    if (targetH <= DXScreenHeight) {
        targetFrame = CGRectMake(0, (DXScreenHeight - targetH) * 0.5, DXScreenWidth, targetH);
    } else {
        targetFrame = CGRectMake(0, 0, DXScreenWidth, targetH);
    }
    
    _beginTransitionFrame = rect;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.4 delay:0.05 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _transitionImageView.frame = targetFrame;
    } completion:^(BOOL finished) {
        _photoContainerView.hidden = NO;
        _transitionImageView.hidden = YES;
    }];
    
    [UIView animateWithDuration:0.3 delay:0.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    } completion:nil];
}

- (void)toggleDismiss {
    
    if (_currentPageIndex == _beginPhotoIndex) {
        [self dismiss];
    } else {
        [self jumpToPageAtIndex:_beginPhotoIndex animated:YES];
    }
}

- (void)dismiss {
    
    _transitionImageView.hidden = NO;
    _photoContainerView.hidden = YES;
    _viewIsActive = NO;
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.4 animations:^{
        _transitionImageView.frame = _beginTransitionFrame;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    }];
}

#pragma mark - 布局

- (void)performLayout {
    
    // Setup
    _performingLayout = YES;
    
    // Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    // Content offset
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
    _performingLayout = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutVisiblePages];
}

- (void)updatePageControl {
    
    _pageControl.currentPage = _currentPageIndex;
}

#pragma mark - 布局可见的页面

- (void)layoutVisiblePages {
    
    // Flag
    _performingLayout = YES;
    
    // Remember index
    NSUInteger indexPriorToLayout = _currentPageIndex;
    
    // Recalculate contentSize based on current orientation
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // Adjust frames and configuration of each visible page
    for (DXFeedZoomingScrollView *page in _visiblePages) {
        NSUInteger index = page.index;
        page.frame = [self frameForPageAtIndex:index];
        
        // Adjust scales if bounds has changed since last time
        if (!CGRectEqualToRect(_previousLayoutBounds, self.bounds)) {
            // Update zooms for new bounds
            [page setMaxMinZoomScalesForCurrentBounds];
            _previousLayoutBounds = self.bounds;
        }
        
    }
    
    // Adjust contentOffset to preserve page location based on values collected prior to location
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
    [self didStartViewingPageAtIndex:_currentPageIndex]; // initial
    
    // Reset
    _currentPageIndex = indexPriorToLayout;
    _performingLayout = NO;
}

#pragma mark - Data

- (NSUInteger)currentIndex {
    return _currentPageIndex;
}

- (void)reloadData {
    
    // Reset
    _photoCount = NSNotFound;
    
    // Get data
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    [self releaseAllUnderlyingPhotos:YES];
    [_photos removeAllObjects];
    [_thumbPhotos removeAllObjects];
    for (int i = 0; i < numberOfPhotos; i++) {
        [_photos addObject:[NSNull null]];
        [_thumbPhotos addObject:[NSNull null]];
    }
    
    // Update current page index
    if (numberOfPhotos > 0) {
        _currentPageIndex = MAX(0, MIN(_currentPageIndex, numberOfPhotos - 1));
    } else {
        _currentPageIndex = 0;
    }
    
    if (_viewIsActive) {
        while (_pagingScrollView.subviews.count) {
            [[_pagingScrollView.subviews lastObject] removeFromSuperview];
        }
        [self performLayout];
        [self setNeedsLayout];
    }
}

- (NSUInteger)numberOfPhotos {
    if (_photoCount == NSNotFound) {
        if ([_delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]) {
            _photoCount = [_delegate numberOfPhotosInPhotoBrowser:self];
        } else if (_fixedPhotosArray) {
            _photoCount = _fixedPhotosArray.count;
        }
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}

- (id<DXFeedPhoto>)photoAtIndex:(NSUInteger)index {
    id <DXFeedPhoto> photo = nil;
    if (index < _photos.count) {
        if ([_photos objectAtIndex:index] == [NSNull null]) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
                photo = [_delegate photoBrowser:self photoAtIndex:index];
            } else if (_fixedPhotosArray && index < _fixedPhotosArray.count) {
                photo = [_fixedPhotosArray objectAtIndex:index];
            }
            if (photo) [_photos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_photos objectAtIndex:index];
        }
    }
    return photo;
}

- (id<DXFeedPhoto>)thumbPhotoAtIndex:(NSUInteger)index {
    id <DXFeedPhoto> photo = nil;
    if (index < _thumbPhotos.count) {
        if ([_thumbPhotos objectAtIndex:index] == [NSNull null]) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:thumbPhotoAtIndex:)]) {
                photo = [_delegate photoBrowser:self thumbPhotoAtIndex:index];
            }
            if (photo) [_thumbPhotos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_thumbPhotos objectAtIndex:index];
        }
    }
    return photo;
}

- (UIImage *)imageForPhoto:(id<DXFeedPhoto>)photo {
    if (photo) {
        // Get image or obtain in background
        if ([photo underlyingImage]) {
            return [photo underlyingImage];
        } else {
            [photo loadUnderlyingImageAndNotify];
        }
    }
    return nil;
}

- (void)loadAdjacentPhotosIfNecessary:(id<DXFeedPhoto>)photo {
    DXFeedZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        // If page is current page then initiate loading of previous and next pages
        NSUInteger pageIndex = page.index;
        if (_currentPageIndex == pageIndex) {
            if (pageIndex > 0) {
                // Preload index - 1
                id <DXFeedPhoto> photo = [self photoAtIndex:pageIndex-1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
//                    DXLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex-1);
                }
            }
            if (pageIndex < [self numberOfPhotos] - 1) {
                // Preload index + 1
                id <DXFeedPhoto> photo = [self photoAtIndex:pageIndex+1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
//                    DXLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex+1);
                }
            }
        }
    }
}

#pragma mark - MWPhoto Loading Notification

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <DXFeedPhoto> photo = [notification object];
    DXFeedZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        if ([photo underlyingImage]) {
            // Successful load
            [page displayImage];
            [self loadAdjacentPhotosIfNecessary:photo];
        } else {
            
            // Failed to load
            [page displayImageFailure];
        }
        #pragma mark ### 这里需要看一下，看看角标怎么写
//        [self updateNavigation];
    }
}

#pragma mark - Paging

- (void)tilePages {
    
    // Calculate which pages should be visible
    // Ignore padding as paging bounces encroach on that
    // and lead to false page loads
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger iFirstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
    NSInteger iLastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
    
    // Recycle no longer needed pages
    NSInteger pageIndex;
    for (DXFeedZoomingScrollView *page in _visiblePages) {
        pageIndex = page.index;
        if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
            [_recycledPages addObject:page];
            [page prepareForReuse];
            [page removeFromSuperview];
//            DXLog(@"Removed page at index %lu", (unsigned long)pageIndex);
        }
    }
    [_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
    
    // Add missing pages
    for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            
            // Add new page
            DXFeedZoomingScrollView *page = [self dequeueRecycledPage];
            if (!page) {
                page = [[DXFeedZoomingScrollView alloc] initWithPhotoBrowser:self];
            }
            [_visiblePages addObject:page];
            [self configurePage:page forIndex:index];
            
            [_pagingScrollView addSubview:page];
//            DXLog(@"Added page at index %lu", (unsigned long)index);
        }
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    for (DXFeedZoomingScrollView *page in _visiblePages)
        if (page.index == index) return YES;
    return NO;
}

- (DXFeedZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
    DXFeedZoomingScrollView *thePage = nil;
    for (DXFeedZoomingScrollView *page in _visiblePages) {
        if (page.index == index) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (DXFeedZoomingScrollView *)pageDisplayingPhoto:(id<DXFeedPhoto>)photo {
    DXFeedZoomingScrollView *thePage = nil;
    for (DXFeedZoomingScrollView *page in _visiblePages) {
        if (page.photo == photo) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (void)configurePage:(DXFeedZoomingScrollView *)page forIndex:(NSUInteger)index {
    page.frame = [self frameForPageAtIndex:index];
    page.index = index;
    if (index == _beginPhotoIndex) {
        page.placeholderImageView.image = _sourceImage;
    }
    page.photo = [self photoAtIndex:index];
}

- (DXFeedZoomingScrollView *)dequeueRecycledPage {
    DXFeedZoomingScrollView *page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    
    // Handle 0 photos
    if (![self numberOfPhotos]) {
        return;
    }
    
    // Release images further away than +/-1
    NSUInteger i;
    if (index > 0) {
        // Release anything < index - 1
        for (i = 0; i < index-1; i++) {
            id photo = [_photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                [photo unloadUnderlyingImage];
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
//                DXLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    if (index < [self numberOfPhotos] - 1) {
        // Release anything > index + 1
        for (i = index + 2; i < _photos.count; i++) {
            id photo = [_photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                [photo unloadUnderlyingImage];
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
//                DXLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    
    // Load adjacent images if needed and the photo is already
    // loaded. Also called after photo has been loaded in background
    id <DXFeedPhoto> currentPhoto = [self photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        // photo loaded so load ajacent now
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    
    // Notify delegate
    if (index != _previousPageIndex) {
        if ([_delegate respondsToSelector:@selector(photoBrowser:didDisplayPhotoAtIndex:)])
            [_delegate photoBrowser:self didDisplayPhotoAtIndex:index];
        _previousPageIndex = index;
    }
    
    [self updatePageControl];
}

- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    
    // Change page
    if (index < [self numberOfPhotos]) {
        CGRect pageFrame = [self frameForPageAtIndex:index];
        [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - PADDING, 0) animated:animated];
        [self updatePageControl];
    }
}

#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = _photoContainerView.bounds;
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return CGRectIntegral(frame);
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Checks
    if (_performingLayout || !_viewIsActive) return;
    
    // Tile pages
    [self tilePages];
    
    // Calculate current page
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
    NSUInteger previousCurrentPage = _currentPageIndex;
    _currentPageIndex = index;
    if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self dismiss];
}

#pragma mark - Properties

- (void)setCurrentPhotoIndex:(NSUInteger)index {
    // Validate
    NSUInteger photoCount = [self numberOfPhotos];
    if (photoCount == 0) {
        index = 0;
    } else {
        if (index >= photoCount)
            index = [self numberOfPhotos]-1;
    }
    _currentPageIndex = index;
    _beginPhotoIndex = index;
    
    if (_viewIsActive) {
        [self jumpToPageAtIndex:index animated:NO];
        [self tilePages]; // Force tiling if view is not visible
    }
}

#pragma mark - photoBrowser dead

- (void)dealloc {
    _pagingScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseAllUnderlyingPhotos:NO];
    [[SDImageCache sharedImageCache] clearMemory]; // clear memory
}

#pragma mark - 处理内存警告

- (void)handleMemoryWarningNotification:(NSNotification *)notification {
    
    // Release any cached data, images, etc that aren't in use.
    [self releaseAllUnderlyingPhotos:YES];
    [_recycledPages removeAllObjects];
}

#pragma mark - 取消下载

- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent {
    // Create a copy in case this array is modified while we are looping through
    // Release photos
    NSArray *copy = [_photos copy];
    for (id p in copy) {
        if (p != [NSNull null]) {
            if (preserveCurrent && p == [self photoAtIndex:self.currentIndex]) {
                continue; // skip current
            }
            [p unloadUnderlyingImage];
        }
    }
    // Release thumbs
    copy = [_thumbPhotos copy];
    for (id p in copy) {
        if (p != [NSNull null]) {
            [p unloadUnderlyingImage];
        }
    }
}

@end
