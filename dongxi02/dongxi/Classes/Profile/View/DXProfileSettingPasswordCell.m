//
//  DXProfileSettingPasswordCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/6.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileSettingPasswordCell.h"

@implementation DXProfileSettingPasswordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.settingTextLabel.text = @"修改密码";
        self.settingIconView.image = [UIImage imageNamed:@"set_cecret"];
        self.showMoreView = YES;
    }
    return self;
}

@end
