//
//  DXFeedHeaderViewV2.m
//  dongxi
//
//  Created by 穆康 on 16/8/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedHeaderViewV2.h"
#import "DXAvatarView.h"
#import "DXButton.h"
#import "UIImage+Extension.h"
#import <UIImageView+WebCache.h>

#define RelationImageUnfollow    [UIImage imageNamed:@"attention_add_v2"]              // 未关注
#define RelationImageFollowed    [UIImage imageNamed:@"attention_ok_v2"]               // 已关注
#define RelationImageFriend      [UIImage imageNamed:@"attention_mutual_v2"]           // 互相关注

@interface DXFeedHeaderViewV2 ()

@property (nonatomic, weak) DXAvatarView *avatarView;
@property (nonatomic, weak) UIButton *nickBtn;
@property (nonatomic, weak) DXButton *followBtn;

@end

@implementation DXFeedHeaderViewV2

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    
    DXAvatarView *avatarView = [[DXAvatarView alloc] init];
    [self addSubview:avatarView];
    UITapGestureRecognizer *avatarViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelAvatarViewTap:)];
    [avatarView addGestureRecognizer:avatarViewTap];
    
    UIButton *nickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nickBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    nickBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [nickBtn setTitleColor:DXRGBColor(72, 72, 72) forState:UIControlStateNormal];
    [nickBtn addTarget:self action:@selector(handelNickBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nickBtn];
    
    DXButton *followBtn = [DXButton buttonWithType:UIButtonTypeCustom];
    [followBtn addTarget:self action:@selector(handelFollowBtnTap:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:followBtn];
    
    self.avatarView = avatarView;
    self.nickBtn = nickBtn;
    self.followBtn = followBtn;
}

- (void)setFeed:(DXFeed *)feed {
    _feed = feed;
    
    CGFloat avatarViewWH = 27;
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(avatarViewWH, avatarViewWH)];
    [self.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:feed.creator.avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarView.verified = feed.current_user.verified;
    self.avatarView.certificationIconSize = DXCertificationIconSizeSmall;
    
    [self.nickBtn setTitle:feed.creator.nick forState:UIControlStateNormal];
    
    self.relation = feed.current_user.relations;
}

- (void)setRelation:(DXUserRelationType)relation {
    _relation = relation;
    
    self.followBtn.hidden = NO;
    
    switch (relation) {
        case DXUserRelationTypeNone:
            [self.followBtn setImage:RelationImageUnfollow forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeFollower:
            [self.followBtn setImage:RelationImageUnfollow forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeFollowed:
            [self.followBtn setImage:RelationImageFollowed forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeFriend:
            [self.followBtn setImage:RelationImageFriend forState:UIControlStateNormal];
            break;
        default:
            self.followBtn.hidden = YES;
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarView.size = CGSizeMake(27, 27);
    self.avatarView.x = 13;
    self.avatarView.centerY = self.height * 0.5;
    
    self.followBtn.size = CGSizeMake(158/3.0, 25);
    self.followBtn.x = self.width - 14 - self.followBtn.width;
    self.followBtn.centerY = self.avatarView.centerY;
    
    self.nickBtn.x = CGRectGetMaxX(self.avatarView.frame) + 8;
    self.nickBtn.y = 0;
    self.nickBtn.width = self.width - self.nickBtn.x - self.followBtn.width - 20;
    self.nickBtn.height = self.height;
}

- (void)handelAvatarViewTap:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedHeaderViewV2:didTapAvatarViewWithFeed:)]) {
        [self.delegate feedHeaderViewV2:self didTapAvatarViewWithFeed:self.feed];
    }
}

- (void)handelNickBtnTap:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedHeaderViewV2:didTapNickBtnWithFeed:)]) {
        [self.delegate feedHeaderViewV2:self didTapNickBtnWithFeed:self.feed];
    }
}

- (void)handelFollowBtnTap:(DXButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedHeaderViewV2:didTapFollowBtnWithFeed:)]) {
        [self.delegate feedHeaderViewV2:self didTapFollowBtnWithFeed:self.feed];
    }
}

@end
