//
//  DXFeedRecommendTopicCell.m
//  dongxi
//
//  Created by 穆康 on 16/3/14.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedRecommendTopicCell.h"
#import "DXFeedRecommendTopicView.h"

#define TopMargin DXRealValue(7) // cell内容顶部间距

@interface DXFeedRecommendTopicCell ()

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) DXFeedRecommendTopicView *firstTopicView;
@property (nonatomic, weak) DXFeedRecommendTopicView *secondTopicView;

@end

@implementation DXFeedRecommendTopicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = DXRGBColor(222, 222, 222);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:containerView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"你可能感兴趣的话题";
    titleLabel.textColor = DXRGBColor(72, 72, 72);
    titleLabel.font = [DXFont dxDefaultBoldFontWithSize:35/3.0];
    [titleLabel sizeToFit];
    [containerView addSubview:titleLabel];
    
    DXFeedRecommendTopicView *firstTopicView = [[DXFeedRecommendTopicView alloc] init];
    [containerView addSubview:firstTopicView];
    UITapGestureRecognizer *firstTopicViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFirstTopicViewTapGesture:)];
    [firstTopicView addGestureRecognizer:firstTopicViewTap];
    
    DXFeedRecommendTopicView *secondTopicView = [[DXFeedRecommendTopicView alloc] init];
    [containerView addSubview:secondTopicView];
    UITapGestureRecognizer *secondTopicViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSecondTopicViewTapGesture:)];
    [secondTopicView addGestureRecognizer:secondTopicViewTap];
    
    self.containerView = containerView;
    self.titleLabel = titleLabel;
    self.firstTopicView = firstTopicView;
    self.secondTopicView = secondTopicView;
}

- (void)setRecommendation:(DXTimelineRecommendation *)recommendation {
    _recommendation = recommendation;
    
    NSArray *topics = recommendation.recommend_topic;
    self.firstTopicView.topic = [topics firstObject];
    self.secondTopicView.topic = [topics lastObject];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.frame = CGRectMake(0, TopMargin, self.contentView.width, self.contentView.height - TopMargin);
    
    self.titleLabel.origin = CGPointMake(DXRealValue(13), DXRealValue(35/3.0));
    
    CGFloat padding = DXRealValue(34/3.0);
    CGFloat margin = DXRealValue(28/3.0);
    CGFloat topicViewW = (self.containerView.width - margin - padding * 2.0) / 2.0;
    CGFloat topicViewH = DXRealValue(221/3.0);
    CGFloat topicViewY = DXRealValue(94/3.0);
    
    CGFloat firstTopicViewX = padding;
    self.firstTopicView.frame = CGRectMake(firstTopicViewX, topicViewY, topicViewW, topicViewH);
    
    CGFloat secondTopicViewX = padding + topicViewW + margin;
    self.secondTopicView.frame = CGRectMake(secondTopicViewX, topicViewY, topicViewW, topicViewH);
}

- (void)handleFirstTopicViewTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedRecommendTopicCell:didTapTopicViewWithTopic:)]) {
        [self.delegate feedRecommendTopicCell:self didTapTopicViewWithTopic:[self.recommendation.recommend_topic firstObject]];
    }
}

- (void)handleSecondTopicViewTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedRecommendTopicCell:didTapTopicViewWithTopic:)]) {
        [self.delegate feedRecommendTopicCell:self didTapTopicViewWithTopic:[self.recommendation.recommend_topic lastObject]];
    }
}

@end
