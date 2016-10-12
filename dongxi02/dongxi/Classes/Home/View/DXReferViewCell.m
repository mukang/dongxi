//
//  DXReferViewCell.m
//  dongxi
//
//  Created by 穆康 on 16/5/9.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXReferViewCell.h"
#import "UIImage+Extension.h"
#import <UIImageView+WebCache.h>

@interface DXReferViewCell ()

/** 头像 */
@property (nonatomic, weak) DXAvatarView *avatarView;
/** 昵称 */
@property (nonatomic, weak) UILabel *nickLabel;
/** 话题图片 */
@property (nonatomic, weak) UIImageView *topicImageView;
/** 话题名称 */
@property (nonatomic, weak) UILabel *topicTitleLabel;

@end

@implementation DXReferViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier referType:(DXReferType)referType {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _referType = referType;
        [self setup];
    }
    return self;
}

- (void)setup {
    
    if (self.referType == DXReferTypeUser) {
        // 头像
        DXAvatarView *avatarView = [[DXAvatarView alloc] init];
        [self.contentView addSubview:avatarView];
        self.avatarView = avatarView;
        // 昵称
        UILabel *nickLabel = [[UILabel alloc] init];
        nickLabel.textColor = DXRGBColor(72, 72, 72);
        nickLabel.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(15)];
        [self.contentView addSubview:nickLabel];
        self.nickLabel = nickLabel;
    } else {
        // 话题图片
        UIImageView *topicImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:topicImageView];
        self.topicImageView = topicImageView;
        // 话题名称
        UILabel *topicTitleLabel = [[UILabel alloc] init];
        topicTitleLabel.textColor = DXRGBColor(66, 189, 205);
        topicTitleLabel.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(15)];
        [self.contentView addSubview:topicTitleLabel];
        self.topicTitleLabel = topicTitleLabel;
    }
}

- (void)setReferUser:(DXUser *)referUser {
    _referUser = referUser;
    if (self.referType != DXReferTypeUser) return;
    
    // 头像
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(40.0f), DXRealValue(40.0f))];
    [self.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:referUser.avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarView.verified = referUser.verified;
    self.avatarView.certificationIconSize = DXCertificationIconSizeMedium;
    // 昵称
    self.nickLabel.text = referUser.nick;
    [self.nickLabel sizeToFit];
}

- (void)setReferTopic:(DXTopic *)referTopic {
    _referTopic = referTopic;
    if (self.referType != DXReferTypeTopic) return;
    
    // 话题图片
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(40.0f), DXRealValue(40.0f))];
    [self.topicImageView sd_setImageWithURL:[NSURL URLWithString:referTopic.thumb] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    // 话题名称
    self.topicTitleLabel.text = [NSString stringWithFormat:@"#%@#", referTopic.topic];
    [self.topicTitleLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.referType == DXReferTypeUser) {
        // 头像
        self.avatarView.size = CGSizeMake(DXRealValue(40), DXRealValue(40));
        self.avatarView.x = DXRealValue(13);
        self.avatarView.centerY = self.contentView.height * 0.5;
        // 昵称
        self.nickLabel.x = CGRectGetMaxX(self.avatarView.frame) + DXRealValue(17);
        self.nickLabel.centerY = self.avatarView.centerY;
    } else {
        // 话题图片
        self.topicImageView.size = CGSizeMake(DXRealValue(43), DXRealValue(43));
        self.topicImageView.x = DXRealValue(13);
        self.topicImageView.centerY = self.contentView.height * 0.5;
        // 话题名称
        self.topicTitleLabel.x = CGRectGetMaxX(self.topicImageView.frame) + DXRealValue(10);
        self.topicTitleLabel.centerY = self.topicImageView.centerY;
    }
}

@end
