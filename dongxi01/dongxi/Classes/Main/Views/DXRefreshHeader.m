//
//  DXRefreshHeader.m
//  dongxi
//
//  Created by 穆康 on 15/10/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRefreshHeader.h"

@implementation DXRefreshHeader

- (void)prepare {
    
    [super prepare];
    
    self.stateLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15.0f)];
    self.lastUpdatedTimeLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(14.0f)];
}

/*
- (void)prepare
{
    [super prepare];
    
    // 隐藏时间
    self.lastUpdatedTimeLabel.hidden = YES;
    
    // 隐藏状态
    self.stateLabel.hidden = YES;
    
    CGFloat scale = 414.0f / DXScreenWidth * 3.0f;
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 0; i<=91; i++) {
        NSString *imageName = [NSString stringWithFormat:@"refresh1__%03zd@3x.png", i];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:imageData scale:scale];
        [idleImages addObject:image];
    }
    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 0; i<=93; i++) {
        NSString *imageName = [NSString stringWithFormat:@"refresh2__%02zd@3x.png", i];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:imageData scale:scale];
        [refreshingImages addObject:image];
    }
    
    // 设置正在刷新状态的动画图片
    [self setImages:refreshingImages duration:2.5f forState:MJRefreshStateRefreshing];
}
 */

@end
