//
//  DXDetailLocationCell.m
//  dongxi
//
//  Created by 穆康 on 15/8/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDetailLocationCell.h"
#import "DXDongXiApi.h"

#define TopMargin                   DXRealValue(7)   // 顶部间距
#define LocImageVW                  DXRealValue(12)  // 定位图标宽
#define LocImageVH                  DXRealValue(17)  // 定位图标高
#define LocImageV_LocLabel_Margin   DXRealValue(8)   // 定位图标和地址间距

@interface DXDetailLocationCell ()

/** 背景 */
@property (nonatomic, weak) UIView *bgView;
/** 定位图标 */
@property (nonatomic, weak) UIImageView *locImageV;
/** 地址 */
@property (nonatomic, weak) UILabel *locLabel;
/** 指示箭头 */
@property (nonatomic, weak) UIImageView *indicatorV;

@end

@implementation DXDetailLocationCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"locCell";
    
    DXDetailLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXDetailLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = DXRGBColor(222, 222, 222);
        
        [self setup];
    }
    return self;
}

// 初始化子控件
- (void)setup {
    
    // 背景
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bgView];
    self.bgView = bgView;
    
    // 定位图标
    UIImageView *locImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_location_feed"]];
    [self.bgView addSubview:locImageV];
    self.locImageV = locImageV;
    
    // 地址
    UILabel *locLabel = [[UILabel alloc] init];
    locLabel.textColor = DXRGBColor(48, 48, 48);
    locLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    [self.bgView addSubview:locLabel];
    self.locLabel = locLabel;
    
    // 箭头
    UIImageView *indicatorV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_small_grew"]];
    [self.bgView addSubview:indicatorV];
    self.indicatorV = indicatorV;
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    // 地址
    self.locLabel.text = feed.data.place;
    [self.locLabel sizeToFit];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 背景
    CGFloat bgViewY = TopMargin;
    CGFloat bgViewW = self.contentView.width;
    CGFloat bgViewH = DXRealValue(44);
    self.bgView.frame = CGRectMake(0, bgViewY, bgViewW, bgViewH);
    
    // 定位图标
    self.locImageV.size = CGSizeMake(LocImageVW, LocImageVH);
    self.locImageV.x = (bgViewW - (LocImageVW + LocImageV_LocLabel_Margin + self.locLabel.width)) * 0.5;
    self.locImageV.centerY = bgViewH * 0.5;
    
    // 地址
    self.locLabel.x = CGRectGetMaxX(self.locImageV.frame) + LocImageV_LocLabel_Margin;
    self.locLabel.centerY = self.locImageV.centerY;
    
    // 箭头
    self.indicatorV.size = CGSizeMake(DXRealValue(10), DXRealValue(14));
    self.indicatorV.centerY = self.locImageV.centerY;
    self.indicatorV.x = bgViewW - self.indicatorV.width - DXRealValue(10);
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withFeed:(DXTimelineFeed *)feed {
    
    return TopMargin + DXRealValue(44);
}

@end
