//
//  DXDetailPhotosCell.m
//  dongxi
//
//  Created by 穆康 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDetailPhotosCell.h"
#import "DXDongXiApi.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Extension.h"
#import "DXFeedPhotoView.h"
#import "DXFeedPhotoBrowser.h"

/** 最大照片数量 */
static const int photoCount = 7;

#define TopMargin DXRealValue(0) // cell内容顶部间距
#define margin DXRealValue(13) // 间距

@interface DXDetailPhotosCell () <DXFeedPhotoBrowserDelegate>

@property (nonatomic, weak) UIView *containerView;
/** 装大图的数组 */
@property (nonatomic, strong) NSMutableArray *bigImageVs;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *borderViews;

@end

@implementation DXDetailPhotosCell

- (NSMutableArray *)bigImageVs {
    
    if (_bigImageVs == nil) {
        _bigImageVs = [NSMutableArray array];
    }
    return _bigImageVs;
}

- (NSMutableArray *)borderViews {
    
    if (_borderViews == nil) {
        _borderViews = [NSMutableArray array];
    }
    return _borderViews;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"photoCell";
    
    DXDetailPhotosCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXDetailPhotosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = DXRGBColor(222, 222, 222);
        
        [self setup];
    }
    return self;
}

// 初始化子控件
- (void)setup {
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:containerView];
    self.containerView = containerView;
    
    for (int i=0; i<photoCount; i++) {
        
        UIView *borderView = [[UIView alloc] init];
        borderView.backgroundColor = DXRGBColor(237, 238, 238);
        borderView.hidden = YES;
        [containerView addSubview:borderView];
        [self.borderViews addObject:borderView];
        
        DXFeedPhotoView *bigPhotoView = [[DXFeedPhotoView alloc] init];
        bigPhotoView.backgroundColor = DXRGBColor(222, 222, 222);
        bigPhotoView.contentMode = UIViewContentModeScaleAspectFit;
        bigPhotoView.layer.masksToBounds = YES;
        bigPhotoView.photoIndex = i;
        bigPhotoView.userInteractionEnabled = YES;
        bigPhotoView.hidden = YES;
        [containerView addSubview:bigPhotoView];
        [self.bigImageVs addObject:bigPhotoView];
        UITapGestureRecognizer *bigPhotoViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlebigPhotoViewTapGesture:)];
        [bigPhotoView addGestureRecognizer:bigPhotoViewTap];
    }
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    NSArray *photos = feed.data.photo;
    
    for (int i=0; i<photos.count; i++) {
        
        DXFeedPhotoView *bigPhotoView = self.bigImageVs[i];
        UIView *borderView = self.borderViews[i];
        bigPhotoView.hidden = NO;
        borderView.hidden = NO;
        DXTimelineFeedPhoto *photo = photos[i];
        CGFloat imageW = DXScreenWidth - margin * 2.0f;
        CGSize placeholderImageSize = CGSizeZero;
        if (photo.height <= 0 || photo.width <= 0) {
            photo.height = 1080;
            photo.width = 1080;
        }
        if (photo.height >= photo.width) {
            placeholderImageSize = CGSizeMake(imageW, imageW);
        } else {
            CGFloat imageH = imageW / photo.width * photo.height;
            placeholderImageSize = CGSizeMake(imageH, imageH);
        }
        UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:placeholderImageSize];
        bigPhotoView.hasImage = NO;
        [bigPhotoView sd_setImageWithURL:[NSURL URLWithString:photo.url] placeholderImage:placeholderImage options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                bigPhotoView.hasImage = YES;
            }
        }];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat containerViewY = TopMargin;
    CGFloat containerViewW = self.contentView.width;
    CGFloat containerViewH = self.contentView.height - containerViewY;
    self.containerView.frame = CGRectMake(0, containerViewY, containerViewW, containerViewH);
    
    NSArray *bigPhotos = self.feed.data.photo;
    
    CGFloat bigPhotoViewX = margin;
    CGFloat bigPhotoViewY = 0;
    CGFloat bigPhotoViewW = self.contentView.width - margin * 2.0;
    CGFloat bigPhotoViewH = 0;
    CGFloat previousPhotoMaxY = 0;
    
    for (int i=0; i<bigPhotos.count; i++) {
        DXTimelineFeedPhoto *photo = bigPhotos[i];
        if (photo.height <= 0 || photo.width <= 0) {
            photo.height = 1080;
            photo.width = 1080;
        }
        bigPhotoViewH = bigPhotoViewW / photo.width * photo.height;
        bigPhotoViewY = previousPhotoMaxY + margin;
        
        DXFeedPhotoView *bigPhotoView = self.bigImageVs[i];
        UIView *borderView = self.borderViews[i];
        bigPhotoView.frame = CGRectMake(bigPhotoViewX, bigPhotoViewY, bigPhotoViewW, bigPhotoViewH);
        borderView.frame = CGRectInset(bigPhotoView.frame, -0.5, -0.5);
        previousPhotoMaxY = CGRectGetMaxY(bigPhotoView.frame);
    }
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withFeed:(DXTimelineFeed *)feed {
    
    NSArray *bigPhotos = feed.data.photo;
    CGFloat totalPhotosH = 0;
    CGFloat photoW = DXScreenWidth - margin * 2;
    CGFloat photoH = 0;
    for (int i=0; i<bigPhotos.count; i++) {
        DXTimelineFeedPhoto *photo = bigPhotos[i];
        if (photo.height <= 0 || photo.width <= 0) {
            photo.height = 1080;
            photo.width = 1080;
        }
        photoH = photoW / photo.width * photo.height;
        totalPhotosH += (margin + photoH);
    }
    totalPhotosH += margin;
    
    return TopMargin + totalPhotosH;
}

#pragma mark - 执行手势的方法

- (void)handlebigPhotoViewTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    DXFeedPhotoView *bigPhotoView = (DXFeedPhotoView *)tapGesture.view;
    if (bigPhotoView.hasImage) {
        
        [self.photos removeAllObjects];
        NSArray *photoList = self.feed.data.photo;
        for (DXTimelineFeedPhoto *photo in photoList) {
            [self.photos addObject:[DXFeedPhoto photoWithURL:[NSURL URLWithString:photo.url]]];
        }
        
        DXFeedPhotoBrowser *photoBrowser = [[DXFeedPhotoBrowser alloc] initWithDelegate:self];
        photoBrowser.sourceImage = bigPhotoView.image;
        photoBrowser.sourceImageViewFrame = bigPhotoView.frame;
        photoBrowser.sourceImageContainerView = self;
        [photoBrowser setCurrentPhotoIndex:bigPhotoView.photoIndex];
        [photoBrowser show];
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(DXFeedPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <DXFeedPhoto>)photoBrowser:(DXFeedPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}

#pragma mark - 懒加载

- (NSMutableArray *)photos {
    if (_photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

@end
