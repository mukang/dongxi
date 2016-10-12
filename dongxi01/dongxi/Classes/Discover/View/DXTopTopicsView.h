//
//  DXTopTopicsView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXTopTopicItemView.h"

@protocol DXTopTopicsViewDelegate;

@interface DXTopTopicsView : UIView

@property (nonatomic, strong) DXTopTopicItemView * firstTopTopicView;
@property (nonatomic, strong) DXTopTopicItemView * secondTopTopicView;

@property (nonatomic, weak) id<DXTopTopicsViewDelegate> delegate;

@end


@protocol DXTopTopicsViewDelegate <NSObject>

@optional
- (void)topTopicsView:(DXTopTopicsView *)topicsView didSelectAtIndex:(NSUInteger)index;

@end