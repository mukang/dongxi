//
//  DXHotTopicTableViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXHotTopicTableViewCell.h"

#define GreenColor      DXRGBColor(112, 171, 43)   // 小于1000
#define YellowColor     DXRGBColor(203, 172, 0)    // 小于5000
#define OrangeColor     DXRGBColor(221, 125, 12)   // 小于10000
#define RedColor        DXRGBColor(225, 79, 60)    // 大于等于10000

@interface DXHotTopicTableViewCell()

@property (nonatomic, strong) UILabel *collectedLabel;
@property (nonatomic, strong) UIView *collectedView;
@property (nonatomic, strong) UIImageView *prizeIcon;

@end

@implementation DXHotTopicTableViewCell {
    UIView * containerView;
    UIImageView * backgroundImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = DXRGBColor(222, 222, 222);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        containerView = [[UIView alloc] initWithFrame:CGRectZero];
        containerView.backgroundColor = [UIColor whiteColor];
        
        self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        self.topicLabel = [[UILabel alloc] init];
        self.topicLabel.numberOfLines = 1;
        self.topicLabel.textColor = DXRGBColor(72, 72, 72);
        self.topicLabel.font = [DXFont dxDefaultFontWithSize:16];
        
        self.activenessLabel = [[UILabel alloc] init];
        self.activenessLabel.numberOfLines = 1;
        self.activenessLabel.font = [DXFont dxDefaultFontWithSize:38/3.0];
        
        self.subTitleLabel = [[UILabel alloc] init];
        self.subTitleLabel.numberOfLines = 1;
        self.subTitleLabel.textColor = DXRGBColor(72, 72, 72);
        self.subTitleLabel.font = [DXFont dxDefaultFontWithSize:38/3.0];
        
        self.collectedView = [[UIView alloc] init];
        self.collectedView.backgroundColor = [UIColor blackColor];
        self.collectedView.alpha = 0.5;
        self.collectedView.hidden = YES;
        
        self.collectedLabel = [[UILabel alloc] init];
        self.collectedLabel.text = @"已收藏";
        self.collectedLabel.textAlignment = NSTextAlignmentCenter;
        self.collectedLabel.textColor = [UIColor whiteColor];
        self.collectedLabel.font = [DXFont dxDefaultFontWithSize:10];
        [self.collectedLabel sizeToFit];
        self.collectedLabel.hidden = YES;
        
        self.prizeIcon = [[UIImageView alloc] init];
        self.prizeIcon.image = [UIImage imageNamed:@"discover_topic_prize"];
        self.prizeIcon.hidden = YES;
        
        [containerView addSubview:self.coverImageView];
        [containerView addSubview:self.topicLabel];
        [containerView addSubview:self.activenessLabel];
        [containerView addSubview:self.subTitleLabel];
        [containerView addSubview:self.collectedView];
        [containerView addSubview:self.collectedLabel];
        [containerView addSubview:self.prizeIcon];
        
        [self.contentView addSubview:containerView];
    }
    return self;
}

- (void)setIsCollected:(BOOL)isCollected {
    _isCollected = isCollected;
    
    if (isCollected) {
        self.collectedView.hidden = NO;
        self.collectedLabel.hidden = NO;
    } else {
        self.collectedView.hidden = YES;
        self.collectedLabel.hidden = YES;
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

- (void)setActiveness:(NSUInteger)activeness {
    _activeness = activeness;
    
    if (activeness < 1000) {
        self.layer.borderColor = GreenColor.CGColor;
        self.activenessLabel.textColor = GreenColor;
        self.activenessLabel.text = [NSString stringWithFormat:@"活跃度%zd", activeness];
    } else if (activeness < 5000) {
        self.layer.borderColor = YellowColor.CGColor;
        self.activenessLabel.textColor = YellowColor;
        self.activenessLabel.text = @"活跃度1000+";
    } else if (activeness < 10000) {
        self.layer.borderColor = OrangeColor.CGColor;
        self.activenessLabel.textColor = OrangeColor;
        self.activenessLabel.text = @"活跃度5000+";
    } else {
        self.layer.borderColor = RedColor.CGColor;
        self.activenessLabel.textColor = RedColor;
        self.activenessLabel.text = @"活跃度10000+";
    }
    
    [self.activenessLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat containerViewW = self.contentView.width;
    CGFloat containerViewH = self.contentView.height - 0.5;
    containerView.frame = CGRectMake(0, 0, containerViewW, containerViewH);
    
    CGFloat coverImageViewX = DXRealValue(25.0/3);
    CGFloat coverImageViewWH = DXRealValue(64);
    self.coverImageView.size = CGSizeMake(coverImageViewWH, coverImageViewWH);
    self.coverImageView.x = coverImageViewX;
    self.coverImageView.centerY = containerViewH * 0.5;
    
    CGFloat topicLabelX = CGRectGetMaxX(self.coverImageView.frame) + DXRealValue(9);
    CGFloat topicLabelY = DXRealValue(12);
    self.topicLabel.origin = CGPointMake(topicLabelX, topicLabelY);
    
    CGFloat activenessLabelX = topicLabelX;
    CGFloat activenessLabelY = DXRealValue(33);
    self.activenessLabel.origin = CGPointMake(activenessLabelX, activenessLabelY);
    
    CGFloat subTitleLabelX = topicLabelX;
    CGFloat subTitleLabelY = DXRealValue(51);
    self.subTitleLabel.origin = CGPointMake(subTitleLabelX, subTitleLabelY);
    
    CGFloat collectedViewW = self.coverImageView.width;
    CGFloat collectedViewH = DXRealValue(18);
    CGFloat collectedViewX = self.coverImageView.x;
    CGFloat collectedViewY = CGRectGetMaxY(self.coverImageView.frame) - collectedViewH;
    self.collectedView.frame = CGRectMake(collectedViewX, collectedViewY, collectedViewW, collectedViewH);
    
    self.collectedLabel.frame = self.collectedView.frame;
    
    CGFloat prizeIconWH = DXRealValue(50.5);
    CGFloat prizeIconX = self.contentView.width - prizeIconWH;
    self.prizeIcon.frame = CGRectMake(prizeIconX, 0, prizeIconWH, prizeIconWH);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
