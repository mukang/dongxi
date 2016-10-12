//
//  DXActivityHeaderCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityHeaderCell.h"

@interface DXActivityHeaderCell()

@property (nonatomic) UIView * bottomContainer;
@property (nonatomic) UIView * starsContainer;
@property (nonatomic) NSArray * starViews;
@property (nonatomic) CGFloat starHeight;

@end

@implementation DXActivityHeaderCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
    }
    return self;
}

- (void)updateConstraints {
    [self setupConstraints];
    
    [super updateConstraints];
}

- (void)setupSubviews {
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:_containerView];
    
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.coverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addSubview:self.coverImageView];
    
    self.bottomContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomContainer.backgroundColor = [UIColor whiteColor];
    self.bottomContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addSubview:self.bottomContainer];
    
    self.nameLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.font = [DXFont fontWithName:DXCommonFontName size:20];
    self.nameLabel.textColor = DXRGBColor(72, 72, 72);
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.bottomContainer addSubview:self.nameLabel];
    
    self.starsContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.starsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.bottomContainer addSubview:self.starsContainer];
    
    UIImage * starNormal = [UIImage imageNamed:@"star_event_grew"];
    UIImage * starHighlight = [UIImage imageNamed:@"star_event_yellow"];
    self.starHeight = starNormal.size.height;
    for (int i = 0; i < 5; i++) {
        UIImageView * starImageView = [[UIImageView alloc] initWithImage:starNormal highlightedImage:starHighlight];
        starImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.starsContainer addSubview:starImageView];
    }
    self.starViews = self.starsContainer.subviews;
    
    self.numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.numberLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.numberLabel.textColor = DXRGBColor(143, 143, 143);
    self.numberLabel.textAlignment = NSTextAlignmentCenter;
    self.numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.bottomContainer addSubview:self.numberLabel];
    
    
    [self setNeedsUpdateConstraints];
}


- (void)setupConstraints {
    [self.containerView removeConstraints:self.containerView.constraints];

    CGFloat coverWidth = self.bounds.size.width;
    CGFloat coverHeight = coverWidth * 480 / 1242;
    CGFloat bottomTopMargin = DXRealValue(160);
    CGFloat bottomHeight = DXRealValue(130);
    CGFloat nameLabelTopMargin = DXRealValue(26);
    CGFloat starsTopMargin = DXRealValue(58);
    CGFloat numberLabelTopMargin = DXRealValue(84);
    
    NSDictionary * views = @{
                             @"coverImageView"      : self.coverImageView,
                             @"bottomContainer"     : self.bottomContainer,
                             @"nameLabel"           : self.nameLabel,
                             @"starsContainer"      : self.starsContainer,
                             @"star0"               : self.starViews[0],
                             @"star1"               : self.starViews[1],
                             @"star2"               : self.starViews[2],
                             @"star3"               : self.starViews[3],
                             @"star4"               : self.starViews[4],
                             @"numberLabel"         : self.numberLabel
                             };
    NSDictionary * metrics = @{
                               @"coverWidth"            : @(coverWidth),
                               @"coverHeight"           : @(coverHeight),
                               @"bottomTopMargin"       : @(bottomTopMargin),
                               @"bottomHeight"          : @(bottomHeight),
                               @"nameLabelTopMargin"    : @(nameLabelTopMargin),
                               @"starHeight"            : @(self.starHeight),
                               @"starsTopMargin"        : @(starsTopMargin),
                               @"numberLabelTopMargin"  : @(numberLabelTopMargin)
                               };
    NSArray * visualFormats = @[
                                @"H:|[coverImageView]|",
                                @"H:|[bottomContainer]|",
                                @"H:|-[nameLabel]-|",
                                @"H:|[star0]-2-[star1]-2-[star2]-2-[star3]-2-[star4]|",
                                @"H:|[numberLabel]|",
                                @"V:|[coverImageView(==coverHeight)][bottomContainer]|",
                                @"V:|-nameLabelTopMargin-[nameLabel]-[starsContainer(==starHeight)]-[numberLabel(==20)]-nameLabelTopMargin-|",
                                @"V:|[star0]|",
                                @"V:|[star1]|",
                                @"V:|[star2]|",
                                @"V:|[star3]|",
                                @"V:|[star4]|"
                                ];
    for (NSString * vf in visualFormats) {
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views];
        [self.containerView addConstraints:constraints];
    }
    
    NSLayoutConstraint * alignX = [NSLayoutConstraint constraintWithItem:self.starsContainer
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.bottomContainer
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    [self.containerView addConstraint:alignX];
}


- (void)setStars:(NSUInteger)stars {
    _stars = stars;
    
    for (NSUInteger i = 0; i < self.starViews.count; i++) {
        UIImageView * starView = self.starViews[i];
        if (i < stars) {
            [starView setHighlighted:YES];
        } else {
            [starView setHighlighted:NO];
        }
    }
}


@end
