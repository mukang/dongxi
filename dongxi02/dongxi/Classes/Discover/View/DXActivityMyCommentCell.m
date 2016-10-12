//
//  DXActivityMyCommentCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityMyCommentCell.h"

@interface DXActivityMyCommentCell ()

@property (nonatomic) UIView * starsOuterContainer;
@property (nonatomic) UILabel * textLabel;
@property (nonatomic) UIView * starsContainer;
@property (nonatomic) NSArray * starViews;
@property (nonatomic) UIView * borderView;

@end

@implementation DXActivityMyCommentCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.frame = self.bounds;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews {
    self.starsOuterContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.starsOuterContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.starsOuterContainer];
    
    self.detailButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.detailButton setImage:[UIImage imageNamed:@"arrow_small_grew"] forState:UIControlStateNormal];
    self.detailButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.detailButton];
    
    self.starsContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.starsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.starsOuterContainer addSubview:self.starsContainer];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.text = @"我的评分:";
    self.textLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.textLabel.textColor = DXRGBColor(72, 72, 72);
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.starsOuterContainer addSubview:self.textLabel];
    
    UIImage * starNormal = [UIImage imageNamed:@"star_event_grew"];
    UIImage * starHighlight = [UIImage imageNamed:@"star_event_yellow"];
    for (int i = 0; i < 5; i++) {
        UIButton * starView = [[UIButton alloc] initWithFrame:CGRectZero];
        [starView setImage:starNormal forState:UIControlStateNormal];
        [starView setImage:starHighlight forState:UIControlStateSelected];
        starView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.starsContainer addSubview:starView];
    }
    self.starViews = self.starsContainer.subviews;
    
    self.borderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.borderView.backgroundColor = DXRGBColor(222, 222, 222);
    self.borderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.borderView];
}

- (void)setupConstraints {
    NSDictionary * views = @{
                             @"starsOuterContainer" : self.starsOuterContainer,
                             @"detailButton"        : self.detailButton,
                             @"textLabel"           : self.textLabel,
                             @"starsContainer"      : self.starsContainer,
                             @"star0"               : self.starViews[0],
                             @"star1"               : self.starViews[1],
                             @"star2"               : self.starViews[2],
                             @"star3"               : self.starViews[3],
                             @"star4"               : self.starViews[4],
                             @"borderView"          : self.borderView,
                             };
    NSDictionary * metrics = @{
                               };
    NSArray * visualFormats = @[
                                @"H:[starsOuterContainer]-(<=20)-[detailButton]",
                                @"H:|[textLabel]-[starsContainer]|",
                                @"H:|[star0]-2-[star1]-2-[star2]-2-[star3]-2-[star4]|",
                                @"H:|[borderView]|",
                                @"V:|[textLabel]|",
                                @"V:|[star0]|",
                                @"V:|[star1]|",
                                @"V:|[star2]|",
                                @"V:|[star3]|",
                                @"V:|[star4]|",
                                @"V:[borderView(==0.5)]|"
                                ];
    for (NSString * vf in visualFormats) {
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.starsOuterContainer
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.starsOuterContainer
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.starsContainer
                                                    attribute:NSLayoutAttributeCenterY
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.starsOuterContainer
                                                    attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.detailButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.textLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
}

- (void)setStars:(NSUInteger)stars {
    _stars = stars;
    
    for (NSUInteger i = 0; i < self.starViews.count; i++) {
        UIButton * starView = self.starViews[i];
        if (i < stars) {
            [starView setSelected:YES];
        } else {
            [starView setSelected:NO];
        }
    }
}

@end
