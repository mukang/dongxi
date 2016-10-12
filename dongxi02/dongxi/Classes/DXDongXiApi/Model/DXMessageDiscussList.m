//
//  DXMessageDiscussList.m
//  dongxi
//
//  Created by 穆康 on 15/9/15.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageDiscussList.h"
#import "DXMessageDiscuss.h"

@implementation DXMessageDiscussList

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [DXMessageDiscuss class]};
}

@end
