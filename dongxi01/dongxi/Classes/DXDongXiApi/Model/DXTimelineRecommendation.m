//
//  DXTimelineRecommendation.m
//  dongxi
//
//  Created by 穆康 on 16/3/15.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineRecommendation.h"

@implementation DXTimelineRecommendation

+ (NSDictionary *)objectClassInArray{
    return @{
             @"recommend_user"  : [DXUser class],
             @"recommend_topic" : [DXTopic class]
             };
}

@end
