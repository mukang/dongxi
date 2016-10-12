//
//  DXFeedLikeView.h
//  dongxi
//
//  Created by 穆康 on 15/10/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  工具栏上点赞控件

#import <UIKit/UIKit.h>

@interface DXFeedLikeView : UIView

/** 是否是已经点赞 */
@property (nonatomic, assign, getter=isLike) BOOL like;

/*
- (void)startLikeAnimating;

- (void)setLiked:(BOOL)liked anmated:(BOOL)animated completion:(void (^)(void))completion;

- (BOOL)isLikeAnimating;
 */

@end
