//
//  DXProfileSettingShareCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileSettingShareCell.h"

@implementation DXProfileSettingShareCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.settingIconView setImage:[UIImage imageNamed:@"set_share"]];
        [self.settingTextLabel setText:@"把东西介绍给朋友"];
    }
    return self;
}

@end
