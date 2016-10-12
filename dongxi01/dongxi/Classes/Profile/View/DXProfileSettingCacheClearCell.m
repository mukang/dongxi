//
//  DXSettingThreeCell.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileSettingCacheClearCell.h"

@interface DXProfileSettingCacheClearCell ()

@property(nonatomic,strong) UIView *line;

@end

@implementation DXProfileSettingCacheClearCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.settingTextLabel.text = @"清除缓存";
        self.settingIconView.image = [UIImage imageNamed:@"set_clean"];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
