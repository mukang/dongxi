//
//  DXSettingFourCell.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileSettingAboutUsCell.h"

@implementation DXProfileSettingAboutUsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.settingIconView setImage:[UIImage imageNamed:@"set_about"]];
        [self.settingTextLabel setText:@"关于东西"];
        self.showMoreView = YES;
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
