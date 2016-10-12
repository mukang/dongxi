//
//  DXFeedLikeAvatarView.m
//  dongxi
//
//  Created by 穆康 on 15/9/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedLikeAvatarView.h"
#import "DXButton.h"
#import <UIImageView+WebCache.h>
#import "DXDongXiApi.h"
#import "UIImage+Extension.h"
#import "DXAvatarView.h"

/** 最大点赞头像个数 */
static const NSInteger avatarCount = 7;

#define defaultHeight DXRealValue(40)

@interface DXFeedLikeAvatarView ()

/** 点赞头像数组 */
@property (nonatomic, strong) NSMutableArray *avatars;
/** 点赞头像模型数组 */
@property (nonatomic, strong) NSArray *likes;
/** 点赞头像的透明遮盖 */
@property (nonatomic, weak) UIButton *avatarCover;

@end

@implementation DXFeedLikeAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor clearColor];
    
    // 点赞头像
    for (int i=0; i<avatarCount; i++) {
        DXAvatarView *avatarV = [[DXAvatarView alloc] init];
        [self.avatars addObject:avatarV];
        [self addSubview:avatarV];
    }
    
    // 点赞头像的透明遮盖
    UIButton *avatarCover = [DXButton buttonWithType:UIButtonTypeCustom];
    avatarCover.userInteractionEnabled = NO;
    [avatarCover setBackgroundColor:[UIColor blackColor]];
    [avatarCover setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    avatarCover.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:DXRealValue(15)];
    avatarCover.alpha = 0.7;
    DXAvatarView *lastAvatarV = self.avatars[avatarCount - 1];
    lastAvatarV.certificationIconHidden = YES;
    [lastAvatarV addSubview:avatarCover];
    self.avatarCover = avatarCover;
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    self.likes = feed.data.likes;
    
    if (self.likes.count > avatarCount) {
        self.likes = [self.likes subarrayWithRange:NSMakeRange(0, avatarCount)];
    }
    
    // 全部隐藏，防止cell重用时出现bug
    self.avatarCover.hidden = YES;
    for (UIImageView *avatarV in self.avatars) {
        avatarV.hidden = YES;
    }
    
    // 点赞头像
    if (self.likes.count) {
        for (int i=0; i<self.likes.count; i++) {
            DXTimelineFeedLiker *liker = self.likes[i];
            DXAvatarView *avatarV = self.avatars[i];
            avatarV.hidden = NO;
            NSURL *avatarUrl = [NSURL URLWithString:liker.avatar];
            UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(defaultHeight, defaultHeight)];
            [avatarV.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:placeholderImage options:SDWebImageRetryFailed];
            avatarV.verified = liker.verified;
            avatarV.certificationIconSize = DXCertificationIconSizeMedium;
        }
    }
    
    if (self.feed.data.total_like >= avatarCount) {
        // 点赞头像的透明遮盖
        self.avatarCover.hidden = NO;
        [self.avatarCover setTitle:[NSString stringWithFormat:@"%zd", feed.data.total_like] forState:UIControlStateNormal];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGFloat avatarMargin = DXRealValue(6);
    CGFloat avatarWH = defaultHeight;
    CGFloat width = 0;
    
    if (self.feed.data.total_like < avatarCount) {
        width = (avatarWH + avatarMargin) * self.feed.data.total_like - avatarMargin;
    } else {
        width = (avatarWH + avatarMargin) * avatarCount - avatarMargin;
    }
    
    return CGSizeMake(width, avatarWH);
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.likes.count) {
        
        // 点赞头像
        CGFloat avatarMargin = DXRealValue(6);
        CGFloat avatarWH = self.height;
        
        for (int i=0; i<self.likes.count; i++) {
            UIImageView *avatarV = self.avatars[i];
            CGFloat avatarX = (avatarWH + avatarMargin) * i;
            avatarV.frame = CGRectMake(avatarX, 0, avatarWH, avatarWH);
        }
        
        // 点赞头像的透明遮盖
        if (self.feed.data.total_like >= avatarCount) {
            UIImageView *avatarV = self.avatars[avatarCount - 1];
            self.avatarCover.frame = avatarV.bounds;
            self.avatarCover.layer.cornerRadius = avatarWH * 0.5;
            self.avatarCover.layer.masksToBounds = YES;
        }
    }
}

+ (CGFloat)heightForLikeAvatarViewWithFeed:(DXTimelineFeed *)feed {
    
    return defaultHeight;
}

#pragma mark - 懒加载

- (NSMutableArray *)avatars {
    
    if (_avatars == nil) {
        _avatars = [NSMutableArray array];
    }
    return _avatars;
}

@end
