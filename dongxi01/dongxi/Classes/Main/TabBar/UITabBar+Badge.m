//
//  UITabBar+Badge.m
//  dongxi
//
//  Created by 穆康 on 15/11/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "UITabBar+Badge.h"

static const int TabBarItemNums = 5;
static const int DefaultTag     = 10080;

@implementation UITabBar (Badge)

- (void)showBadgeOnItemIndex:(int)index {
    
    [self removeBadgeOnItemIndex:index];
    
    UIView *badgeView = [[UIView alloc] init];
    badgeView.tag = DefaultTag + index;
    badgeView.backgroundColor = DXRGBColor(255, 115, 115);
    
    float percentX = (index + 0.6f) / TabBarItemNums;
    CGFloat badgeViewX = ceilf(percentX * self.width);
    CGFloat badgeViewY = ceilf(0.1 * self.height);
    CGFloat badgeViewWH = 8.0f;
    badgeView.frame = CGRectMake(badgeViewX, badgeViewY, badgeViewWH, badgeViewWH);
    badgeView.layer.cornerRadius = badgeViewWH * 0.5f;
    [self addSubview:badgeView];
}

- (void)hideBadgeOnItemIndex:(int)index {
    
    [self removeBadgeOnItemIndex:index];
}

- (void)removeBadgeOnItemIndex:(int)index {
    
    for (UIView *view in self.subviews) {
        if (view.tag == DefaultTag + index) {
            [view removeFromSuperview];
        }
    }
}

@end
