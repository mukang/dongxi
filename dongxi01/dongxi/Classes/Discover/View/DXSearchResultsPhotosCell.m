//
//  DXSearchResultsPhotosCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/22.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchResultsPhotosCell.h"
#import "UIImage+Extension.h"
#import <UIImageView+WebCache.h>

static NSInteger const MaxPhotosCount = 16;

@interface DXSearchResultsPhotosCell ()

@property (nonatomic, strong) NSArray *photoViews;
@property (nonatomic, strong) NSArray *feedList;

@end

@implementation DXSearchResultsPhotosCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:16];
    for (NSInteger i=0; i<MaxPhotosCount; i++) {
        UIImageView *photoView = [[UIImageView alloc] init];
        photoView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewDidTap:)];
        [photoView addGestureRecognizer:tap];
        [self.contentView addSubview:photoView];
        [temp addObject:photoView];
    }
    self.photoViews = [temp copy];
}

- (void)setFeeds:(NSArray *)feeds {
    _feeds = feeds;
    if (feeds.count == 0) return;
    
    if (feeds.count <= MaxPhotosCount) {
        self.feedList = feeds;
    } else {
        self.feedList = [feeds subarrayWithRange:NSMakeRange(0, MaxPhotosCount)];
    }
    for (UIImageView *photoView in self.photoViews) {
        photoView.hidden = YES;
    }
    
    int columns = 4;
    CGFloat margin = 2;
    CGFloat photoViewWH = (DXScreenWidth - (columns - 1) * margin) / columns;
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(photoViewWH, photoViewWH)];
    for (int i=0; i<self.feedList.count; i++) {
        DXTimelineFeed *feed = self.feedList[i];
        NSString *preview = [feed.data.photo[0] preview];
        UIImageView *photoView = self.photoViews[i];
        photoView.hidden = NO;
        [photoView sd_setImageWithURL:[NSURL URLWithString:preview] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    int columns = 4;
    CGFloat margin = 2;
    CGFloat photoViewWH = (self.contentView.width - (columns - 1) * margin) / columns;
    CGFloat photoViewX = 0;
    CGFloat photoViewY = 0;
    
    for (int i=0; i<self.feedList.count; i++) {
        int row = i/columns;
        int col = i%columns;
        photoViewX = (photoViewWH + margin) * col;
        photoViewY = (photoViewWH + margin) * row;
        
        UIImageView *photoView = self.photoViews[i];
        photoView.frame = CGRectMake(photoViewX, photoViewY, photoViewWH, photoViewWH);
    }
}

- (void)photoViewDidTap:(UITapGestureRecognizer *)tap {
    
    UIImageView *photoView = (UIImageView *)tap.view;
    NSUInteger index = [self.photoViews indexOfObject:photoView];
    DXTimelineFeed *feed = self.feedList[index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchResultsPhotosCell:didTapPhotoWithFeed:)]) {
        [self.delegate searchResultsPhotosCell:self didTapPhotoWithFeed:feed];
    }
}

@end
