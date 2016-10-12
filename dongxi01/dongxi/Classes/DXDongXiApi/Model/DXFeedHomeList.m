//
//  DXFeedHomeList.m
//  dongxi
//
//  Created by 穆康 on 16/8/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedHomeList.h"

@implementation DXFeedHomeList

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [DXFeed class]};
}

+ (NSDictionary *)objectClassInDictionary{
    return @{@"recommendation" : [DXTimelineRecommendation class]};
}

@end
