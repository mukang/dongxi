//
//  DXNoticeLikeList.m
//  dongxi
//
//  Created by 穆康 on 15/10/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNoticeLikeList.h"
#import "DXNoticeLike.h"

@implementation DXNoticeLikeList

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [DXNoticeLike class]};
}

@end
