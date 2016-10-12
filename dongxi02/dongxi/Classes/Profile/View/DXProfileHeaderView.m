//
//  DXProfileHeaderView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/6.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileHeaderView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DXProfileHeaderView ()

@property (nonatomic, strong) UIImageView * genderImageView;
/** 认证图标 */
@property (nonatomic, weak) UIImageView *certificationIconView;
/** 认证标签 */
@property (nonatomic, weak) UIImageView *certificationTagView;

@property (nonatomic, strong) UILabel * lineLabel;

@end

@implementation DXProfileHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        self.followCount = 0;
        self.fansCount = 0;
    }
    return self;
}


- (void)setupSubviews {
    CGFloat fullWidth = CGRectGetWidth(self.bounds);
    CGFloat fullHeight = CGRectGetHeight(self.bounds);
    
    // 标签栏 ***
    const CGFloat tabBarHeight = DXRealValue(44);
    DXTabBarView *tabBarView = [[DXTabBarView alloc] initWithFrame:CGRectMake(0, fullHeight-tabBarHeight, fullWidth, tabBarHeight)
                                                       tabCount:2
                                                          names:@[@"我参与的", @"我收藏的"]];
    tabBarView.backgroundColor = DXNavBarColor;
    tabBarView.contentInsets = UIEdgeInsetsMake(0, DXRealValue(50), 0, DXRealValue(50));
    tabBarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:tabBarView];

    //用户头像白边  ***
    CGFloat avatarBackgroundLength = DXRealValue(242.0/3);
    UIView *avatarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, avatarBackgroundLength, avatarBackgroundLength)];
    avatarBackgroundView.backgroundColor = [UIColor whiteColor];
    avatarBackgroundView.centerX = fullWidth/2 ;
    avatarBackgroundView.y = 72;
    avatarBackgroundView.layer.cornerRadius = avatarBackgroundLength/2;
    avatarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:avatarBackgroundView];
    
    //用户头像  ***
    CGRect avatarViewFrame = CGRectInset(avatarBackgroundView.bounds, DXRealValue(4.0/3), DXRealValue(4.0/3));
    UIImageView * avatarView = [[UIImageView alloc] initWithFrame:avatarViewFrame];
    avatarView.center = avatarBackgroundView.center;
    avatarView.backgroundColor = DXRGBColor(222, 222, 222);
    avatarView.layer.cornerRadius = avatarViewFrame.size.width/2;
    avatarView.contentMode = UIViewContentModeScaleAspectFill;
    avatarView.layer.masksToBounds = YES;
    avatarView.userInteractionEnabled = YES;
    avatarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:avatarView];
    
    //认证图标  ***
    UIImageView *certificationIconView = [[UIImageView alloc] init];
    CGFloat certificationIconViewWH = DXRealValue(21);
    CGFloat certificationIconViewX = CGRectGetMaxX(avatarView.frame) - certificationIconViewWH;
    CGFloat certificationIconViewY = CGRectGetMaxY(avatarView.frame) - certificationIconViewWH;
    certificationIconView.frame = CGRectMake(certificationIconViewX, certificationIconViewY, certificationIconViewWH, certificationIconViewWH);
    certificationIconView.layer.cornerRadius = certificationIconViewWH * 0.5;
    certificationIconView.layer.masksToBounds = YES;
    certificationIconView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:certificationIconView];
    certificationIconView.hidden = YES;
    
    //认证标签  ***
    UIImageView *certificationTagView = [[UIImageView alloc] init];
    CGFloat certificationTagViewW = DXRealValue(63);
    CGFloat certificationTagViewH = DXRealValue(24);
    CGFloat certificationTagViewX = DXScreenWidth - certificationTagViewW;
    CGFloat certificationTagViewY = 150;
    certificationTagView.frame = CGRectMake(certificationTagViewX, certificationTagViewY, certificationTagViewW, certificationTagViewH);
    certificationTagView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:certificationTagView];
    certificationTagView.hidden = YES;
    
//    //用户性别  ***
//    UIImageView *genderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Personal_girl"]];
//    genderImageView.width = DXRealValue(19);
//    genderImageView.height = DXRealValue(19);
//    genderImageView.center = CGPointMake(avatarBackgroundView.centerX + avatarBackgroundLength*0.5*0.707,
//                                         avatarBackgroundView.centerY + avatarBackgroundLength*0.5*0.707);
//    genderImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    genderImageView.hidden = YES;
//    [self addSubview:genderImageView];
    
    // 聊天按钮  ***
    CGFloat chatBtnRightMargin = DXRealValue(118.0/3);
    CGFloat followBtnLeftMargin = chatBtnRightMargin;
    CGFloat halfAvatarWidth = avatarBackgroundLength/2;
    UIImage * chatImage = [UIImage imageNamed:@"Personal_chat_icon"];
    CGFloat chatBtnWidth = DXRealValue(chatImage.size.width);
    CGFloat chatBtnHeight = DXRealValue(chatImage.size.height);
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [chatButton setImage:chatImage forState:UIControlStateNormal];
    [chatButton setBounds:CGRectMake(0, 0, chatBtnWidth, chatBtnHeight)];
    chatButton.x = fullWidth/2 - halfAvatarWidth - chatBtnWidth - chatBtnRightMargin;
    chatButton.centerY = avatarBackgroundView.centerY;
    chatButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    chatButton.hidden = YES;
    [self addSubview:chatButton];
    
    // 关注按钮  ***
    UIImage * followImage = [UIImage imageNamed:@"attention_add_2"];
    CGFloat followBtnWidth = DXRealValue(followImage.size.width);
    CGFloat followBtnHeight = DXRealValue(followImage.size.height);
    UIButton *followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [followBtn setImage:followImage forState:UIControlStateNormal];
    followBtn.bounds = CGRectMake(0, 0, followBtnWidth, followBtnHeight);
    followBtn.x = fullWidth/2 + halfAvatarWidth + followBtnLeftMargin;
    followBtn.centerY = avatarBackgroundView.centerY;
    followBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    followBtn.hidden = YES;
    [self addSubview:followBtn];
    
    //用户个签  ***
    UILabel *bioLabel = [[UILabel alloc] init];
    bioLabel.y = DXRealValue(655.0/3);
    bioLabel.textAlignment = NSTextAlignmentCenter;
    bioLabel.numberOfLines = 2;
    bioLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    bioLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    bioLabel.textColor = [UIColor whiteColor];
    bioLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:bioLabel];
    
    //关注字符  ***
    UILabel *followLabel = [[UILabel alloc] init];
    followLabel.textAlignment = NSTextAlignmentRight;
    followLabel.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(15)];
    followLabel.textColor = [UIColor whiteColor];
    followLabel.userInteractionEnabled = YES;
    followLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:followLabel];
    
    //粉丝字符  ***
    UILabel *fansLabel = [[UILabel alloc] init];
    fansLabel.textAlignment = NSTextAlignmentLeft;
    fansLabel.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(15)];
    fansLabel.textColor = [UIColor whiteColor];
    fansLabel.userInteractionEnabled = YES;
    fansLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:fansLabel];
    
    //分割线  ***
    UILabel *lineLabel = [[UILabel alloc] init];
    lineLabel.text = @"|";
    [lineLabel sizeToFit];
    lineLabel.centerX = avatarBackgroundView.centerX;
    lineLabel.y = DXRealValue(185);
    lineLabel.textAlignment = NSTextAlignmentCenter;
    lineLabel.numberOfLines = 0;
    lineLabel.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(15)];
    lineLabel.textColor = [UIColor whiteColor];
    lineLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:lineLabel];
    
    _switchTabBarView = tabBarView;
    _avatarView = avatarView;
//    _genderImageView = genderImageView;
    _certificationIconView = certificationIconView;
    _certificationTagView = certificationTagView;
    _chatButton = chatButton;
    _followButton = followBtn;
    _bioLabel = bioLabel;
    _lineLabel = lineLabel;
    _followLabel = followLabel;
    _fansLabel = fansLabel;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView * subview in self.subviews) {
        CGRect viewFrame = subview.frame;
        if (!subview.hidden && CGRectContainsPoint(viewFrame, point)) {
            if ([subview isKindOfClass:[UIControl class]]) {
                UIControl * subControl = (UIControl *)subview;
                if (!subControl.enabled) {
                    continue;
                }
            }
            CGPoint subviewPoint = [self convertPoint:point toView:subview];
            return [subview pointInside:subviewPoint withEvent:event];
        }
    }
    return NO;
}


- (void)setHideSocialButtons:(BOOL)hideSocialButtons {
    _hideSocialButtons = hideSocialButtons;
    
    self.chatButton.hidden = hideSocialButtons;
    self.followButton.hidden = hideSocialButtons;
}

- (void)setShowAvatarOnly:(BOOL)showAvatarOnly {
    _showAvatarOnly = showAvatarOnly;
    
    if (showAvatarOnly) {
        [self bringSubviewToFront:self.avatarView];
    } else {
        [self insertSubview:self.avatarView belowSubview:self.certificationIconView];
    }
}

- (void)setFansCount:(NSUInteger)fansCount {
    _fansCount = fansCount;
    
    const CGFloat fullWidth = CGRectGetWidth(self.bounds);
    self.fansLabel.text = [NSString stringWithFormat:@"粉丝 %lu", (unsigned long)fansCount];
    [self.fansLabel sizeToFit];
    const CGFloat height = CGRectGetHeight(self.fansLabel.bounds);
    const CGFloat width = CGRectGetWidth(self.fansLabel.bounds);
    const CGFloat x = fullWidth/2 + DXRealValue(10);
    self.fansLabel.frame = CGRectMake(x, 0, width, height);
    self.fansLabel.centerY = self.lineLabel.centerY;
}

- (void)setFollowCount:(NSUInteger)followCount {
    _followCount = followCount;
    
    const CGFloat fullWidth = CGRectGetWidth(self.bounds);
    self.followLabel.text = [NSString stringWithFormat:@"关注 %lu", (unsigned long)followCount];
    [self.followLabel sizeToFit];
    const CGFloat height = CGRectGetHeight(self.followLabel.bounds);
    const CGFloat width = CGRectGetWidth(self.followLabel.bounds);
    const CGFloat x = fullWidth/2 - width - DXRealValue(10);
    self.followLabel.frame = CGRectMake(x, 0, width, height);
    self.followLabel.centerY = self.lineLabel.centerY;
}

//- (void)setGender:(DXUserGenderType)gender {
//    _gender = gender;
//    
//    if (gender == DXUserGenderTypeFemale) {
//        self.genderImageView.hidden = NO;
//        [self.genderImageView setImage:[UIImage imageNamed:@"Personal_girl"]];
//    }else if (gender == DXUserGenderTypeMale){
//        self.genderImageView.hidden = NO;
//        [self.genderImageView setImage:[UIImage imageNamed:@"Personal_boy"]];
//    }else{
//        self.genderImageView.hidden = YES;
//    }
//}

- (void)setRelation:(DXUserRelationType)relation {
    _relation = relation;
    
    self.hideSocialButtons = NO;
    
    UIImage * image = nil;
    switch (relation) {
        case DXUserRelationTypeFollowed:
            image = [UIImage imageNamed:@"attention_ok_2"];
            break;
        case DXUserRelationTypeFriend:
            image = [UIImage imageNamed:@"attention_mutual_2"];
            break;
        case DXUserRelationTypeFollower:
        case DXUserRelationTypeNone:
            image = [UIImage imageNamed:@"attention_add_2"];
            break;
        default:
            self.hideSocialButtons = YES;
            break;
    }
    [self.followButton setImage:image forState:UIControlStateNormal];
}

- (void)setBio:(NSString *)bio {
    _bio = bio;
    
    const CGFloat maxWidth = DXScreenWidth - DXRealValue(88);
    self.bioLabel.text = bio;
    CGSize size = [self.bioLabel sizeThatFits:CGSizeMake(maxWidth, DXRealValue(45))];
    CGRect frame = self.bioLabel.frame;
    frame.origin.x = (DXScreenWidth - size.width)/2;
    frame.size = size;
    self.bioLabel.frame = frame;
}

- (void)setAvatar:(NSString *)avatar {
    _avatar = avatar;
    
    NSURL *avatarURL = [NSURL URLWithString:avatar];
    [self.avatarView sd_setImageWithURL:avatarURL];
}

- (void)setVerified:(DXUserVerifiedType)verified {
    _verified = verified;
    
    switch (verified) {
        case DXUserVerifiedTypeNone:
            self.certificationIconView.hidden = YES;
            self.certificationTagView.hidden = YES;
            break;
        case DXUserVerifiedTypeOfficial:
            self.certificationIconView.hidden = NO;
            self.certificationTagView.hidden = NO;
            self.certificationIconView.image = [UIImage imageNamed:@"certificationIconOfficial"];
            self.certificationTagView.image = [UIImage imageNamed:@"certificationIconOfficialTag"];
            break;
            
        default:
            self.certificationIconView.hidden = YES;
            self.certificationTagView.hidden = YES;
            break;
    }
}

- (void)setProfile:(DXUserProfile *)profile {
    _profile = profile;
    
    if (profile) {
        self.genderImageView.hidden = NO;
        self.chatButton.hidden = NO;
        self.followButton.hidden = NO;
        
        self.followCount = profile.follows;
        self.fansCount = profile.fans;
//        self.gender = profile.gender;
        self.relation = profile.relations;
        self.bio = profile.bio;
        self.avatar = profile.avatar;
        self.verified = profile.verified;
    }
}

@end
