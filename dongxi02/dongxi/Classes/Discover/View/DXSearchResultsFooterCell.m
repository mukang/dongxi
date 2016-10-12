//
//  DXSearchResultsFooterCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/21.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchResultsFooterCell.h"

#define Image_Label_Margin DXRealValue(9)  // 图片和标题的间距

@interface DXSearchResultsFooterCell ()

@property (nonatomic, weak) UIButton *moreBtn;

@end

@implementation DXSearchResultsFooterCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn setTitleColor:DXRGBColor(90, 117, 157) forState:UIControlStateNormal];
    moreBtn.titleLabel.font = [DXFont dxDefaultFontWithSize:40/3.0];
    [moreBtn setImage:[UIImage imageNamed:@"discover_secreh_more_button"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:moreBtn];
    
    self.moreBtn = moreBtn;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    [self.moreBtn setTitle:title forState:UIControlStateNormal];
    [self.moreBtn sizeToFit];
    self.moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, Image_Label_Margin);
    self.moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, Image_Label_Margin, 0, 0);
    self.moreBtn.size = CGSizeMake(self.moreBtn.width + Image_Label_Margin, self.moreBtn.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.moreBtn.centerY = self.contentView.height * 0.5;
    self.moreBtn.x = self.contentView.width - self.moreBtn.width - DXRealValue(18);
}

- (void)moreBtnDidClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchResultsFooterCell:didTapSearchMoreWithIndexPath:)]) {
        [self.delegate searchResultsFooterCell:self didTapSearchMoreWithIndexPath:self.indexPath];
    }
}

@end
