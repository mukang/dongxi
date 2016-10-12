//
//  UITabBar+Badge.h
//  dongxi
//
//  Created by 穆康 on 15/11/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (Badge)

/** 显示小红点 */
- (void)showBadgeOnItemIndex:(int)index;

/** 隐藏小红点 */
- (void)hideBadgeOnItemIndex:(int)index;

@end
