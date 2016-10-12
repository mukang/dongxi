//
//  DXAvatarView.m
//  dongxi
//
//  Created by 穆康 on 15/12/31.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXAvatarView.h"
#import <UIImageView+WebCache.h>

#define IconSizeSmall    DXRealValue(10)     // 认证图标尺寸（小）
#define IconSizeMedium   DXRealValue(13)     // 认证图标尺寸（中）
#define IconSizeLarge    DXRealValue(15)     // 认证图标尺寸（大）

@interface DXAvatarView ()

@property (nonatomic, weak) UIView *borderView;

@end

@implementation DXAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    
    UIView *borderView = [[UIView alloc] init];
    borderView.backgroundColor = DXRGBColor(237, 238, 238);
    [self addSubview:borderView];
    self.borderView = borderView;
    
    UIImageView *avatarImageView = [[UIImageView alloc] init];
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:avatarImageView];
    self.avatarImageView = avatarImageView;
    
    UIImageView *certificationIconView = [[UIImageView alloc] init];
    [self addSubview:certificationIconView];
    self.certificationIconView = certificationIconView;
}

- (void)setCertificationIconHidden:(BOOL)certificationIconHidden {
    _certificationIconHidden = certificationIconHidden;
    
    if (certificationIconHidden) {
        self.certificationIconView.hidden = YES;
    } else {
        self.certificationIconView.hidden = NO;
    }
}

- (void)setVerified:(DXUserVerifiedType)verified {
    _verified = verified;
    
    if (self.certificationIconHidden) return;
    
    switch (verified) {
        case DXUserVerifiedTypeNone:
            self.certificationIconView.hidden = YES;
            break;
        case DXUserVerifiedTypeOfficial:
            self.certificationIconView.hidden = NO;
            self.certificationIconView.image = [UIImage imageNamed:@"certificationIconOfficial"];
            break;
            
        default:
            self.certificationIconView.hidden = YES;
            break;
    }
}

- (void)setCertificationIconSize:(DXCertificationIconSize)certificationIconSize {
    _certificationIconSize = certificationIconSize;
    
    switch (certificationIconSize) {
        case DXCertificationIconSizeSmall:
            self.certificationIconView.size = CGSizeMake(IconSizeSmall, IconSizeSmall);
            break;
        case DXCertificationIconSizeMedium:
            self.certificationIconView.size = CGSizeMake(IconSizeMedium, IconSizeMedium);
            break;
        case DXCertificationIconSizeLarge:
            self.certificationIconView.size = CGSizeMake(IconSizeLarge, IconSizeLarge);
            break;
            
        default:
            self.certificationIconView.size = CGSizeZero;
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.borderView.frame = self.bounds;
    self.borderView.layer.cornerRadius = self.borderView.width * 0.5;
    self.borderView.layer.masksToBounds = YES;
    
    self.avatarImageView.frame = CGRectInset(self.borderView.bounds, 1, 1);
    self.avatarImageView.center = self.borderView.center;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.width * 0.5f;
    self.avatarImageView.layer.masksToBounds = YES;
    
    self.certificationIconView.x = self.width - self.certificationIconView.width;
    self.certificationIconView.y = self.height - self.certificationIconView.height;
}

@end
