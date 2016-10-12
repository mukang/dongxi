//
//  DXSearchResultsTopicCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/21.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchResultsTopicCell.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Extension.h"
#import "DXTopicActivenessView.h"

@interface DXSearchResultsTopicCell ()

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *descLabel;
@property (nonatomic, weak) DXTopicActivenessView *activenessView;
@property (nonatomic, weak) UIView *separateView;

@end

@implementation DXSearchResultsTopicCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:iconImageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = DXRGBColor(72, 72, 72);
    titleLabel.font = [DXFont dxDefaultFontWithSize:15];
    [self.contentView addSubview:titleLabel];
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.textColor = DXRGBColor(143, 143, 143);
    descLabel.font = [DXFont dxDefaultFontWithSize:(40/3.0)];
    descLabel.numberOfLines = 2;
    descLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    [self.contentView addSubview:descLabel];
    
    DXTopicActivenessView *activenessView = [[DXTopicActivenessView alloc] init];
    [self.contentView addSubview:activenessView];
    
    UIView *separateView = [[UIView alloc] init];
    separateView.backgroundColor = DXRGBColor(200, 200, 200);
    [self.contentView addSubview:separateView];
    
    self.iconImageView = iconImageView;
    self.titleLabel = titleLabel;
    self.descLabel = descLabel;
    self.activenessView = activenessView;
    self.separateView = separateView;
}

- (void)setTopic:(DXTopic *)topic {
    _topic = topic;
    
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(56), DXRealValue(56))];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:topic.cover] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    
    self.titleLabel.attributedText = [self setHighlightedString:self.keywords withOriginString:topic.topic];
    [self.titleLabel sizeToFit];
    
//    self.descLabel.attributedText = [self setHighlightedString:self.keywords withOriginString:topic.txt];
    self.descLabel.text = topic.txt;
    
    self.activenessView.activeness = topic.activeness;
    [self.activenessView sizeToFit];
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat padding = DXRealValue(40/3.0);
    
    self.iconImageView.size = CGSizeMake(DXRealValue(56), DXRealValue(56));
    self.iconImageView.x = padding;
    self.iconImageView.centerY = self.contentView.height * 0.5;
    
    CGFloat titleLabelX = CGRectGetMaxX(self.iconImageView.frame) + padding;
    CGFloat titleLabelY = DXRealValue(10);
    self.titleLabel.origin = CGPointMake(titleLabelX, titleLabelY);
    
    CGFloat descLabelX = titleLabelX;
    CGFloat descLabelY = CGRectGetMaxY(self.titleLabel.frame) + DXRealValue(10);
    CGFloat descLabelW = self.contentView.width - descLabelX - padding;
    self.descLabel.frame = [self.descLabel textRectForBounds:CGRectMake(descLabelX, descLabelY, descLabelW, CGFLOAT_MAX) limitedToNumberOfLines:2];
    
    CGFloat activenessViewX = self.contentView.width - self.activenessView.width - padding;
    CGFloat activenessViewY = DXRealValue(10);
    self.activenessView.origin = CGPointMake(activenessViewX, activenessViewY);
    
    CGFloat separateViewX = padding;
    CGFloat separateViewW = self.contentView.width - separateViewX;
    CGFloat separateViewH = 0.5;
    CGFloat separateViewY = self.contentView.height - separateViewH;
    self.separateView.frame = CGRectMake(separateViewX, separateViewY, separateViewW, separateViewH);
}

- (NSAttributedString *)setHighlightedString:(NSString *)highlightedString withOriginString:(NSString *)originString {
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:originString];
    if (self.keywords) {
        NSRange highlightedRange = [originString rangeOfString:highlightedString options:NSCaseInsensitiveSearch];
        if (highlightedRange.location != NSNotFound) {
            [attrStr addAttribute:NSForegroundColorAttributeName value:DXCommonColor range:highlightedRange];
        }
    }
    return [attrStr copy];
}

@end
