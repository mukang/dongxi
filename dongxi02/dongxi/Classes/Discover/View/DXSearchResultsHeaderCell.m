//
//  DXSearchResultsHeaderCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/21.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchResultsHeaderCell.h"

@interface DXSearchResultsHeaderCell ()

@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation DXSearchResultsHeaderCell

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
    titleLabel.textColor = DXRGBColor(143, 143, 143);
    titleLabel.font = [DXFont dxDefaultBoldFontWithSize:(40/3.0)];
    [self.contentView addSubview:titleLabel];
    
    UIView *separateView = [[UIView alloc] init];
    separateView.backgroundColor = DXRGBColor(177, 177, 177);
    [self.contentView addSubview:separateView];
    
    self.titleLabel = titleLabel;
    self.separateView = separateView;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.origin = CGPointMake(DXRealValue(40/3.0), DXRealValue(9));
    
    self.separateView.size = CGSizeMake(self.contentView.width, 0.5);
    self.separateView.origin = CGPointMake(0, self.contentView.height - self.separateView.height);
}

@end
