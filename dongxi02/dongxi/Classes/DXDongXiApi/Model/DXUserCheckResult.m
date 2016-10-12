//
//  DXUserCheckResult.m
//  dongxi
//
//  Created by 穆康 on 16/2/2.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserCheckResult.h"

@implementation DXUserCheckResult

+ (NSDictionary *)objectClassInDictionary{
    return @{
             @"version"       : [DXUserCheckResultVersion class],
             @"notification"  : [DXUserCheckResultNotification class]
             };
}

@end

@implementation DXUserCheckResultVersion



@end

@implementation DXUserCheckResultNotification



@end
