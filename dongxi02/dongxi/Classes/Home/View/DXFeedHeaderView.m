//
//  DXFeedHeaderView.m
//  dongxi
//
//  Created by 穆康 on 15/9/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedHeaderView.h"
#import <UIImageView+WebCache.h>
#import "DXDongXiApi.h"
#import "UIResponder+Router.h"
#import "DXFeedTopicView.h"
#import "UIImage+Extension.h"
#import "DXUserInfoManager.h"
#import "DXAvatarView.h"

NSString *const kRouterEventAvatarViewDidTapEventName = @"kRouterEventAvatarViewDidTapEventName";
NSString *const kRouterEventTopicViewDidTapEventName = @"kRouterEventTopicViewDidTapEventName";

@interface DXFeedHeaderView ()

/** 头像 */
@property (nonatomic, weak) DXAvatarView *avatarV;
/** 昵称 */
@property (nonatomic, weak) UILabel *nickL;
/** 话题 */
@property (nonatomic, weak) DXFeedTopicView *topicV;

@end

@implementation DXFeedHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    // 头像
    DXAvatarView *avatarV = [[DXAvatarView alloc] init];
    [self addSubview:avatarV];
    self.avatarV = avatarV;
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewDidTap)];
    [avatarV addGestureRecognizer:avatarTap];
    
    // 昵称
    UILabel *nickL = [[UILabel alloc] init];
    nickL.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(17)];
    [self addSubview:nickL];
    self.nickL = nickL;
    
    // 话题
    DXFeedTopicView *topicV = [[DXFeedTopicView alloc] init];
    topicV.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    UITapGestureRecognizer *topicTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topicViewDidTap)];
    [topicV addGestureRecognizer:topicTap];
    [self addSubview:topicV];
    self.topicV = topicV;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 头像
    CGFloat avatarVX = DXRealValue(13);
    CGFloat avatarVY = DXRealValue(13);
    CGFloat avatarVW = DXRealValue(50);
    CGFloat avatarVH = DXRealValue(50);
    self.avatarV.frame = CGRectMake(avatarVX, avatarVY, avatarVW, avatarVH);
    
    // 昵称
    CGFloat nickLX = DXRealValue(76.0f);
    CGFloat nickLY = DXRealValue(15.0f);
    CGFloat nickLW = self.width - nickLX - DXRealValue(13.0f);
    CGFloat nickLH = DXRealValue(19.0f);
    self.nickL.frame = CGRectMake(nickLX, nickLY, nickLW, nickLH);
    
    // 话题
    CGFloat topicLX = nickLX;
    CGFloat topicLY = DXRealValue(41);
    self.topicV.origin = CGPointMake(topicLX, topicLY);
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    // 头像
    NSString * avatar = [DXUserInfoManager getNewestAvatarWithCurrentAvatar:feed.avatar updateTime:feed.getFeedTime forUID:feed.uid];
    NSURL *avatarUrl = [NSURL URLWithString:avatar];
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(50.0f), DXRealValue(50.0f))];
    [self.avatarV.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarV.verified = feed.verified;
    self.avatarV.certificationIconSize = DXCertificationIconSizeLarge;
    
    // 昵称
    NSString * nick = [DXUserInfoManager getNewestNicknameWithCurrentNickname:feed.nick updateTime:feed.getFeedTime forUID:feed.uid];
    self.nickL.text = nick;
    
    [self.nickL hookNicknameTextForUID:feed.uid];
    [self.avatarV.avatarImageView hookAvatarImageForUID:feed.uid];
    
    // 话题
    if (!feed.data.topic.topic) {
        self.topicV.hidden = YES;
    } else {
        self.topicV.hidden = NO;
        self.topicV.text = [NSString stringWithFormat:@"#%@#", feed.data.topic.topic];
    }
    [self.topicV sizeToFit];
}

+ (CGFloat)heightForHeaderViewWithFeed:(DXTimelineFeed *)feed {
    
    return DXRealValue(76);
}

/**
 *  点击了头像
 */
- (void)avatarViewDidTap {
    
    if (self.feed) {
        NSDictionary *info = @{kFeedKey: self.feed};
        [self routerEventWithName:kRouterEventAvatarViewDidTapEventName userInfo:info];
    }
}

/**
 *  点击了话题
 */
- (void)topicViewDidTap {
    
    if (self.feed) {
        NSDictionary *info = @{kFeedKey: self.feed};
        [self routerEventWithName:kRouterEventTopicViewDidTapEventName userInfo:info];
    }
}

@end
