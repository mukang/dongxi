//
//  DXSearchNoResultsCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/25.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchNoResultsCell.h"

@interface DXSearchNoResultsCell ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *noResultsView;

@end

@implementation DXSearchNoResultsCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"抱歉，在这颗星球上没有找到您需要的内容";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = DXRGBColor(143, 143, 143);
    titleLabel.font = [DXFont dxDefaultFontWithSize:15];
    titleLabel.numberOfLines = 2;
    [self.contentView addSubview:titleLabel];
    
    UIImageView *noResultsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"discover_search_noResults"]];
    [self.contentView addSubview:noResultsView];
    
    self.titleLabel = titleLabel;
    self.noResultsView = noResultsView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat titleLabelW = DXRealValue(334);
    CGFloat titleLabelH = [self.titleLabel textRectForBounds:CGRectMake(0, 0, titleLabelW, CGFLOAT_MAX) limitedToNumberOfLines:2].size.height;
    self.titleLabel.size = CGSizeMake(titleLabelW, titleLabelH);
    self.titleLabel.centerX = self.contentView.width * 0.5;
    self.titleLabel.y = DXRealValue(84);
    
    self.noResultsView.size = CGSizeMake(DXRealValue(104), DXRealValue(104.5));
    self.noResultsView.centerX = self.contentView.width * 0.5;
    self.noResultsView.y = DXRealValue(171);
}

@end
