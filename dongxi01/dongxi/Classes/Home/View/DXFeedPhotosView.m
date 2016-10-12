//
//  DXFeedPhotosView.m
//  dongxi
//
//  Created by 穆康 on 15/9/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import "DXFeedPhotosView.h"
#import "UIImage+Extension.h"

#define Thumb_Count            6                    // 缩略图总数
#define Margin                 DXRealValue(12)      // 间距

@interface DXFeedPhotosView ()

@property (nonatomic, weak) UIView *borderView;
/** 大图 */
@property (nonatomic, weak) DXFeedPhotoView *bigPhotoView;
/** 缩略图数组 */
@property (nonatomic, strong) NSMutableArray *thumbViews;
/** 分割线 */
@property (nonatomic, weak) UIView *dividerV;

@end

@implementation DXFeedPhotosView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *borderView = [[UIView alloc] init];
    borderView.backgroundColor = DXRGBColor(237, 238, 238);
    [self addSubview:borderView];
    self.borderView = borderView;
    
    // 大图
    DXFeedPhotoView *bigPhotoView = [[DXFeedPhotoView alloc] init];
    bigPhotoView.backgroundColor = DXRGBColor(222, 222, 222);
    bigPhotoView.contentMode = UIViewContentModeScaleAspectFit;
    bigPhotoView.clipsToBounds = YES;
    bigPhotoView.userInteractionEnabled = YES;
    bigPhotoView.photoIndex = 0;
    [self addSubview:bigPhotoView];
    UITapGestureRecognizer *bigPhotoViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlebigPhotoViewTapGesture:)];
    [bigPhotoView addGestureRecognizer:bigPhotoViewTap];
    self.bigPhotoView = bigPhotoView;
    
    // 缩略图
    for (int i=0; i<Thumb_Count; i++) {
        DXFeedPhotoView *thumbView = [[DXFeedPhotoView alloc] init];
        thumbView.contentMode = UIViewContentModeScaleAspectFill;
        thumbView.clipsToBounds = YES;
        thumbView.photoIndex = i + 1;
        thumbView.userInteractionEnabled = YES;
        [self addSubview:thumbView];
        [self.thumbViews addObject:thumbView];
        UITapGestureRecognizer *thumbViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThumbViewTapGesture:)];
        [thumbView addGestureRecognizer:thumbViewTap];
    }
    
    // 分割线
    UIView *dividerV = [[UIView alloc] init];
    dividerV.backgroundColor = DXRGBColor(208, 208, 208);
    [self addSubview:dividerV];
    self.dividerV = dividerV;
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    NSArray *photos = feed.data.photo;
    NSUInteger photosCount = photos.count;
    
    // 大图
    DXTimelineFeedPhoto *firstPhoto = photos[0];
    CGFloat placeholderImageW = DXScreenWidth - Margin * 2.0;
    CGSize placeholderImageSize = CGSizeZero;
    if (firstPhoto.height <= 0 || firstPhoto.width <= 0) {
        firstPhoto.height = 1080;
        firstPhoto.width = 1080;
    }
    
    if (firstPhoto.height >= firstPhoto.width) {
        placeholderImageSize = CGSizeMake(placeholderImageW, placeholderImageW);
    } else {
        CGFloat placeholderImageH = placeholderImageW / firstPhoto.width * firstPhoto.height;
        placeholderImageSize = CGSizeMake(placeholderImageH, placeholderImageH);
    }
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:placeholderImageSize];
    self.bigPhotoView.hasImage = NO;
    __weak typeof(self) weakSelf = self;
    [self.bigPhotoView sd_setImageWithURL:[NSURL URLWithString:firstPhoto.url] placeholderImage:placeholderImage options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            weakSelf.bigPhotoView.hasImage = YES;
        }
    }];
    
    // 缩略图隐藏，防止cell重用时出现bug
    CGFloat thumbViewWH = (DXScreenWidth - (Thumb_Count + 1) * Margin) / Thumb_Count;
    for (DXFeedPhotoView *thumbView in self.thumbViews) {
        thumbView.hidden = YES;
    }
    placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(thumbViewWH, thumbViewWH)];
    if (photosCount > 1 && photosCount <= Thumb_Count + 1) { // 有多张图
        self.dividerV.hidden = NO;
        for (NSUInteger i=1; i<photosCount; i++) {
            DXTimelineFeedPhoto *photo = photos[i];
            DXFeedPhotoView *thumbView = self.thumbViews[i-1];
            thumbView.hidden = NO;
            thumbView.hasImage = NO;
            __weak typeof(thumbView) weakThumbView = thumbView;
            [thumbView sd_setImageWithURL:[NSURL URLWithString:photo.preview] placeholderImage:placeholderImage options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    weakThumbView.hasImage = YES;
                }
            }];
        }
    } else {
        self.dividerV.hidden = YES;
    }
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    NSArray *photos = self.feed.data.photo;
    NSUInteger photosCount = photos.count;
    
    // 大图
    DXTimelineFeedPhoto *bigPhoto = photos[0];
    if (bigPhoto.height <= 0 || bigPhoto.width <= 0) {
        bigPhoto.height = 1080;
        bigPhoto.width = 1080;
    }
    
    CGFloat bigPhotoViewW = self.width - Margin * 2.0;
    CGFloat bigPhotoViewH = bigPhotoViewW / bigPhoto.width * bigPhoto.height;
    self.bigPhotoView.frame = CGRectMake(Margin, 0.5, bigPhotoViewW, bigPhotoViewH);
    
    // 边界
    self.borderView.frame = CGRectInset(self.bigPhotoView.frame, -0.5, -0.5);
    
    // 缩略图
    CGFloat thumbViewWH = (self.width - (Thumb_Count + 1) * Margin) / Thumb_Count;
    if (photosCount > 1 && photosCount <= Thumb_Count + 1) {
        CGFloat thumbViewY = CGRectGetMaxY(self.bigPhotoView.frame) + Margin;
        for (NSUInteger i=0; i<photosCount-1; i++) {
            DXFeedPhotoView *thumbView = self.thumbViews[i];
            CGFloat thumbViewX = Margin + (thumbViewWH + Margin) * i;
            thumbView.frame = CGRectMake(thumbViewX, thumbViewY, thumbViewWH, thumbViewWH);
        }
        // 分割线
        CGFloat dividerVX = Margin;
        CGFloat dividerVW = self.width - dividerVX * 2.0;
        CGFloat dividerVH = 0.5;
        CGFloat dividerVY = self.height - dividerVH;
        self.dividerV.frame = CGRectMake(dividerVX, dividerVY, dividerVW, dividerVH);
    }
}

+ (CGFloat)heightForPhotosViewWithFeed:(DXTimelineFeed *)feed {
    
    CGFloat height = 0;
    NSUInteger photosCount = feed.data.photo.count;
    DXTimelineFeedPhoto *bigPhoto = feed.data.photo[0];
    if (bigPhoto.height <= 0 || bigPhoto.width <= 0) {
        bigPhoto.height = 1080;
        bigPhoto.width = 1080;
    }
    CGFloat bigPhotoW = DXScreenWidth - Margin * 2.0;
    CGFloat bigPhotoH = bigPhotoW / bigPhoto.width * bigPhoto.height;
    CGFloat thumbViewWH = (DXScreenWidth - (Thumb_Count + 1) * Margin) / Thumb_Count;
    if (photosCount > 1 && photosCount <= Thumb_Count + 1) {
        height = bigPhotoH + Margin + thumbViewWH + Margin + 1;
    } else {
        height = bigPhotoH + 1;
    }
    return height;
}

#pragma mark - 执行手势的方法

- (void)handlebigPhotoViewTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    if (self.bigPhotoView.hasImage && self.delegate && [self.delegate respondsToSelector:@selector(feedPhotosView:didTapPhotoWithPhotoView:)]) {
        [self.delegate feedPhotosView:self didTapPhotoWithPhotoView:self.bigPhotoView];
    }
}

- (void)handleThumbViewTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    DXFeedPhotoView *photoView = (DXFeedPhotoView *)tapGesture.view;
    if (photoView.hasImage && self.delegate && [self.delegate respondsToSelector:@selector(feedPhotosView:didTapPhotoWithPhotoView:)]) {
        [self.delegate feedPhotosView:self didTapPhotoWithPhotoView:photoView];
    }
}

#pragma mark - 懒加载

- (NSMutableArray *)thumbViews {
    
    if (_thumbViews == nil) {
        _thumbViews = [NSMutableArray array];
    }
    return _thumbViews;
}

@end
