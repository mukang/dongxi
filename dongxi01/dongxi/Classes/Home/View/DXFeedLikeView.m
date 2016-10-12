//
//  DXFeedLikeView.m
//  dongxi
//
//  Created by 穆康 on 15/10/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedLikeView.h"

static NSString *const kLikeImageName = @"like_01";
static NSString *const kUnlikeImageName = @"like_28";

@interface DXFeedLikeView ()

@property (nonatomic, weak) UIImageView *likeView;

@property (nonatomic, weak) UILabel *likeLabel;
/*
@property (nonatomic, strong) NSMutableArray *likeAnimationImages;

@property (nonatomic, strong) NSMutableArray *unlikeAnimationImages;
*/
@end

@implementation DXFeedLikeView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {

    UIImageView *likeView = [[UIImageView alloc] init];
//    likeView.animationDuration = 1.0;
//    likeView.animationRepeatCount = 1;
    [self addSubview:likeView];
    self.likeView = likeView;
    
    UILabel *likeLabel = [[UILabel alloc] init];
    likeLabel.text = @"赞";
    likeLabel.textColor = DXRGBColor(48, 48, 48);
    likeLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    [self addSubview:likeLabel];
    [likeLabel sizeToFit];
    self.likeLabel = likeLabel;
    /*
    for (int i=1; i<=28; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"like_%02d", i]];
        [self.unlikeAnimationImages addObject:image];
    }
    
    for (int i=28; i>=1; i--) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"like_%02d", i]];
        [self.likeAnimationImages addObject:image];
    }
     */
}

- (void)setLike:(BOOL)like {
    _like = like;
    
    if (like) {
        self.likeView.image = [UIImage imageNamed:kLikeImageName];
    } else {
        self.likeView.image = [UIImage imageNamed:kUnlikeImageName];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.likeView.size = CGSizeMake(DXRealValue(20), DXRealValue(20));
    self.likeView.x = DXRealValue(20);
    self.likeView.centerY = self.height * 0.5;
    
    self.likeLabel.x = CGRectGetMaxX(self.likeView.frame) + DXRealValue(4);
    self.likeLabel.centerY = self.likeView.centerY;
}

/*
#pragma mark - 动画

- (void)startLikeAnimating {
    
    if (self.feed.data.is_like) {
        self.likeView.image = [UIImage imageNamed:kUnlikeImageName];
        self.likeView.animationImages = self.unlikeAnimationImages;
    } else {
        self.likeView.image = [UIImage imageNamed:kLikeImageName];
        self.likeView.animationImages = self.likeAnimationImages;
    }
    
    [self.likeView startAnimating];
}

- (void)setLiked:(BOOL)liked anmated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.likeView.isAnimating) {
        [self.likeView stopAnimating];
    }
    
    if (liked) {
        if (animated) {
            self.likeView.image = [UIImage imageNamed:kLikeImageName];
            self.likeView.animationImages = self.likeAnimationImages;
            [self.likeView startAnimating];
        } else {
            self.likeView.image = [UIImage imageNamed:kLikeImageName];
            self.likeView.animationImages = nil;
        }
    }
    
    if (!liked) {
        if (animated) {
            self.likeView.image = [UIImage imageNamed:kUnlikeImageName];
            self.likeView.animationImages = self.unlikeAnimationImages;
            [self.likeView startAnimating];
        } else {
            [self.likeView setImage:[UIImage imageNamed:kUnlikeImageName]];
            self.likeView.animationImages = nil;
        }
    }
    
    if (completion) {
        completion();
    }
}

- (BOOL)isLikeAnimating {
    
    return self.likeView.isAnimating;
}

#pragma mark - 懒加载

- (NSMutableArray *)likeAnimationImages {
    
    if (_likeAnimationImages == nil) {
        _likeAnimationImages = [NSMutableArray array];
    }
    return _likeAnimationImages;
}

- (NSMutableArray *)unlikeAnimationImages {
    
    if (_unlikeAnimationImages == nil) {
        _unlikeAnimationImages = [NSMutableArray array];
    }
    return _unlikeAnimationImages;
}
 */

@end
