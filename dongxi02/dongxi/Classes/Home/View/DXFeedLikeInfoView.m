//
//  DXFeedLikeInfoView.m
//  dongxi
//
//  Created by 穆康 on 15/11/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  

#import "DXFeedLikeInfoView.h"
#import "DXFeedLikeAvatarView.h"

#define AvatarV_Top_Margin       DXRealValue(11.0f)  // 头像距顶部的间距
#define AvatarV_Bottom_Margin    DXRealValue(18.0f)  // 头像距分割线的间距
#define DividerV_Left_Margin     DXRealValue(12.0f)  // 分割线距视图的左边距

@interface DXFeedLikeInfoView ()

/** 点赞头像视图 */
@property (nonatomic, weak) DXFeedLikeAvatarView *likeAvatarView;
/** 点赞人数 */
//@property (nonatomic, weak) UILabel *infoL;
/** 分割线 */
@property (nonatomic, weak) UIView *dividerV;

@end

@implementation DXFeedLikeInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    // 点赞头像视图
    DXFeedLikeAvatarView *likeAvatarView = [[DXFeedLikeAvatarView alloc] init];
    [self addSubview:likeAvatarView];
    self.likeAvatarView = likeAvatarView;
    
    // 点赞人数
//    UILabel *infoL = [[UILabel alloc] init];
//    infoL.textColor = DXRGBColor(143, 143, 143);
//    infoL.textAlignment = NSTextAlignmentCenter;
//    infoL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(14)];
//    [self addSubview:infoL];
//    self.infoL = infoL;
    
    // 分割线
    UIView *dividerV = [[UIView alloc] init];
    dividerV.backgroundColor = DXRGBColor(208, 208, 208);
    [self addSubview:dividerV];
    self.dividerV = dividerV;
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    // 点赞头像视图
    self.likeAvatarView.feed = feed;
    [self.likeAvatarView sizeToFit];
    
    // 评论人数及点赞人数
//    self.infoL.text = [NSString stringWithFormat:@"%zd人赞过", feed.data.total_like];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat avatarVMaxY = 0;
    if (self.feed.data.total_like) {
        self.likeAvatarView.centerX = self.width * 0.5f;
        self.likeAvatarView.y = AvatarV_Top_Margin;
        avatarVMaxY = CGRectGetMaxY(self.likeAvatarView.frame);
    }
    
    // 点赞人数
//    CGFloat infoLX = 0;
//    CGFloat infoLY = avatarVMaxY + AvatarV_InfoL_Margin;
//    CGFloat infoLW = self.width;
//    CGFloat infoLH = DXRealValue(14.0f);
//    self.infoL.frame = CGRectMake(infoLX, infoLY, infoLW, infoLH);
    
    // 分割线
    CGFloat dividerVW = self.width - DividerV_Left_Margin * 2.0f;
    CGFloat dividerVH = 0.5f;
    CGFloat dividerVX = DividerV_Left_Margin;
    CGFloat dividerVY = self.height - dividerVH;
    self.dividerV.frame = CGRectMake(dividerVX, dividerVY, dividerVW, dividerVH);
}

+ (CGFloat)heightForLikeInfoViewWithFeed:(DXTimelineFeed *)feed {
    
    CGFloat avatarVH = [DXFeedLikeAvatarView heightForLikeAvatarViewWithFeed:feed];
    
    if (feed.data.total_like) {
        return AvatarV_Top_Margin + avatarVH + AvatarV_Bottom_Margin;
    } else {
        return 0.5;
    }
}

@end
