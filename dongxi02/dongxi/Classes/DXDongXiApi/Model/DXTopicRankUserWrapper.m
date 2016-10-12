//
//  DXTopicRankUserWrapper.m
//  dongxi
//
//  Created by 穆康 on 16/2/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicRankUserWrapper.h"

@implementation DXTopicRankUserWrapper

+ (NSDictionary *)objectClassInArray{
    return @{
             @"list"  : [DXRankUser class]
             };
}

@end
