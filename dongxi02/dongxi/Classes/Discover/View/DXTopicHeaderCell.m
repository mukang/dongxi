//
//  DXTopicHeaderCell.m
//  dongxi
//
//  Created by 穆康 on 16/2/3.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicHeaderCell.h"

@interface DXTopicHeaderCell ()

@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation DXTopicHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = DXRGBColor(143, 143, 143);
    titleLabel.font = [DXFont dxDefaultFontWithSize:13];
    [self.contentView addSubview:titleLabel];
    
    UIView *separateView = [[UIView alloc] init];
    separateView.backgroundColor = DXRGBColor(222, 222, 222);
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
    
    self.titleLabel.x = DXRealValue(20.0/3);
    self.titleLabel.centerY = self.contentView.height * 0.5;
    
    CGFloat separateViewW = self.contentView.width;
    CGFloat separateViewH = 0.5;
    CGFloat separateViewY = self.contentView.height - separateViewH;
    self.separateView.frame = CGRectMake(0, separateViewY, separateViewW, separateViewH);
}

@end
