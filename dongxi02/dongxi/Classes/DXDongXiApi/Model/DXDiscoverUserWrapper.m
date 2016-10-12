//
//  DXDiscoverUserWrapper.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDiscoverUserWrapper.h"
#import "DXDiscoverUser.h"

@implementation DXDiscoverUserWrapper

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [DXDiscoverUser class]};
}

@end
