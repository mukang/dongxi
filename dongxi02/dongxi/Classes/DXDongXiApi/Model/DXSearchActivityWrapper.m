//
//  DXSearchActivityWrapper.m
//  dongxi
//
//  Created by 穆康 on 16/1/27.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchActivityWrapper.h"

@implementation DXSearchActivityWrapper

+ (NSDictionary *)objectClassInArray{
    return @{
             @"list": [DXActivity class]
             };
}

@end
