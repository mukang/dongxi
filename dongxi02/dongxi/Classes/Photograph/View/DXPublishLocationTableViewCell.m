//
//  DXPublishLocationTableViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishLocationTableViewCell.h"

@implementation DXPublishLocationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [DXFont dxDefaultFontWithSize:45.0/3];
        self.textLabel.textColor = DXRGBColor(66, 189, 205);
        self.detailTextLabel.font = [DXFont dxDefaultFontWithSize:40.0/3];
        self.detailTextLabel.textColor = DXRGBColor(143, 143, 143);
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsZero;
        if ([self respondsToSelector:@selector(layoutMargins)]) {
            self.layoutMargins = UIEdgeInsetsZero;
        }
        
        
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topic_highlighted"]];
        self.accessoryView.hidden = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.accessoryView.hidden = !selected;
}


@end
