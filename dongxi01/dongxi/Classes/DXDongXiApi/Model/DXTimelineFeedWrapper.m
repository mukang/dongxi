//
//  DXTimelineFeedWrapper.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineFeedWrapper.h"
#import "DXTimelineFeed.h"

@implementation DXTimelineFeedWrapper

+ (NSDictionary *)objectClassInDictionary{
    return @{@"recommendation" : [DXTimelineRecommendation class]};
}

+ (NSDictionary *)objectClassInArray{
    return @{@"feeds" : [DXTimelineFeed class]};
}

@end




