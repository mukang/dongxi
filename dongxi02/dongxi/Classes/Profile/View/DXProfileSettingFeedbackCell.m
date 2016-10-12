//
//  DXProfileSettingFeedbackCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileSettingFeedbackCell.h"

@implementation DXProfileSettingFeedbackCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.settingIconView setImage:[UIImage imageNamed:@"set_feedback"]];
        [self.settingTextLabel setText:@"意见反馈"];
        self.showMoreView = YES;
    }
    return self;
}

@end
