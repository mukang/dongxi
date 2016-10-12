//
//  DXTopicInviteFansList.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicInviteFansList.h"
#import "DXUser.h"

@implementation DXTopicInviteFansList

+ (NSDictionary *)objectClassInArray{
    return @{@"top" : [DXUser class], @"list" : [DXUser class]};
}

@end
