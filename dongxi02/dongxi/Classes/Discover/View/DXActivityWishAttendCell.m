//
//  DXActivityWishAttendCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityWishAttendCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DXExtendButton.h"

@interface DXActivityWishAttendCell()

@property (nonatomic) DXExtendButton * moreWisherButton;
@property (nonatomic) UILabel * wisherCountLabel;
@property (nonatomic) UIView * avatarContainer;
@property (nonatomic) UIView * topContainer;
@property (nonatomic) CGSize avatarSize;
@property (nonatomic) BOOL isConstraintsSet;

@end


#define kDXActivityWishAttendCell_MaxAvatars  7

@implementation DXActivityWishAttendCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.frame = self.bounds;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.avatarSize = CGSizeMake(DXRealValue(120/3), DXRealValue(120/3));
        [self setupSubviews];
        
        [self setWisherCount:0];
    }
    return self;
}

- (void)updateConstraints {
    if (!self.isConstraintsSet) {
        [self setupConstraints];
        self.isConstraintsSet = YES;
    }
    
    [self setupAvatarConstraints];
    
    [super updateConstraints];
}

- (void)setupSubviews {
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:_containerView];
    
    self.topContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.topContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.wisherCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.wisherCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.moreWisherButton = [[DXExtendButton alloc] initWithFrame:CGRectZero];
    self.moreWisherButton.hitTestSlop = UIEdgeInsetsMake(-5, -5, -5, -5);
    [self.moreWisherButton setImage:[UIImage imageNamed:@"arrow_small_grew"] forState:UIControlStateNormal];
    [self.moreWisherButton addTarget:self action:@selector(moreWisherButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.moreWisherButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.avatarContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.avatarContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.topContainer addSubview:self.wisherCountLabel];
    [self.topContainer addSubview:self.moreWisherButton];
    
    [self.containerView addSubview:self.topContainer];
    [self.containerView addSubview:self.avatarContainer];

    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints {
    [self.containerView removeConstraints:self.containerView.constraints];

    NSDictionary * views = @{
                             @"topContainer"            : self.topContainer,
                             @"wisherCountLabel"        : self.wisherCountLabel,
                             @"moreWisherButton"        : self.moreWisherButton,
                             @"avatarContainer"         : self.avatarContainer
                             };
    NSDictionary * metrics = @{
                               @"wisherCountLabelTop"       : @(DXRealValue(62.0/3)),
                               @"avatarContainerTop"        : @(DXRealValue(180/3)),
                               @"avatarContainerBottom"     : @(DXRealValue(69.0/3))
                               };
    NSArray * visualFormats = @[
                                @"H:|[wisherCountLabel]-[moreWisherButton]|",
                                @"V:|[topContainer]",
                                @"V:|-wisherCountLabelTop-[wisherCountLabel]",
                                @"V:|-avatarContainerTop-[avatarContainer]-(>=avatarContainerBottom@500)-|"
                                ];
    for (NSString * vf in visualFormats) {
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views];
        [self.containerView addConstraints:constraints];
    }
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                      toItem:self.moreWisherButton
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.moreWisherButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.wisherCountLabel
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarContainer
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0]];
}

- (void)setupAvatarConstraints {
    [self.avatarContainer removeConstraints:self.avatarContainer.constraints];

    NSDictionary * metrics = @{
                               @"avatarViewHeight"                  : @(self.avatarSize.height),
                               @"avatarViewWidth"                   : @(self.avatarSize.width),
                               @"avatarViewMargin"                  : @(DXRealValue(20.0/3))
                               };
    NSMutableDictionary * constraintViews = [NSMutableDictionary dictionary];
    NSMutableString * horizonalVisualFormat = [[NSMutableString alloc] init];
    NSMutableArray * verticalVisualFormatList = [NSMutableArray array];
    
    NSArray * wisherAvatars = self.avatarContainer.subviews;
    
    for (NSInteger i = 0; i < wisherAvatars.count && i < kDXActivityWishAttendCell_MaxAvatars; i++) {
        DXAvatarView * avatarView = [wisherAvatars objectAtIndex:i];
        NSString * avatarViewName = [NSString stringWithFormat:@"avatarView%ld", (long)i];
        [constraintViews setObject:avatarView forKey:avatarViewName];
        
        if (wisherAvatars.count > 1) {
            if (i == 0) {
                [horizonalVisualFormat appendFormat:@"H:|[avatarView%ld(==avatarViewWidth)]", (long)i];
            } else if (i == wisherAvatars.count -1 || i == kDXActivityWishAttendCell_MaxAvatars - 1) {
                [horizonalVisualFormat appendFormat:@"-avatarViewMargin-[avatarView%ld(==avatarViewWidth)]|", (long)i];
            } else {
                [horizonalVisualFormat appendFormat:@"-avatarViewMargin-[avatarView%ld(==avatarViewWidth)]", (long)i];
            }
        } else {
            [horizonalVisualFormat appendFormat:@"H:|[avatarView%ld(==avatarViewWidth)]|", (long)i];
        }
        [verticalVisualFormatList addObject:[NSString stringWithFormat:@"V:|[avatarView%ld(==avatarViewHeight)]|", (long)i]];
    }
    
    if (horizonalVisualFormat.length > 0) {
        [self.avatarContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizonalVisualFormat options:0 metrics:metrics views:constraintViews]];
    }
    
    for (NSString * vf in verticalVisualFormatList) {
        [self.avatarContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:constraintViews]];
    }
}

- (void)prepareAvatarsIfNeeded:(NSUInteger)avatarCount {
    if (avatarCount == self.avatarContainer.subviews.count) {
        return;
    }

    for (UIView * avatarView in self.avatarContainer.subviews) {
        [avatarView removeFromSuperview];
    }
    
    DXAvatarView * lastAvatarView = nil;
    
    for (NSInteger i = 0; i < avatarCount && i < kDXActivityWishAttendCell_MaxAvatars; i++) {
        DXAvatarView * avatarView = [[DXAvatarView alloc] initWithFrame:CGRectZero];
        avatarView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
        [avatarView addGestureRecognizer:tap];
        avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.avatarContainer addSubview:avatarView];
        
        lastAvatarView = avatarView;
    }

    if (avatarCount >= kDXActivityWishAttendCell_MaxAvatars) {
        UILabel * maskView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.avatarSize.width, self.avatarSize.height)];
        if (self.wisherCount <= 99) {
            maskView.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.wisherCount];
        } else {
            maskView.text = @"99+";
        }
        maskView.textColor = [UIColor whiteColor];
        maskView.font = [DXFont dxDefaultFontWithSize:18];
        maskView.textAlignment = NSTextAlignmentCenter;
        maskView.adjustsFontSizeToFitWidth = YES;
        maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
        [lastAvatarView.avatarImageView addSubview:maskView];
        lastAvatarView.certificationIconHidden = YES;
    }
    
    [self setNeedsUpdateConstraints];
}


#pragma mark - Property Methods

- (void)setWisherCount:(NSUInteger)wisherCount {
    _wisherCount = wisherCount;
    
    [self prepareAvatarsIfNeeded:wisherCount];

    NSString * numberString = [NSString stringWithFormat:@"%lu", (unsigned long)wisherCount];
    NSString * fullString = [NSString stringWithFormat:@"%@人想去", numberString];
    NSUInteger numberStringLength = numberString.length;
    NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:fullString];
    [attributedText setAttributes:@{
                                    NSFontAttributeName : [DXFont fontWithName:DXCommonFontName size:20],
                                    NSForegroundColorAttributeName : DXRGBColor(72, 72, 72)
                                    }
                            range:NSMakeRange(0, numberStringLength)];
    [attributedText setAttributes:@{
                                    NSFontAttributeName : [DXFont fontWithName:DXCommonFontName size:15],
                                    NSForegroundColorAttributeName : DXRGBColor(143, 143, 143)
                                    }
                            range:NSMakeRange(numberStringLength, fullString.length-numberStringLength)];
    self.wisherCountLabel.attributedText = attributedText;
}

- (void)setWisherAvatars:(NSArray *)wisherAvatars {
    [self prepareAvatarsIfNeeded:wisherAvatars.count];

    _wisherAvatars = wisherAvatars;
    for (int i = 0; i < self.avatarContainer.subviews.count; i++) {
        DXAvatarView * avatarView = [self.avatarContainer.subviews objectAtIndex:i];
        DXActivityWantUserInfo *userInfo = [wisherAvatars objectAtIndex:i];
        NSURL * avatarURL = [NSURL URLWithString:userInfo.avatar];
        [avatarView.avatarImageView sd_setImageWithURL:avatarURL];
        avatarView.verified = userInfo.verified;
        avatarView.certificationIconSize = DXCertificationIconSizeMedium;
    }
}


#pragma mark - Internal Action

- (void)moreWisherButtonTapped:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wishAttendCell:didSelectMoreButton:)]) {
        [self.delegate wishAttendCell:self didSelectMoreButton:sender];
    }
}

- (void)avatarTapped:(UITapGestureRecognizer *)tap {
    DXAvatarView *avatarView = (DXAvatarView *)tap.view;
    NSInteger index = avatarView.tag;
    if (index == kDXActivityWishAttendCell_MaxAvatars - 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(wishAttendCell:didSelectMoreButton:)]) {
            [self.delegate wishAttendCell:self didSelectMoreButton:avatarView];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(wishAttendCell:didSelectAvatarAtIndex:)]) {
            [self.delegate wishAttendCell:self didSelectAvatarAtIndex:index];
        }
    }
}

@end
