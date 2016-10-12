//
//  DXTopicUserInviteCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/29.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicUserInviteCell.h"

@implementation DXTopicUserInviteCell {
    BOOL isConstraintsSet;
    DXAvatarView * avatarView;
    UILabel * nickLabel;
    UILabel * locationLabel;
    UIButton * inviteButton;
    UIView * bottomShadow;
}

@synthesize avatarView = avatarView;

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    UITapGestureRecognizer * avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];

    avatarView = [[DXAvatarView alloc] initWithFrame:CGRectZero];
//    avatarView.backgroundColor = DXRGBColor(221, 221, 221);
    [avatarView addGestureRecognizer:avatarTap];
    avatarView.translatesAutoresizingMaskIntoConstraints = NO;

    nickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nickLabel.font = [DXFont dxDefaultBoldFontWithSize:20.0f];
    nickLabel.textColor = DXRGBColor(72, 72, 72);
    nickLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    locationLabel.font = [DXFont dxDefaultFontWithSize:15.0f];
    locationLabel.textColor = DXCommonColor;
    locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    inviteButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [inviteButton setImage:[UIImage imageNamed:@"button_invite"] forState:UIControlStateNormal];
    [inviteButton setImage:[UIImage imageNamed:@"button_invited_unable"] forState:UIControlStateDisabled];
    [inviteButton addTarget:self action:@selector(inviteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    inviteButton.translatesAutoresizingMaskIntoConstraints = NO;

    bottomShadow = [[UIView alloc] initWithFrame:CGRectZero];
    bottomShadow.backgroundColor = DXRGBColor(221, 221, 221);
    bottomShadow.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:avatarView];
    [self.contentView addSubview:nickLabel];
    [self.contentView addSubview:locationLabel];
    [self.contentView addSubview:inviteButton];
    [self.contentView addSubview:bottomShadow];

    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints {
    NSDictionary * views = NSDictionaryOfVariableBindings(avatarView, nickLabel, locationLabel, inviteButton, bottomShadow);
    NSDictionary * metrics = @{
                               @"avatarHeight"      : @(DXRealValue(150.0f/3)),
                               @"avatarWidth"       : @(DXRealValue(150.0f/3)),
                               @"avatarLeading"     : @(DXRealValue(40.0f/3)),
                               @"labelLeading"      : @(DXRealValue(232.0f/3)),
                               @"nickTop"           : @(DXRealValue(60.0f/3)),
                               @"locationTop"       : @(DXRealValue(132.0f/3)),
                               @"inviteButtonWidth" : @(DXRealValue(180.0f/3)),
                               @"inviteButtonHeight": @(DXRealValue(78.0f/3)),
                               @"inviteButtonTail"  : @(DXRealValue(40.0f/3))
                               };
    NSArray * visualFormats = @[
                                @"H:|-avatarLeading-[avatarView(==avatarWidth)]",
                                @"H:|-labelLeading-[nickLabel]-[inviteButton]",
                                @"H:|-labelLeading-[locationLabel]-[inviteButton]",
                                @"H:[inviteButton(==inviteButtonWidth)]-inviteButtonTail-|",
                                @"H:|[bottomShadow]|",
                                @"V:[avatarView(==avatarHeight)]",
                                @"V:|-nickTop-[nickLabel]",
                                @"V:|-locationTop-[locationLabel]",
                                @"V:[inviteButton(==inviteButtonHeight)]",
                                @"V:[bottomShadow(==0.5)]|",
                                ];
    for (NSString * vf in visualFormats) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views]];
    }
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:avatarView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:inviteButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0 constant:0]];
    
}

- (void)updateConstraints {
    if (!isConstraintsSet) {
        [self setupConstraints];
        isConstraintsSet = YES;
    }
    [super updateConstraints];
}

#pragma mark -

- (void)setNick:(NSString *)nick {
    _nick = nick;
    
    nickLabel.text = nick;
}

- (void)setLocation:(NSString *)location {
    _location = location;
    
    location = location ? location : @"";
    
    locationLabel.text = [NSString stringWithFormat:@"来自%@", location];
}

- (void)setInvited:(BOOL)invited {
    _invited = invited;
    
    inviteButton.enabled = invited ? NO : YES;
}

#pragma mark - 

- (void)inviteButtonTapped:(UIButton *)sender {
    if (self.tapBlock) {
        self.tapBlock(self);
    }
}

- (void)avatarTapped:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(userInviteCell:didTapAvatarView:)]) {
            [self.delegate userInviteCell:self didTapAvatarView:(UIImageView *)gesture.view];
        }
    }
}

@end
