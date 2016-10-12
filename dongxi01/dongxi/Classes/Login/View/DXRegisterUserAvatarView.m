//
//  DXRegisterUserAvatarView.m
//  dongxi
//
//  Created by 穆康 on 16/1/6.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRegisterUserAvatarView.h"

#define AvatarImageMale     [UIImage imageNamed:@"register_user_avatar_male"]     // 男
#define AvatarImageFemale   [UIImage imageNamed:@"register_user_avatar_female"]   // 女
#define AvatarImageOther    [UIImage imageNamed:@"register_user_avatar_other"]    // 其他

@interface DXRegisterUserAvatarView ()


@end

@implementation DXRegisterUserAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UIImageView *avatarImageView = [[UIImageView alloc] init];
    [self addSubview:avatarImageView];
    self.avatarImageView = avatarImageView;
    
    UIImageView *addAvatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register_user_add_avatar"]];
    [self addSubview:addAvatarView];
    self.addAvatarView = addAvatarView;
}

- (void)setAvatarType:(DXRegisterUserAvatarType)avatarType {
    _avatarType = avatarType;
    
    if (self.isCustom) return;
    
    switch (avatarType) {
        case DXRegisterUserAvatarTypeMale:
            self.avatarImageView.image = AvatarImageMale;
            break;
        case DXRegisterUserAvatarTypeFemale:
            self.avatarImageView.image = AvatarImageFemale;
            break;
            
        default:
            self.avatarImageView.image = AvatarImageOther;
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.addAvatarView.frame = self.bounds;
    self.addAvatarView.layer.cornerRadius = self.addAvatarView.width * 0.5;
    self.addAvatarView.layer.masksToBounds = YES;
    
    self.avatarImageView.frame = self.bounds;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.width * 0.5;
    self.avatarImageView.layer.masksToBounds = YES;
}

@end
