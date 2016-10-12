//
//  DXRefreshAutoFooter.m
//  dongxi
//
//  Created by 穆康 on 15/11/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRefreshAutoFooter.h"

static const CGFloat defaultHeight = 50;

@interface DXRefreshAutoFooter ()

@property (weak, nonatomic) UILabel *label;
@property (weak, nonatomic) UIActivityIndicatorView *loading;
@property (nonatomic, assign, getter=isError) BOOL error;

@end

@implementation DXRefreshAutoFooter

#pragma mark - 重写方法
#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = defaultHeight;
    self.error = NO;
    
    // 添加label
    UILabel *label = [[UILabel alloc] init];
    label.textColor = DXRGBColor(72, 72, 72);
    label.font = [DXFont fontWithName:DXCommonFontName size:15];
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
    self.loading.center = CGPointMake(self.mj_w * 0.5 - 90, self.mj_h * 0.5);
    self.triggerAutomaticallyRefreshPercent = 0.3;
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
            self.label.text = self.idleText ? self.idleText : @"上拉加载更多";
            [self.loading stopAnimating];
            break;
        case MJRefreshStateRefreshing:
            self.label.text = self.refreshingText ? self.refreshingText : @"正在加载更多";
            if (!self.isError) {
                [self.loading startAnimating];
            }
            break;
        case MJRefreshStateNoMoreData:
            self.label.text = self.noMoreDataText ? self.noMoreDataText : @"已经全部加载完毕";
            [self.loading stopAnimating];
            break;
        default:
            break;
    }
}

- (void)endRefreshingWithError {
    
    self.state = MJRefreshStateIdle;
    
    if (!self.isError && !self.isHidden) {
        CGFloat lastHeight = self.mj_h;
        self.error = YES;
        self.mj_h = 1;
        self.label.hidden = YES;
        self.loading.hidden = YES;
        self.scrollView.mj_insetB -= (lastHeight - self.mj_h);
    }
}

- (void)endRefreshing {
    [super endRefreshing];
    
    if (self.isError && !self.isHidden) {
        CGFloat lastHeight = self.mj_h;
        self.error = NO;
        self.mj_h = defaultHeight;
        self.label.hidden = NO;
        self.loading.hidden = NO;
        self.scrollView.mj_insetB += (self.mj_h - lastHeight);
    }
}


- (void)setIdleText:(NSString *)idleText {
    _idleText = idleText;
    
    if (self.state == MJRefreshStateIdle) {
        self.label.text = idleText;
    }
}

- (void)setRefreshingText:(NSString *)refreshingText {
    _refreshingText = refreshingText;
    
    if (self.state == MJRefreshStateRefreshing) {
        self.label.text = refreshingText;
    }
}

- (void)setNoMoreDataText:(NSString *)noMoreDataText {
    _noMoreDataText = noMoreDataText;
    
    if (self.state == MJRefreshStateNoMoreData) {
        self.label.text = noMoreDataText;
    }
}

@end
