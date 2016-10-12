//
//  DXFeedRecommendTopicView.m
//  dongxi
//
//  Created by 穆康 on 16/3/14.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedRecommendTopicView.h"
#import <UIImageView+WebCache.h>

@interface DXFeedRecommendTopicView ()

@property (nonatomic, weak) UIImageView *bgImageView;
@property (nonatomic, weak) UIView *maskCoverView;
@property (nonatomic, weak) UILabel *topicLabel;

@end

@implementation DXFeedRecommendTopicView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    [self addSubview:bgImageView];
    
    UIView *maskCoverView = [[UIView alloc] init];
    maskCoverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self addSubview:maskCoverView];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = [UIColor whiteColor];
    topicLabel.font = [DXFont dxDefaultFontWithSize:40/3.0];
    [self addSubview:topicLabel];
    
    self.bgImageView = bgImageView;
    self.maskCoverView = maskCoverView;
    self.topicLabel = topicLabel;
}

- (void)setTopic:(DXTopic *)topic {
    _topic = topic;
    
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:topic.cover] placeholderImage:nil options:SDWebImageRetryFailed];
    
    self.topicLabel.text = [NSString stringWithFormat:@"#%@#", topic.topic];
    [self.topicLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgImageView.frame = self.bounds;
    
    self.maskCoverView.frame = self.bounds;
    
    self.topicLabel.center = self.bgImageView.center;
}

@end
