//
//  DXRankUserBaseCell.m
//  dongxi
//
//  Created by 穆康 on 16/3/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRankUserBaseCell.h"
#import "DXButton.h"
#import "UIImage+Extension.h"
#import <UIImageView+WebCache.h>

#define RelationImageUnfollow    [UIImage imageNamed:@"attention_add"]              // 未关注
#define RelationImageFollowed    [UIImage imageNamed:@"attention_ok"]               // 已关注
#define RelationImageFriend      [UIImage imageNamed:@"attention_mutual"]           // 互相关注

@interface DXRankUserBaseCell ()

@property (nonatomic, weak) DXAvatarView *avatarView;
@property (nonatomic, weak) UILabel *nickLabel;
@property (nonatomic, weak) DXButton *followBtn;
@property (nonatomic, weak) UIView *separateView;

@end

@implementation DXRankUserBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *rankNumView = [[UIImageView alloc] init];
        [self.contentView addSubview:rankNumView];
        
        UILabel *rankNumLabel = [[UILabel alloc] init];
        rankNumLabel.textColor = DXCommonColor;
        rankNumLabel.font = [DXFont dxDefaultFontWithSize:24];
        [self.contentView addSubview:rankNumLabel];
        
        DXAvatarView *avatarView = [[DXAvatarView alloc] init];
        [self.contentView addSubview:avatarView];
        UITapGestureRecognizer *avatarViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelAvatarViewTap)];
        [avatarView addGestureRecognizer:avatarViewTap];
        
        UILabel *nickLabel = [[UILabel alloc] init];
        nickLabel.textColor = DXRGBColor(72, 72, 72);
        nickLabel.font = [DXFont dxDefaultFontWithSize:17];
        [self.contentView addSubview:nickLabel];
        
        DXButton *followBtn = [DXButton buttonWithType:UIButtonTypeCustom];
        [followBtn addTarget:self action:@selector(handelFollowBtnTap) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:followBtn];
        
        UIView *separateView = [[UIView alloc] init];
        separateView.backgroundColor = DXRGBColor(222, 222, 222);
        [self.contentView addSubview:separateView];
        
        self.rankNumView = rankNumView;
        self.rankNumLabel = rankNumLabel;
        self.avatarView = avatarView;
        self.nickLabel = nickLabel;
        self.followBtn = followBtn;
        self.separateView = separateView;
    }
    return self;
}

- (void)setRankUser:(DXRankUser *)rankUser {
    _rankUser = rankUser;
    
    CGFloat avatarViewWH = DXRealValue(50);
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(avatarViewWH, avatarViewWH)];
    [self.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:rankUser.avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarView.verified = rankUser.verified;
    self.avatarView.certificationIconSize = DXCertificationIconSizeLarge;
    
    self.nickLabel.text = rankUser.nick;
    [self.nickLabel sizeToFit];
    
    self.relation = rankUser.relations;
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
    
    CGFloat centerX = DXRealValue(23);
    CGFloat centerY = self.contentView.height * 0.5;
    
    CGSize originSize = self.rankNumView.image.size;
    self.rankNumView.size = CGSizeMake(DXRealValue(originSize.width), DXRealValue(originSize.height));
    self.rankNumView.center = CGPointMake(centerX, centerY);
    
    self.rankNumLabel.center = CGPointMake(centerX, centerY);
    
    self.avatarView.size = CGSizeMake(DXRealValue(50), DXRealValue(50));
    self.avatarView.x = DXRealValue(160/3.0);
    self.avatarView.centerY = centerY;
    
    self.nickLabel.x = CGRectGetMaxX(self.avatarView.frame) + DXRealValue(13);
    self.nickLabel.y = DXRealValue(12);
    
    self.followBtn.size = CGSizeMake(DXRealValue(58), DXRealValue(33));
    self.followBtn.x = self.contentView.width - DXRealValue(13) - self.followBtn.width;
    self.followBtn.centerY = centerY;
    
    self.separateView.size = CGSizeMake(self.contentView.width, 0.5);
    self.separateView.origin = CGPointMake(0, self.contentView.height - self.separateView.height);
}

- (void)handelAvatarViewTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rankUserCell:didTapAvatarViewWithUserID:)]) {
        [self.delegate rankUserCell:self didTapAvatarViewWithUserID:self.rankUser.uid];
    }
}

- (void)handelFollowBtnTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rankUserCell:didTapFollowBtnWithRankUser:)]) {
        [self.delegate rankUserCell:self didTapFollowBtnWithRankUser:self.rankUser];
    }
}

@end
