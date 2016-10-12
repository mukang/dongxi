//
//  DXAppVersionViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXAppVersionViewCell.h"
#import "DXAppVersionView.h"

@implementation DXAppVersionViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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
        
        DXAppVersionView * appVersionView = [[DXAppVersionView alloc] initWithFrame:self.bounds];
        appVersionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:appVersionView];
    }
    return self;
}

@end
