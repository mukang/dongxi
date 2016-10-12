//
//  DXFeedRecommendUserView.m
//  dongxi
//
//  Created by 穆康 on 16/3/14.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedRecommendUserView.h"
#import "UIImage+Extension.h"
#import <UIImageView+WebCache.h>

@interface DXFeedRecommendUserView ()

@property (nonatomic, weak) DXAvatarView *avatarView;
@property (nonatomic, weak) UILabel *nickLabel;

@end

@implementation DXFeedRecommendUserView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    DXAvatarView *avatarView = [[DXAvatarView alloc] init];
    [self addSubview:avatarView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarViewTapGesture:)];
    [avatarView addGestureRecognizer:tapGesture];
    
    UILabel *nickLabel = [[UILabel alloc] init];
    nickLabel.textColor = DXRGBColor(72, 72, 72);
    nickLabel.textAlignment = NSTextAlignmentCenter;
    nickLabel.font = [DXFont dxDefaultBoldFontWithSize:12];
    [self addSubview:nickLabel];
    
    self.avatarView = avatarView;
    self.nickLabel = nickLabel;
}

- (void)setUser:(DXUser *)user {
    _user = user;
    
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(50.0f), DXRealValue(50.0f))];
    [self.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarView.verified = user.verified;
    self.avatarView.certificationIconSize = DXCertificationIconSizeLarge;
    
    self.nickLabel.text = user.nick;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarView.size = CGSizeMake(DXRealValue(50), DXRealValue(50));
    self.avatarView.centerX = self.width * 0.5;
    self.avatarView.y = DXRealValue(38/3.0);
    
    self.nickLabel.width = self.width - DXRealValue(15);
    self.nickLabel.height = DXRealValue(20);
    self.nickLabel.centerX = self.avatarView.centerX;
    self.nickLabel.y = CGRectGetMaxY(self.avatarView.frame) + DXRealValue(5/3.0);
}

- (void)handleAvatarViewTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedRecommendUserView:didTapAvatarViewWithUser:)]) {
        [self.delegate feedRecommendUserView:self didTapAvatarViewWithUser:self.user];
    }
}

@end
