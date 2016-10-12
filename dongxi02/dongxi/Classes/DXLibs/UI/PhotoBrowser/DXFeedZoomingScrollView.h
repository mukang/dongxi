//
//  DXFeedZoomingScrollView.h
//  dongxi
//
//  Created by 穆康 on 16/3/2.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXFeedPhotoProtocol.h"
#import "DXFeedTapDetectingImageView.h"
#import "DXFeedTapDetectingView.h"

@class DXFeedPhotoBrowser, DXFeedPhoto;

@interface DXFeedZoomingScrollView : UIScrollView <UIScrollViewDelegate, DXFeedTapDetectingImageViewDelegate, DXFeedTapDetectingViewDelegate>

@property () NSUInteger index;
@property (nonatomic) id <DXFeedPhoto> photo;
@property (nonatomic, weak) UIImageView *placeholderImageView;

- (id)initWithPhotoBrowser:(DXFeedPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (void)setImageHidden:(BOOL)hidden;

@end
