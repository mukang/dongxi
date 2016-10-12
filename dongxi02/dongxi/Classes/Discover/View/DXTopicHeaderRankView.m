//
//  DXTopicHeaderRankView.m
//  dongxi
//
//  Created by 穆康 on 16/2/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicHeaderRankView.h"
#import "UIImage+Extension.h"
#import <UIImageView+WebCache.h>

#define IconWH      DXRealValue(28)  // 头像和图标的尺寸
#define IconMargin  DXRealValue(7)   // 头像或图标之间的距离

@interface DXTopicHeaderRankView ()

@property (nonatomic, weak) UIImageView *rankIcon;
@property (nonatomic, weak) UIImageView *moreIcon;
@property (nonatomic, strong) NSMutableArray *rankAvatars;

@end

@implementation DXTopicHeaderRankView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UIImageView *rankIcon = [[UIImageView alloc] init];
    rankIcon.image = [UIImage imageNamed:@"discover_topic_rank"];
    [self addSubview:rankIcon];
    
    UIImageView *moreIcon = [[UIImageView alloc] init];
    moreIcon.image = [UIImage imageNamed:@"discover_topic_rank_more"];
    [self addSubview:moreIcon];
    
    for (int i=0; i<3; i++) {
        DXAvatarView *avatarView = [[DXAvatarView alloc] init];
        [self addSubview:avatarView];
        [self.rankAvatars addObject:avatarView];
    }
    
    self.rankIcon = rankIcon;
    self.moreIcon = moreIcon;
}

- (void)setRank:(NSArray *)rank {
    _rank = rank;
    
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(IconWH, IconWH)];
    for (int i=0; i<rank.count; i++) {
        DXRankUser *rankUser = rank[i];
        DXAvatarView *avatarView = self.rankAvatars[i];
        [avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:rankUser.avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
        avatarView.verified = rankUser.verified;
        avatarView.certificationIconSize = DXCertificationIconSizeSmall;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSUInteger rankUserCount = self.rank.count;
    if (!rankUserCount) return;
    
    self.rankIcon.size = CGSizeMake(IconWH, IconWH);
    self.rankIcon.x = 0;
    self.rankIcon.centerY = self.height * 0.5;
    
    self.moreIcon.size = self.rankIcon.size;
    self.moreIcon.x = self.width - self.moreIcon.width;
    self.moreIcon.centerY = self.rankIcon.centerY;
    
    for (int i=0; i<rankUserCount; i++) {
        DXAvatarView *avatarView = self.rankAvatars[i];
        avatarView.size = self.rankIcon.size;
        avatarView.x = self.rankIcon.width + IconMargin + (avatarView.width + IconMargin) * i;
        avatarView.centerY = self.rankIcon.centerY;
    }
}

- (NSMutableArray *)rankAvatars {
    if (_rankAvatars == nil) {
        _rankAvatars = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return _rankAvatars;
}

@end
