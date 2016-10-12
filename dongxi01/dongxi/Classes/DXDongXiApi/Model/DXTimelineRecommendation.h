//
//  DXTimelineRecommendation.h
//  dongxi
//
//  Created by 穆康 on 16/3/15.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DXRecommendationType) {
    DXRecommendationTypeUser,
    DXRecommendationTypeTopic
};

@interface DXTimelineRecommendation : NSObject

/** 推荐人 */
@property (nonatomic, strong) NSArray *recommend_user;
/** 推荐话题 */
@property (nonatomic, strong) NSArray *recommend_topic;
/** 时间戳 */
@property (nonatomic, assign) NSUInteger timestamp_for_user;
@property (nonatomic, assign) NSUInteger timestamp_for_topic;
/** 类型 */
@property (nonatomic, assign) DXRecommendationType type;

@end
