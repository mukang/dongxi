//
//  DXLikeRankUserWrapper.m
//  dongxi
//
//  Created by 穆康 on 16/3/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLikeRankUserWrapper.h"

@implementation DXLikeRankUserWrapper

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [DXRankUser class]};
}

+ (NSDictionary *)objectClassInDictionary{
    return @{@"info" : [DXLikeRankInfo class]};
}

@end

@implementation DXLikeRankInfo

@end
