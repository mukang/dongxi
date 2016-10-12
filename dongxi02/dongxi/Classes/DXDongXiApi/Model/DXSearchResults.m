//
//  DXSearchResults.m
//  dongxi
//
//  Created by 穆康 on 16/1/21.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchResults.h"

@implementation DXSearchResults

+ (NSDictionary *)objectClassInDictionary{
    return @{
             @"topic"    : [DXSearchTopicWrapper class],
             @"user"     : [DXSearchUserWrapper class],
             @"activity" : [DXSearchActivityWrapper class],
             @"feed"     : [DXSearchFeedWrapper class]
             };
}

@end
