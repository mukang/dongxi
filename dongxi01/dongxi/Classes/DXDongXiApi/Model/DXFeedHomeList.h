//
//  DXFeedHomeList.h
//  dongxi
//
//  Created by 穆康 on 16/8/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXFeedHomeList : NSObject

/** 是否还有更多的DXFeed对象未获取完 */
@property (nonatomic, assign) BOOL more;
/** 当前获取到的DXFeed对象的数组 */
@property (nonatomic, strong) NSArray *list;
/** 推荐信息(人和话题) */
@property (nonatomic, strong) DXTimelineRecommendation *recommendation;

@end
