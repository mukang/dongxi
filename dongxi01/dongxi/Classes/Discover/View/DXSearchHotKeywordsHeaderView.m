//
//  DXSearchHotKeywordsHeaderView.m
//  dongxi
//
//  Created by 穆康 on 16/1/20.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchHotKeywordsHeaderView.h"

@interface DXSearchHotKeywordsHeaderView ()

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UIView *separateView;

@end

@implementation DXSearchHotKeywordsHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"热门搜索";
    titleLabel.textColor = DXRGBColor(253, 150, 151);
    titleLabel.font = [DXFont dxDefaultBoldFontWithSize:10];
    [self addSubview:titleLabel];
    [titleLabel sizeToFit];
    
    UIView *separateView = [[UIView alloc] init];
    separateView.backgroundColor = DXRGBColor(222, 222, 222);
    [self addSubview:separateView];
    
    self.titleLabel = titleLabel;
    self.separateView = separateView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.origin = CGPointMake(DXRealValue(13), DXRealValue(18));
    
    self.separateView.size = CGSizeMake(self.width, 0.5);
    self.separateView.origin = CGPointMake(0, self.height - self.separateView.height);
}

@end
