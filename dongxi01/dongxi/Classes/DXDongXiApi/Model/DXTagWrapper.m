//
//  DXTagWrapper.m
//  dongxi
//
//  Created by 穆康 on 16/1/29.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTagWrapper.h"

@implementation DXTagWrapper

+ (NSDictionary *)objectClassInArray{
    return @{
             @"collected": [DXTag class],
             @"all": [DXTag class]
             };
}

@end