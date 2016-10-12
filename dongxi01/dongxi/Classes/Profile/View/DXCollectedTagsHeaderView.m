//
//  DXCollectedTagsHeaderView.m
//  dongxi
//
//  Created by 穆康 on 16/1/14.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCollectedTagsHeaderView.h"

@interface DXCollectedTagsHeaderView ()

@property (nonatomic, weak) UIView *separateView;
@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation DXCollectedTagsHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *separateView = [[UIView alloc] init];
    separateView.backgroundColor = DXRGBColor(222, 222, 222);
    [self addSubview:separateView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"我关注的标签";
    titleLabel.textColor = DXRGBColor(143, 143, 143);
    titleLabel.font = [DXFont dxDefaultBoldFontWithSize:16];
    [self addSubview:titleLabel];
    [titleLabel sizeToFit];
    
    self.separateView = separateView;
    self.titleLabel = titleLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.separateView.frame = CGRectMake(0, 0, self.width, DXRealValue(20/3));
    
    self.titleLabel.x = DXRealValue(40/3);
    self.titleLabel.y = self.height - self.titleLabel.height;
}

@end
