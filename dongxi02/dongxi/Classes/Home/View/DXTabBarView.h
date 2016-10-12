//
//  DXTabBarView.h
//  dongxi
//
//  Created by 穆康 on 15/8/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DXTabBarViewDelegate;


@interface DXTabBarView : UIView

/**
 *  创建一个有动画、可切换的标签栏
 *
 *  @param frame frame
 *  @param count 标签按钮数量
 *  @param names 标签按钮标题数组
 *
 *  @return 标签栏
 */
- (instancetype)initWithFrame:(CGRect)frame tabCount:(int)count names:(NSArray *)names;

@property (nonatomic, weak) id<DXTabBarViewDelegate> delegate;

@property (nonatomic, assign) UIEdgeInsets contentInsets;

- (void)setName:(NSString *)name atTabIndex:(NSUInteger)tabIndex;

- (void)selectIndex:(NSUInteger)index;

@end


@protocol DXTabBarViewDelegate <NSObject>

@optional

- (void)tabBarView:(DXTabBarView *)view didTapButtonAtIndex:(NSUInteger)index;

- (UIFont *)titleFontInTabBarView:(DXTabBarView *)tabBarView;

@end