//
//  DXProfileUpdateLocationCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileUpdateLocationCell.h"

@implementation DXProfileUpdateLocationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel.text = @"地区";
    }
    return self;
}

@end
