//
//  DXMessageCell.m
//  dongxi
//
//  Created by 穆康 on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageCell.h"

@interface DXMessageCell ()

/**
 *  箭头
 */
@property (nonatomic, weak) UIImageView *arrowImageV;
/**
 *  新消息提示的小红点
 */
@property (nonatomic, weak) UIView *dotView;


@end

@implementation DXMessageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"MessageCell";
    
    DXMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setup];
    }
    return self;
}

// 初始化子控件
- (void)setup {
    
    UIImageView *iconImageV = [[UIImageView alloc] init];
    [self.contentView addSubview:iconImageV];
    self.iconImageV = iconImageV;
    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.textColor = DXRGBColor(72, 72, 72);
    titleL.textAlignment = NSTextAlignmentLeft;
    titleL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(18.0f)];
    [self.contentView addSubview:titleL];
    self.titleL = titleL;
    
    UIImageView *arrowImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_news_more"]];
    [self.contentView addSubview:arrowImageV];
    self.arrowImageV = arrowImageV;
    
    UIView *separatorV = [[UIView alloc] init];
    separatorV.backgroundColor = DXRGBColor(208, 208, 208);
    [self.contentView addSubview:separatorV];
    self.separatorV = separatorV;
    
    UIView *dotView = [[UIView alloc] init];
    dotView.backgroundColor = DXRGBColor(255, 115, 115);
    dotView.hidden = YES;
    [self.contentView addSubview:dotView];
    self.dotView = dotView;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.iconImageV.size = CGSizeMake(DXRealValue(40), DXRealValue(40));
    self.iconImageV.x = DXRealValue(18);
    self.iconImageV.centerY = self.contentView.height * 0.5;
    
    self.titleL.size = CGSizeMake(DXRealValue(100), DXRealValue(30));
    self.titleL.x = CGRectGetMaxX(self.iconImageV.frame) + DXRealValue(18);
    self.titleL.centerY = self.iconImageV.centerY;
    
    self.arrowImageV.size = CGSizeMake(DXRealValue(8), DXRealValue(13));
    self.arrowImageV.x = self.contentView.width - self.arrowImageV.width - DXRealValue(13);
    self.arrowImageV.centerY = self.iconImageV.centerY;
    
    self.separatorV.size = CGSizeMake(self.contentView.width, 0.5);
    self.separatorV.x = 0;
    self.separatorV.y = self.contentView.height - self.separatorV.height;
    
    self.dotView.size = CGSizeMake(8.0f, 8.0f);
    self.dotView.x = CGRectGetMaxX(self.iconImageV.frame);
    self.dotView.y = DXRealValue(5.0f);
    self.dotView.layer.cornerRadius = self.dotView.width * 0.5f;
    self.dotView.layer.masksToBounds = YES;
}

- (void)setHasUnReadMessage:(BOOL)hasUnReadMessage {
    
    _hasUnReadMessage = hasUnReadMessage;
    
    self.dotView.hidden = !hasUnReadMessage;
}

@end
