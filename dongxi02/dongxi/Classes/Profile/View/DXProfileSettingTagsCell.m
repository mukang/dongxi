//
//  DXProfileSettingTagsCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/15.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileSettingTagsCell.h"

@implementation DXProfileSettingTagsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.settingIconView setImage:[UIImage imageNamed:@"set_tags"]];
        [self.settingTextLabel setText:@"关注的标签"];
        self.showMoreView = YES;
    }
    return self;
}

@end
