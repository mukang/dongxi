//
//  DXActivityWishUserCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityWishUserCell.h"

@implementation DXActivityWishUserCell {
    BOOL isConstraintsSet;
    DXAvatarView * avatarView;
    UILabel * nickLabel;
    UILabel * locationLabel;
    UIView * bottomShadow;
}

@synthesize avatarView = avatarView;

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
    [avatarView addGestureRecognizer:avatarTap];
    avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    nickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nickLabel.font = [DXFont dxDefaultBoldFontWithSize:16.6f];
    nickLabel.textColor = DXRGBColor(72, 72, 72);
    nickLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    locationLabel.font = [DXFont dxDefaultFontWithSize:15.0f];
    locationLabel.textColor = DXCommonColor;
    locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    bottomShadow = [[UIView alloc] initWithFrame:CGRectZero];
    bottomShadow.backgroundColor = DXRGBColor(221, 221, 221);
    bottomShadow.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:avatarView];
    [self.contentView addSubview:nickLabel];
    [self.contentView addSubview:locationLabel];
    [self.contentView addSubview:bottomShadow];
    
    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints {
    [self removeConstraints:self.constraints];
    
    NSDictionary * views = NSDictionaryOfVariableBindings(avatarView, nickLabel, locationLabel, bottomShadow);
    NSDictionary * metrics = @{
                               @"avatarHeight"      : @(DXRealValue(150.0f/3)),
                               @"avatarWidth"       : @(DXRealValue(150.0f/3)),
                               @"avatarLeading"     : @(DXRealValue(40.0f/3)),
                               @"labelLeading"      : @(DXRealValue(232.0f/3)),
                               @"nickTop"           : @(DXRealValue(60.0f/3)),
                               @"locationTop"       : @(DXRealValue(132.0f/3)),
                               };
    NSArray * visualFormats = @[
                                @"H:|-avatarLeading-[avatarView(==avatarWidth)]",
                                @"H:|-labelLeading-[nickLabel]-|",
                                @"H:|-labelLeading-[locationLabel]-|",
                                @"H:|[bottomShadow]|",
                                @"V:[avatarView(==avatarHeight)]",
                                @"V:|-nickTop-[nickLabel]",
                                @"V:|-locationTop-[locationLabel]",
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

#pragma mark -

- (void)avatarTapped:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(wishUserCell:didTapAvatarView:)]) {
            [self.delegate wishUserCell:self didTapAvatarView:(UIImageView *)gesture.view];
        }
    }
}

@end
