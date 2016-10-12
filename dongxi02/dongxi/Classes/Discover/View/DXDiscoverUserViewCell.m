//
//  DXDiscoverUserViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDiscoverUserViewCell.h"

@implementation DXDiscoverUserViewCell {
    UIView * _photoMaskView;
    UILabel * _nickLabel;
    DXMutiLineLabel * _textLabel;
    UIButton * _relationButton;
    CGSize _relationButtonSize;

    BOOL _isConstraintSet;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.bounds = self.bounds;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}


#pragma mark -

- (void)setupSubviews {
    
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_containerView];
    
    _photoView1 = [[UIImageView alloc] initWithFrame:CGRectZero];
    _photoView1.contentMode = UIViewContentModeScaleAspectFill;
    _photoView1.clipsToBounds = YES;
    _photoView1.translatesAutoresizingMaskIntoConstraints = NO;
    
    _photoView2 = [[UIImageView alloc] initWithFrame:CGRectZero];
    _photoView2.contentMode = UIViewContentModeScaleAspectFill;
    _photoView2.clipsToBounds = YES;
    _photoView2.translatesAutoresizingMaskIntoConstraints = NO;
    
    _photoView3 = [[UIImageView alloc] initWithFrame:CGRectZero];
    _photoView3.contentMode = UIViewContentModeScaleAspectFill;
    _photoView3.clipsToBounds = YES;
    _photoView3.translatesAutoresizingMaskIntoConstraints = NO;
    
    _photoMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    _photoMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.30];
    _photoMaskView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _avatarView = [[DXAvatarView alloc] initWithFrame:CGRectZero];
    _avatarView.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    UITapGestureRecognizer * avatarViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewTapped:)];
    [_avatarView addGestureRecognizer:avatarViewTapGesture];
    
    _nickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nickLabel.font = [DXFont dxDefaultBoldFontWithSize:50.0/3];
    _nickLabel.textColor = DXRGBColor(72, 72, 72);
    _nickLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableParagraphStyle * paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paraStyle.lineSpacing = DXRealValue(3);
    _textLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    _textLabel.font = [DXFont dxDefaultFontWithSize:40.0/3];
    _textLabel.textColor = DXRGBColor(72, 72, 72);
    _textLabel.paragraphStyle = paraStyle;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImage * followImage = [UIImage imageNamed:@"attention_add_3"];
    _relationButtonSize = CGSizeMake(DXRealValue(followImage.size.width), DXRealValue(followImage.size.height));
    _relationButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_relationButton setImage:followImage forState:UIControlStateNormal];
    [_relationButton addTarget:self action:@selector(relationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _relationButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addSubview:_photoView1];
    [self.containerView addSubview:_photoView2];
    [self.containerView addSubview:_photoView3];
    [self.containerView addSubview:_photoMaskView];
    [self.containerView addSubview:_avatarView];
    [self.containerView addSubview:_nickLabel];
    [self.containerView addSubview:_textLabel];
    [self.containerView addSubview:_relationButton];
    
    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints {

    NSDictionary * views = NSDictionaryOfVariableBindings(_photoView1, _photoView2, _photoView3, _photoMaskView, _avatarView, _nickLabel, _textLabel, _relationButton);
    CGFloat photoWidth = CGRectGetWidth(self.bounds)/3;
    CGFloat photoHeight = photoWidth * 280.0f / 414.0f;
    CGFloat avatarWidth = DXRealValue(50);
    CGFloat avatarHeight = DXRealValue(50);
    CGFloat textLabelLeading = DXRealValue(81.0/3);
    CGFloat textLabelTrailing = DXRealValue(81.0/3);
    
    NSDictionary * metrics = @{
                               @"photoWidth"                : @(photoWidth),
                               @"photoHeight"               : @(photoHeight),
                               @"avatarWidth"               : @(avatarWidth),
                               @"avatarHeight"              : @(avatarHeight),
                               @"nickLabelTop"              : @(DXRealValue(381.0/3)),
                               @"textLabelTop"              : @(DXRealValue(462.0/3)),
                               @"textLabelBottom"           : @(DXRealValue(30)),
                               @"textLabelLeading"          : @(textLabelLeading),
                               @"textLabelTrailing"         : @(textLabelTrailing),
                               @"relationButtonWidth"       : @(_relationButtonSize.width),
                               @"relationButtonHeight"      : @(_relationButtonSize.height),
                               @"relationButtonTop"         : @(DXRealValue(349.0/3)),
                               @"relationButtonTrailing"    : @(DXRealValue(83.0/3)),
                               };
    
    NSArray * visualFormats = @[
                                @"H:|[_photoView1(==photoWidth)][_photoView2(==photoWidth)][_photoView3]|",
                                @"H:|[_photoMaskView]|",
                                @"H:[_avatarView(==avatarWidth)]",
                                @"H:|-textLabelLeading-[_textLabel]-textLabelTrailing-|",
                                @"H:[_relationButton(==relationButtonWidth)]-relationButtonTrailing-|",
                                @"V:|[_photoView1(==photoHeight)]",
                                @"V:|[_photoView2(==photoHeight)]",
                                @"V:|[_photoView3(==photoHeight)]",
                                @"V:|[_photoMaskView(==photoHeight)]",
                                @"V:[_avatarView(==avatarHeight)]",
                                @"V:|-nickLabelTop-[_nickLabel]",
                                @"V:|-textLabelTop-[_textLabel]-(>=textLabelBottom@500)-|",
                                @"V:|-relationButtonTop-[_relationButton(==relationButtonHeight)]"
                                ];
    for (NSString * vf in visualFormats) {
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views]];
    }
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_photoMaskView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:-avatarHeight/2]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:_avatarView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.containerView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0 constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:_nickLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.containerView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0 constant:0]];
}

- (void)updateConstraints {
    [self.containerView removeConstraints:self.containerView.constraints];
    
    [self setupConstraints];
    [super updateConstraints];
}

#pragma mark -

- (void)relationButtonTapped:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapFollowButtonInDiscoverUserViewCell:)]) {
        [self.delegate didTapFollowButtonInDiscoverUserViewCell:self];
    }
}

- (void)avatarViewTapped:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAvatarInDiscoverUserViewCell:)]) {
        [self.delegate didTapAvatarInDiscoverUserViewCell:self];
    }
}

- (void)setNick:(NSString *)nick {
    _nick = nick;

    _nickLabel.text = nick;
    _isConstraintSet = NO;
    [self setNeedsUpdateConstraints];
}

- (void)setText:(NSString *)text {
    _text = text;

    _textLabel.text = text;
    _isConstraintSet = NO;
    [self setNeedsUpdateConstraints];
}

- (void)setRelation:(NSUInteger)relation {
    _relation = relation;
    
    _relationButton.hidden = NO;
    
    switch (relation) {
        case DXUserRelationTypeFollower:
            [_relationButton setImage:[UIImage imageNamed:@"attention_add_3"] forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeFollowed:
            [_relationButton setImage:[UIImage imageNamed:@"attention_ok_3"] forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeFriend:
            [_relationButton setImage:[UIImage imageNamed:@"attention_mutual_3"] forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeCurrentUser:
            _relationButton.hidden = YES;
            break;
        default:
            [_relationButton setImage:[UIImage imageNamed:@"attention_add_3"] forState:UIControlStateNormal];
            break;
    }
}


@end
