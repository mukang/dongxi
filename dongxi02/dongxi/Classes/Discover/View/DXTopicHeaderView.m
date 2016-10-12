//
//  DXTopicHeaderView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicHeaderView.h"
#import "DXCollapseTextView.h"
#import "DXTopicHeaderRankView.h"
#import "DXExtendButton.h"

@interface DXTopicHeaderView() <DXCollapseTextViewDelegate>

@property (nonatomic, assign) BOOL constraintsInstalled;

@property (nonatomic, strong) UIView * topContainerView;
@property (nonatomic, strong) UIView * coverImageMaskView;
@property (nonatomic, strong) UIView * bottomContainerView;
@property (nonatomic, strong) UIView * avatarContainer;

@property (nonatomic, strong) DXCollapseTextView * collapseTextView;

/** 有奖图标 */
@property (nonatomic, strong) UIImageView *prizeIcon;
/** 排行榜视图 */
@property (nonatomic, strong) DXTopicHeaderRankView *rankView;
/** 排行榜视图的宽 */
@property (nonatomic, assign) CGFloat rankViewWidth;



@end

@implementation DXTopicHeaderView

#pragma mark - Public Methods

- (void)setTopicText:(NSString *)text {
    BOOL textChanged = ![_topicText isEqualToString:text];
    _topicText = text;
    
    self.collapseTextView.text = text;
    
    if (textChanged && self.delegate && [self.delegate respondsToSelector:@selector(textDidChangeInTopicHeaderView:)]) {
        [self.delegate textDidChangeInTopicHeaderView:self];
    }
}


#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.constraintsInstalled = NO;
        [self setupSubviews];
    }
    return self;
}

- (void)updateConstraints {
    if (!self.constraintsInstalled) {
        [self setupContraints];
        self.constraintsInstalled = YES;
    }
    
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


- (void)setupSubviews {
    self.topContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.topContainerView.clipsToBounds = YES;
    self.topContainerView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.topContainerView.userInteractionEnabled = NO;
    
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.coverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.coverImageMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    self.coverImageMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    self.coverImageMaskView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.prizeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"discover_topic_prize"]];
    self.prizeIcon.hidden = YES;
    self.prizeIcon.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.topicLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.topicLabel.numberOfLines = 1;
    self.topicLabel.textAlignment = NSTextAlignmentCenter;
    self.topicLabel.font = [DXFont dxDefaultBoldFontWithSize:20];
    self.topicLabel.textColor = [UIColor whiteColor];
    self.topicLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.subTitleLabel.numberOfLines = 1;
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.font = [DXFont dxDefaultFontWithSize:(40/3.0)];
    self.subTitleLabel.textColor = [UIColor whiteColor];
    self.subTitleLabel.alpha = 0.7;
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.rankView = [[DXTopicHeaderRankView alloc] initWithFrame:CGRectZero];
    self.rankView.hidden = YES;
    self.rankView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer * rankViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRankViewTapGesture:)];
    [self.rankView addGestureRecognizer:rankViewTapGesture];
    
    self.collectedBtn = [DXButton buttonWithType:UIButtonTypeCustom];
    [self.collectedBtn setImage:[UIImage imageNamed:@"discover_topic_collected_btn_normal"] forState:UIControlStateNormal];
    [self.collectedBtn setImage:[UIImage imageNamed:@"discover_topic_collected_btn_selected"] forState:UIControlStateSelected];
    [self.collectedBtn addTarget:self action:@selector(handleCollectedBtnTapGesture:) forControlEvents:UIControlEventTouchDown];
    self.collectedBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.bottomContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomContainerView.backgroundColor = [UIColor whiteColor];
    self.bottomContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.nickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nickLabel.textAlignment = NSTextAlignmentCenter;
    self.nickLabel.font = [DXFont dxDefaultBoldFontWithSize:17.0f];
    self.nickLabel.textColor = DXRGBColor(72, 72, 72);
    self.nickLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = [DXFont systemFontOfSize:15.0 weight:DXFontWeightLight];
    self.timeLabel.textColor = DXRGBColor(143, 143, 143);
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.collapseTextView = [[DXCollapseTextView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
    self.collapseTextView.delegate = self;
    self.collapseTextView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    self.avatarContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.avatarContainer.layer.shadowOpacity = 1;
    self.avatarContainer.layer.shadowColor = [UIColor colorWithWhite:0.5 alpha:1].CGColor;
    self.avatarContainer.layer.shadowOffset = CGSizeMake(0, 1);
    self.avatarContainer.layer.shadowRadius = 1.7f;
    self.avatarContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.avatarView = [[DXAvatarView alloc] initWithFrame:CGRectZero];
    self.avatarView.avatarImageView.backgroundColor = [UIColor whiteColor];
    self.avatarView.avatarImageView.layer.borderWidth = 1;
    self.avatarView.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer * avatarTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTapGesture:)];
    [self.avatarView addGestureRecognizer:avatarTapGesture];
    

    [self.topContainerView addSubview:self.coverImageView];
    [self.topContainerView addSubview:self.coverImageMaskView];
    [self.topContainerView addSubview:self.prizeIcon];
    [self.topContainerView addSubview:self.topicLabel];
    [self.topContainerView addSubview:self.subTitleLabel];
    [self.topContainerView addSubview:self.rankView];
    [self.topContainerView addSubview:self.collectedBtn];
    [self addSubview:self.topContainerView];
    [self.bottomContainerView addSubview:self.nickLabel];
    [self.bottomContainerView addSubview:self.timeLabel];
    [self.bottomContainerView addSubview:self.collapseTextView];
    [self addSubview:self.bottomContainerView];
    [self.avatarContainer addSubview:self.avatarView];
    [self addSubview:self.avatarContainer];
    
    [self setNeedsUpdateConstraints];
}

- (void)setupContraints {
    [self removeConstraints:self.constraints];
    
    
    NSDictionary * views = @{
                             @"topContainerView"        : self.topContainerView,
                             @"coverImageView"          : self.coverImageView,
                             @"coverImageMaskView"      : self.coverImageMaskView,
                             @"prizeIcon"               : self.prizeIcon,
                             @"topicLabel"              : self.topicLabel,
                             @"subTitleLabel"           : self.subTitleLabel,
                             @"rankView"                : self.rankView,
                             @"collectedBtn"            : self.collectedBtn,
                             
                             @"avatarContainer"         : self.avatarContainer,
                             @"avatarImageView"         : self.avatarView,
                             
                             @"bottomContainerView"     : self.bottomContainerView,
                             @"nickLabel"               : self.nickLabel,
                             @"timeLabel"               : self.timeLabel,
                             @"collapseTextView"        : self.collapseTextView
                             };
    
    NSDictionary * metrics = @{
                               @"topContainerHeight"            : @(DXScreenWidth*480/1242),
                               @"prizeIconLength"               : @(DXRealValue(50.5f)),
                               @"topicLabelTopMargin"           : @(DXRealValue(33.0f)),
                               @"topicLabelHeight"              : @(DXRealValue(20.0f)),
                               @"subTitleLabelTopMargin"        : @(DXRealValue(4.0f)),
                               @"subTitleLabelHeight"           : @(DXRealValue(40/3.0f)),
                               @"rankViewTopMargin"             : @(DXRealValue(16.0f)),
                               @"rankViewWidth"                 : @(self.rankViewWidth),
                               @"rankViewHeight"                : @(DXRealValue(38.0f)),
                               @"avatarImageViewLength"         : @(DXRealValue(50.0f)),
                               @"avatarImageViewBottomOffset"   : @(-DXRealValue(50.0f)/2),
                               @"collectedBtnWidth"             : @(DXRealValue(24)),
                               @"collectedBtnHeight"            : @(DXRealValue(23)),
                               @"collectedBtnRightMargin"       : @(DXRealValue(18)),
                               @"collectedBtnBottomMargin"      : @(DXRealValue(40.0/3)),
                               @"nickLabelTopMargin"            : @(DXRealValue(33.0f)),
                               @"timeLabelTopMargin"            : @(DXRealValue(7.0f)),
                               @"textViewTopMargin"             : @(DXRealValue(288.0/3)),
                               };
    
    NSArray * visualFormats = @[
                                // Containers and Avatar
                                @"H:|[topContainerView]|",
                                @"H:|[bottomContainerView]|",
                                @"H:[avatarContainer(==avatarImageViewLength)]",
                                @"H:|[avatarImageView]|",
                                @"V:|[topContainerView(==topContainerHeight)]",
                                @"V:|-(>=topContainerHeight@500)-[bottomContainerView]|",
                                @"V:[avatarContainer(==avatarImageViewLength)]-avatarImageViewBottomOffset-[bottomContainerView]",
                                @"V:|[avatarImageView]|",
                                // Top Container Subviews
                                @"H:[prizeIcon(==prizeIconLength)]|",
                                @"H:|-[topicLabel]-|",
                                @"H:|-[subTitleLabel]-|",
                                @"H:|[coverImageView]|",
                                @"H:|[coverImageMaskView]|",
                                @"H:[collectedBtn(==collectedBtnWidth)]-collectedBtnRightMargin-|",
                                @"V:|[prizeIcon(==prizeIconLength)]",
                                @"V:|-topicLabelTopMargin-[topicLabel(==topicLabelHeight)]-subTitleLabelTopMargin-[subTitleLabel(==subTitleLabelHeight)]-rankViewTopMargin-[rankView(==rankViewHeight)]",
                                @"V:|[coverImageView]|",
                                @"V:|[coverImageMaskView]|",
                                @"V:[collectedBtn(==collectedBtnHeight)]-collectedBtnBottomMargin-|",
                                // Bottom Container Subviews
                                @"H:|-[nickLabel]-|",
                                @"H:|-[timeLabel]-|",
                                @"H:|[collapseTextView]|",
                                @"V:|-nickLabelTopMargin-[nickLabel]-timeLabelTopMargin-[timeLabel]",
                                @"V:|-textViewTopMargin-[collapseTextView]-|"
                                ];
    
    for (NSString * vf in visualFormats) {
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
    }
    
    NSLayoutConstraint * constraint = nil;
    constraint = [NSLayoutConstraint constraintWithItem:self.rankView
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:0
                                             multiplier:1.0
                                               constant:self.rankViewWidth];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.rankView
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.topContainerView
                                              attribute:NSLayoutAttributeCenterX
                                             multiplier:1.0
                                               constant:0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.avatarContainer
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                              attribute:NSLayoutAttributeCenterX
                                             multiplier:1.0
                                               constant:0];
    [self addConstraint:constraint];
}

#pragma mark - Gesture & Button Actions 

- (void)handleRankViewTapGesture:(UITapGestureRecognizer *)gesture {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rankViewDidTapInTopicHeaderView:)]) {
        [self.delegate rankViewDidTapInTopicHeaderView:self];
    }
}

- (void)handleAvatarTapGesture:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(avatarDidTapInTopicHeaderView:)]) {
        [self.delegate avatarDidTapInTopicHeaderView:self];
    }
}

- (void)handleCollectedBtnTapGesture:(UITapGestureRecognizer *)gesture {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectedBtnDidTapInTopicHeaderView:)]) {
        [self.delegate collectedBtnDidTapInTopicHeaderView:self];
    }
}

#pragma mark - DXCollapseTextViewDelegate

- (void)collapseTextView:(DXCollapseTextView *)collapseTextView willChangeState:(BOOL)collapse {
    [self setNeedsUpdateConstraints];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textDidChangeInTopicHeaderView:)]) {
        [self.delegate textDidChangeInTopicHeaderView:self];
    }
}

- (void)setHasPrize:(BOOL)hasPrize {
    _hasPrize = hasPrize;
    
    if (hasPrize) {
        self.prizeIcon.hidden = NO;
    } else {
        self.prizeIcon.hidden = YES;
    }
}

- (void)setRank:(NSArray *)rank {
    _rank = rank;
    
    CGFloat iconWH = DXRealValue(28);
    CGFloat iconMargin = DXRealValue(7);
    if (rank.count) {
        self.rankView.hidden = NO;
        self.rankViewWidth = (iconWH + iconMargin) * (rank.count + 2) - iconMargin;
        self.rankView.rank = rank;
        [self setNeedsUpdateConstraints];
    } else {
        self.rankView.hidden = YES;
    }
}

@end
