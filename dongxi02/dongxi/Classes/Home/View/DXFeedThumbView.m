//
//  DXFeedThumbView.m
//  dongxi
//
//  Created by 穆康 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedThumbView.h"
#import <UIImageView+WebCache.h>
#import "DXDongXiApi.h"
#import "UIImage+Extension.h"

/** 缩略图内边距 */
static const CGFloat insetMargin = 2.0;

@interface DXFeedThumbView ()

/** 边框 */
@property (nonatomic, weak) UIImageView *borderV;
/** 缩略图内容 */
@property (nonatomic, weak) UIImageView *thumbV;

@end

@implementation DXFeedThumbView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UIImageView *borderV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"border_blue_image"]];
    [self addSubview:borderV];
    self.borderV = borderV;
    
    UIImageView *thumbV = [[UIImageView alloc] init];
    thumbV.contentMode = UIViewContentModeScaleAspectFill;
    thumbV.layer.masksToBounds = YES;
    [self addSubview:thumbV];
    self.thumbV = thumbV;
}

- (void)setPhoto:(DXTimelineFeedPhoto *)photo {
    
    _photo = photo;
    
    // 需要算一下占位图大小
    NSInteger thumbCount = 6;
    CGFloat thumbMargin = DXRealValue(8.0f);
    CGFloat thumbWH = (DXScreenWidth - thumbMargin) / thumbCount - thumbMargin;
    CGFloat imageWH = thumbWH - insetMargin * 2.0f;
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(imageWH, imageWH)];
    
    [self.thumbV sd_setImageWithURL:[NSURL URLWithString:photo.preview] placeholderImage:placeholderImage options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            DXLog(@"预览图下载失败: %@", error.localizedDescription);
        }
    }];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.borderV.frame = self.bounds;
    
    self.thumbV.x = insetMargin;
    self.thumbV.y = insetMargin;
    self.thumbV.width = self.width - insetMargin * 2.0;
    self.thumbV.height = self.height - insetMargin * 2.0;
}


- (void)setBorderIsHidden:(BOOL)borderIsHidden {
    
    _borderIsHidden = borderIsHidden;
    
    if (borderIsHidden) {
        self.borderV.hidden = YES;
    } else {
        self.borderV.hidden = NO;
    }
}

@end
