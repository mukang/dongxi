//
//  DXRefreshFooter.m
//  dongxi
//
//  Created by 穆康 on 15/10/29.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRefreshFooter.h"

@interface DXRefreshFooter ()

@property (weak, nonatomic) UILabel *label;
@property (weak, nonatomic) UIActivityIndicatorView *loading;

@end

@implementation DXRefreshFooter

#pragma mark - 重写方法
#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 50;
    
    // 添加label
    UILabel *label = [[UILabel alloc] init];
    label.textColor = DXRGBColor(72, 72, 72);
    label.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15.0f)];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.label = label;
    
    // loading
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:loading];
    self.loading = loading;
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    self.label.frame = self.bounds;
    
    self.loading.center = CGPointMake(self.mj_w * 0.5 - DXRealValue(90.0f), self.mj_h * 0.5);
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
            self.label.text = @"上拉加载更多";
            [self.loading stopAnimating];
            break;
        case MJRefreshStatePulling:
            [self.loading stopAnimating];
            self.label.text = @"松开立即加载";
            break;
        case MJRefreshStateRefreshing:
            self.label.text = @"正在加载更多";
            [self.loading startAnimating];
            break;
        case MJRefreshStateNoMoreData:
            self.label.text = @"已经全部加载完毕";
            [self.loading stopAnimating];
            break;
        default:
            break;
    }
}

@end
