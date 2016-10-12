//
//  DXActivityAttendCommentCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityAttendCommentCell.h"

@interface DXActivityAttendCommentCell ()

@property (nonatomic) UIView * borderView;
@property (nonatomic) UIView * starsContainer;
@property (nonatomic) NSArray * starViews;
@property (nonatomic) CGSize avatarSize;

@end

@implementation DXActivityAttendCommentCell {
    BOOL isConstraintsSet;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.frame = self.bounds;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.avatarSize = CGSizeMake(DXRealValue((120/3)), DXRealValue((120/3)));
        [self setupSubviews];
    }
    return self;
}

- (void)updateConstraints {
    if (!isConstraintsSet) {
        [self setupConstraints];
        isConstraintsSet = YES;
    }

    [super updateConstraints];
}

- (void)setupSubviews {
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:_containerView];
    
    self.avatarView = [[DXAvatarView alloc] initWithFrame:CGRectZero];
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewTapped:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.avatarView addGestureRecognizer:tapGesture];
    
    self.nickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nickLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.nickLabel.textColor = DXRGBColor(72, 72, 72);
    self.nickLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.font = [DXFont systemFontOfSize:13 weight:DXFontWeightLight];
    self.timeLabel.textColor = DXRGBColor(143, 143, 143);
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.commentLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    self.commentLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.commentLabel.textColor = DXRGBColor(72, 72, 72);
    self.commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.borderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.borderView.backgroundColor = DXRGBColor(222, 222, 222);
    self.borderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addSubview:self.avatarView];
    [self.containerView addSubview:self.nickLabel];
    [self.containerView addSubview:self.timeLabel];
    [self.containerView addSubview:self.commentLabel];
    [self.containerView addSubview:self.borderView];
    
    self.starsContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.starsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.starsContainer];
    
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
    
    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints {
    [self.containerView removeConstraints:self.containerView.constraints];

    NSDictionary * views = @{
                             @"avatarImageView"     : self.avatarView,
                             @"nickLabel"           : self.nickLabel,
                             @"timeLabel"           : self.timeLabel,
                             @"commentLabel"        : self.commentLabel,
                             @"borderView"          : self.borderView,
                             @"starsContainer"      : self.starsContainer,
                             @"star0"               : self.starViews[0],
                             @"star1"               : self.starViews[1],
                             @"star2"               : self.starViews[2],
                             @"star3"               : self.starViews[3],
                             @"star4"               : self.starViews[4]
                             };
    NSDictionary * metrics = @{
                               @"avatarViewWidth"           : @(self.avatarSize.width),
                               @"avatarViewHeight"          : @(self.avatarSize.height),
                               @"avatarTopMargin"           : @(DXRealValue((40.0/3))),
                               @"avatarLeftMargin"          : @(DXRealValue((40.0/3))),
                               @"labelLeftMargin"           : @(DXRealValue((190.0/3))),
                               @"nickLabelTopMargin"        : @(DXRealValue((42.0/3))),
                               @"timeLabelTopMargin"        : @(DXRealValue((100.0/3))),
                               @"commentLabelTopMargin"     : @(DXRealValue((210.0/3))),
                               @"commentLabelRightMargin"   : @(DXRealValue((230.0/3))),
                               @"commentLabelBottomMargin"  : @(DXRealValue((40.0/3))),
                               @"starsTopMargin"            : @(DXRealValue((134.0/3)))
                               };
    NSArray * visualFormats = @[
                                @"H:|-avatarLeftMargin-[avatarImageView(==avatarViewWidth)]",
                                @"H:|-labelLeftMargin-[nickLabel]",
                                @"H:|-labelLeftMargin-[timeLabel]",
                                @"H:|-labelLeftMargin-[starsContainer]",
                                @"H:|[star0]-2-[star1]-2-[star2]-2-[star3]-2-[star4]|",
                                @"H:|-labelLeftMargin-[commentLabel]-commentLabelRightMargin-|",
                                @"H:|[borderView]|",
                                @"V:|-avatarTopMargin-[avatarImageView(==avatarViewHeight)]",
                                @"V:|-nickLabelTopMargin-[nickLabel]",
                                @"V:|-timeLabelTopMargin-[timeLabel]",
                                @"V:|-commentLabelTopMargin-[commentLabel]-commentLabelBottomMargin@500-|",
                                @"V:[borderView(==0.5)]|",
                                @"V:|-starsTopMargin-[starsContainer]",
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

- (void)avatarImageViewTapped:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapAvatarInCell:)]) {
            [self.delegate userDidTapAvatarInCell:self];
        }
    }
}


@end
