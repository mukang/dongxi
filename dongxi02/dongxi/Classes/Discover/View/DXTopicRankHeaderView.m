//
//  DXTopicRankHeaderView.m
//  dongxi
//
//  Created by 穆康 on 16/2/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicRankHeaderView.h"
#import "DXTopicFeedList.h"
#import <UIImageView+WebCache.h>

@interface DXTopicRankHeaderView ()

@property (nonatomic, weak) UIImageView *coverImageView;
@property (nonatomic, weak) UIView *coverImageMaskView;

@property (nonatomic, weak) UILabel *topicLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;
@property (nonatomic, weak) UILabel *rankNumLabel;

@property (nonatomic, weak) UIView *separateView;

@end

@implementation DXTopicRankHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UIImageView *coverImageView = [[UIImageView alloc] init];
    [self addSubview:coverImageView];
    
    UIView *coverImageMaskView = [[UIView alloc] init];
    coverImageMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    [self addSubview:coverImageMaskView];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = [UIColor whiteColor];
    topicLabel.font = [DXFont dxDefaultBoldFontWithSize:20];
    [self addSubview:topicLabel];
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    subTitleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
    subTitleLabel.font = [DXFont dxDefaultFontWithSize:40/3.0];
    [self addSubview:subTitleLabel];
    
    UILabel *rankNumLabel = [[UILabel alloc] init];
    rankNumLabel.textColor = [UIColor whiteColor];
    rankNumLabel.font = [UIFont boldSystemFontOfSize:DXRealValue(25)];
    [self addSubview:rankNumLabel];
    
    UIView *separateView = [[UIView alloc] init];
    separateView.backgroundColor = [UIColor whiteColor];
    [self addSubview:separateView];
    
    self.coverImageView = coverImageView;
    self.coverImageMaskView = coverImageMaskView;
    self.topicLabel = topicLabel;
    self.subTitleLabel = subTitleLabel;
    self.rankNumLabel = rankNumLabel;
    self.separateView = separateView;
}

- (void)setTopicDetail:(DXTopicDetail *)topicDetail {
    _topicDetail = topicDetail;
    
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:topicDetail.cover] placeholderImage:nil options:SDWebImageRetryFailed];
    
    self.topicLabel.text = [NSString stringWithFormat:@"#%@#", topicDetail.topic];
    self.subTitleLabel.text = topicDetail.title;
    
    [self.topicLabel sizeToFit];
    [self.subTitleLabel sizeToFit];
}

- (void)setRankNum:(NSUInteger)rankNum {
    _rankNum = rankNum;
    
    self.rankNumLabel.text = [NSString stringWithFormat:@"TOP%zd", rankNum];
    [self.rankNumLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverImageView.frame = self.bounds;
    self.coverImageMaskView.frame = self.bounds;
    
    self.topicLabel.centerX = self.width * 0.5;
    self.topicLabel.centerY = DXRealValue(52);
    
    self.subTitleLabel.centerX = self.topicLabel.centerX;
    self.subTitleLabel.centerY = DXRealValue(72);
    
    self.rankNumLabel.centerX = self.topicLabel.centerX;
    self.rankNumLabel.centerY = DXRealValue(111);
    
    self.separateView.width = DXRealValue(148);
    self.separateView.height = 0.5;
    self.separateView.centerX = self.topicLabel.centerX;
    self.separateView.y = DXRealValue(89);
}

@end
