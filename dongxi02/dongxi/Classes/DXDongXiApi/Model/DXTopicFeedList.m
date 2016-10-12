//
//  DXTopicFeedList.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicFeedList.h"
#import "DXTimelineFeed.h"

@implementation DXTopicFeedList

NSString * const DXTopicFeedListTypeNew     = @"new";
NSString * const DXTopicFeedListTypeHot     = @"hot";

+ (NSDictionary *)objectClassInArray{
    return @{
             @"feeds" : [DXTimelineFeed class],
             @"rank"  : [DXRankUser class]
             };
}

+ (NSDictionary *)objectClassInDictionary{
    return @{@"topic" : [DXTopicDetail class]};
}

@end



@implementation DXTopicDetail

@end


