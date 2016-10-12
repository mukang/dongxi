//
//  DXCollectedTopicCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/26.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCollectedTopicCell.h"
#import "UIImage+Extension.h"
#import <UIImageView+WebCache.h>

static CGFloat BoderWidth = 1;

@interface DXCollectedTopicCell ()

@property (nonatomic, weak) UIImageView *topicImageView;

@end

@implementation DXCollectedTopicCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = DXRGBColor(222, 222, 222);
    
    UIImageView *topicImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:topicImageView];
    self.topicImageView = topicImageView;
}

- (void)setTopic:(DXTopic *)topic {
    _topic = topic;
    
    CGFloat placeholderImageWH = roundf(DXRealValue(84)) - BoderWidth * 2;
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(placeholderImageWH, placeholderImageWH)];
    [self.topicImageView sd_setImageWithURL:[NSURL URLWithString:topic.thumb] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.topicImageView.frame = CGRectMake(BoderWidth, BoderWidth, self.contentView.width - BoderWidth * 2, self.contentView.height - BoderWidth * 2);
}


@end
