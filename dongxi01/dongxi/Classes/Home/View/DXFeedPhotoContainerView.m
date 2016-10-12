//
//  DXFeedPhotoContainerView.m
//  dongxi
//
//  Created by 穆康 on 16/8/22.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedPhotoContainerView.h"
#import "DXFeedPhotoView.h"
#import <UIImageView+WebCache.h>

@interface DXFeedPhotoContainerView ()

@property (nonatomic, strong) NSMutableArray *photoViews;
@property (nonatomic, weak) DXFeedPhotoView *photoView00;
@property (nonatomic, weak) DXFeedPhotoView *photoView01;
@property (nonatomic, weak) DXFeedPhotoView *photoView02;
@property (nonatomic, weak) DXFeedPhotoView *photoView03;
@property (nonatomic, weak) DXFeedPhotoView *photoView04;
@property (nonatomic, weak) DXFeedPhotoView *photoView05;
@property (nonatomic, weak) DXFeedPhotoView *photoView06;
@property (nonatomic, weak) DXFeedPhotoView *photoView07;
@property (nonatomic, weak) DXFeedPhotoView *photoView08;

@end

@implementation DXFeedPhotoContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupContent];
    }
    return self;
}

- (void)setupContent {
    
    self.photoViews = [NSMutableArray arrayWithCapacity:9];
    
    DXFeedPhotoView *photoView00 = [[DXFeedPhotoView alloc] init];
    [self.photoViews addObject:photoView00];
    DXFeedPhotoView *photoView01 = [[DXFeedPhotoView alloc] init];
    [self.photoViews addObject:photoView01];
    DXFeedPhotoView *photoView02 = [[DXFeedPhotoView alloc] init];
    [self.photoViews addObject:photoView02];
    DXFeedPhotoView *photoView03 = [[DXFeedPhotoView alloc] init];
    [self.photoViews addObject:photoView03];
    DXFeedPhotoView *photoView04 = [[DXFeedPhotoView alloc] init];
    [self.photoViews addObject:photoView04];
    DXFeedPhotoView *photoView05 = [[DXFeedPhotoView alloc] init];
    [self.photoViews addObject:photoView05];
    DXFeedPhotoView *photoView06 = [[DXFeedPhotoView alloc] init];
    [self.photoViews addObject:photoView06];
    DXFeedPhotoView *photoView07 = [[DXFeedPhotoView alloc] init];
    [self.photoViews addObject:photoView07];
    DXFeedPhotoView *photoView08 = [[DXFeedPhotoView alloc] init];
    [self.photoViews addObject:photoView08];
    
    for (int i=0; i<self.photoViews.count; i++) {
        DXFeedPhotoView *photoView = self.photoViews[i];
        photoView.photoIndex = i;
        photoView.contentMode = UIViewContentModeScaleAspectFill;
        photoView.clipsToBounds = YES;
        photoView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePhotoViewTap:)];
        [photoView addGestureRecognizer:gesture];
        [self addSubview:photoView];
    }
    
    self.photoView00 = photoView00;
    self.photoView01 = photoView01;
    self.photoView02 = photoView02;
    self.photoView03 = photoView03;
    self.photoView04 = photoView04;
    self.photoView05 = photoView05;
    self.photoView06 = photoView06;
    self.photoView07 = photoView07;
    self.photoView08 = photoView08;
}

- (void)setFeed:(DXFeed *)feed {
    _feed = feed;
    
    if (feed.photos.count > self.photoViews.count) {
        DXLog(@"ID为：%@的feed，图片数量超出9张", feed.fid);
        return;
    }
    
    for (DXFeedPhotoView *photoView in self.photoViews) {
        photoView.hidden = YES;
    }
    
    for (int i=0; i<feed.photos.count; i++) {
        DXFeedPhotoView *photoView = self.photoViews[i];
        DXFeedPhotoInfo *photoInfo = feed.photos[i];
        photoView.hidden = NO;
        NSURL *photoUrl = [NSURL URLWithString:photoInfo.url];
        [photoView sd_setImageWithURL:photoUrl placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                photoView.hasImage = YES;
            }
        }];
    }
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat photoLength = self.width;
    CGFloat photoLength2 = self.width / 2.0;
    CGFloat photoLength3 = self.width / 3.0;
    CGFloat photoLength4 = self.width / 4.0;
    
    switch (self.feed.photos.count) {
        case 1:
        {
            self.photoView00.frame = CGRectMake(0, 0, photoLength, photoLength);
        }
            break;
        case 2:
        {
            self.photoView00.frame = CGRectMake(0, 0, photoLength, photoLength2);
            self.photoView01.frame = CGRectMake(0, photoLength2, photoLength, photoLength2);
        }
            break;
        case 3:
        {
            self.photoView00.frame = CGRectMake(0, 0, photoLength, photoLength2);
            self.photoView01.frame = CGRectMake(0, photoLength2, photoLength2, photoLength2);
            self.photoView02.frame = CGRectMake(photoLength2, photoLength2, photoLength2, photoLength2);
        }
            break;
        case 4:
        {
            self.photoView00.frame = CGRectMake(0, 0, photoLength2, photoLength2);
            self.photoView01.frame = CGRectMake(photoLength2, 0, photoLength2, photoLength2);
            self.photoView02.frame = CGRectMake(0, photoLength2, photoLength2, photoLength2);
            self.photoView03.frame = CGRectMake(photoLength2, photoLength2, photoLength2, photoLength2);
        }
            break;
        case 5:
        {
            self.photoView00.frame = CGRectMake(0, 0, photoLength3 * 2.0, photoLength3 * 2.0);
            self.photoView01.frame = CGRectMake(photoLength3 * 2.0, 0, photoLength3, photoLength3);
            self.photoView02.frame = CGRectMake(photoLength3 * 2.0, photoLength3, photoLength3, photoLength3);
            self.photoView03.frame = CGRectMake(0, photoLength3 * 2.0, photoLength3 * 2.0, photoLength3);
            self.photoView04.frame = CGRectMake(photoLength3 * 2.0, photoLength3 * 2.0, photoLength3, photoLength3);
        }
            break;
        case 6:
        {
            self.photoView00.frame = CGRectMake(0, 0, photoLength3 * 2.0, photoLength3 * 2.0);
            self.photoView01.frame = CGRectMake(photoLength3 * 2.0, 0, photoLength3, photoLength3);
            self.photoView02.frame = CGRectMake(photoLength3 * 2.0, photoLength3, photoLength3, photoLength3);
            self.photoView03.frame = CGRectMake(0, photoLength3 * 2.0, photoLength3, photoLength3);
            self.photoView04.frame = CGRectMake(photoLength3, photoLength3 * 2.0, photoLength3, photoLength3);
            self.photoView05.frame = CGRectMake(photoLength3 * 2.0, photoLength3 * 2.0, photoLength3, photoLength3);
        }
            break;
        case 7:
        {
            self.photoView00.frame = CGRectMake(0, 0, photoLength, photoLength3);
            self.photoView01.frame = CGRectMake(0, photoLength3, photoLength3, photoLength3);
            self.photoView02.frame = CGRectMake(photoLength3, photoLength3, photoLength3, photoLength3);
            self.photoView03.frame = CGRectMake(photoLength3 * 2.0, photoLength3, photoLength3, photoLength3);
            self.photoView04.frame = CGRectMake(0, photoLength3 * 2.0, photoLength3, photoLength3);
            self.photoView05.frame = CGRectMake(photoLength3, photoLength3 * 2.0, photoLength3, photoLength3);
            self.photoView06.frame = CGRectMake(photoLength3 * 2.0, photoLength3 * 2.0, photoLength3, photoLength3);
        }
            break;
        case 8:
        {
            self.photoView00.frame = CGRectMake(0, 0, photoLength4 * 3.0, photoLength4 * 3.0);
            self.photoView01.frame = CGRectMake(photoLength4 * 3.0, 0, photoLength4, photoLength4);
            self.photoView02.frame = CGRectMake(photoLength4 * 3.0, photoLength4, photoLength4, photoLength4);
            self.photoView03.frame = CGRectMake(photoLength4 * 3.0, photoLength2, photoLength4, photoLength4);
            self.photoView04.frame = CGRectMake(0, photoLength4 * 3.0, photoLength4, photoLength4);
            self.photoView05.frame = CGRectMake(photoLength4, photoLength4 * 3.0, photoLength4, photoLength4);
            self.photoView06.frame = CGRectMake(photoLength2, photoLength4 * 3.0, photoLength4, photoLength4);
            self.photoView07.frame = CGRectMake(photoLength4 * 3.0, photoLength4 * 3.0, photoLength4, photoLength4);
        }
            break;
        case 9:
        {
            int totalRow = 3;
            for (int i=0; i<self.photoViews.count; i++) {
                int row = i / totalRow;
                int column = i % totalRow;
                DXFeedPhotoView *photoView = self.photoViews[i];
                photoView.frame = CGRectMake(photoLength3 * column, photoLength3 * row, photoLength3, photoLength3);
            }
        }
            break;
            
        default:
            DXLog(@"不会来这里了吧！！！");
            break;
    }
}

- (void)handlePhotoViewTap:(UITapGestureRecognizer *)gesture {
    DXFeedPhotoView *photoView = (DXFeedPhotoView *)gesture.view;
    if (photoView.hasImage && self.delegate && [self.delegate respondsToSelector:@selector(feedPhotoContainerView:didTapPhotoView:)]) {
        [self.delegate feedPhotoContainerView:self didTapPhotoView:photoView];
    }
}

@end
