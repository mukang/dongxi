//
//  DXSettingFiveCell.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileSettingLogoutCell.h"


@implementation DXProfileSettingLogoutCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        /** 设置分隔线样式，针对iOS [7.0, 8.0) */
        self.separatorInset = UIEdgeInsetsZero;
        
        /** 改变分隔线样式：设置layoutMargins，针对iOS (>=8.0) */
        if ([self respondsToSelector:@selector(layoutMargins)]) {
            self.layoutMargins = UIEdgeInsetsZero;
        }
        
        /** 改变分隔线样式：阻止使用父视图的layoutMargins，针对iOS (>=8.0) */
        if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            self.preservesSuperviewLayoutMargins = NO;
        }
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton * logoutButton = [[UIButton alloc] initWithFrame:self.bounds];
        logoutButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        NSDictionary * titleAttributes = @{
                                           NSFontAttributeName : [DXFont dxDefaultBoldFontWithSize:50.0/3],
                                           NSForegroundColorAttributeName : DXRGBColor(255, 128, 129)
                                           };
        NSAttributedString * title = [[NSAttributedString alloc] initWithString:@"退出" attributes:titleAttributes];
        [logoutButton setAttributedTitle:title forState:UIControlStateNormal];
        [self addSubview:logoutButton];
        
        self.logoutButton = logoutButton;
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
