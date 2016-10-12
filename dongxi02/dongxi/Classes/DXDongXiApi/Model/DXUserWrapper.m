//
//  DXUserWrapper.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserWrapper.h"
#import "DXUser.h"

@implementation DXUserWrapper

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [DXUser class]};
}

@end
