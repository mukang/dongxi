//
//  DXTimelineFeedWrapper.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DXTimelineRecommendation;

@interface DXTimelineFeedWrapper : NSObject

/** 当前获取到的DXTimelineFeed对象的数量 */
@property (nonatomic, assign) NSInteger count;

/** 当前获取到的DXTimelineFeed对象的数组 */
@property (nonatomic, strong) NSArray *feeds;

@property (nonatomic, strong) DXTimelineRecommendation *recommendation;

/** 是否还有更多的DXTimelineFeed对象未获取完 */
@property (nonatomic, assign) BOOL more;

@end


