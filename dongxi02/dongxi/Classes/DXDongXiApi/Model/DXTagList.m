//
//  DXTagList.m
//  dongxi
//
//  Created by 穆康 on 16/1/13.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTagList.h"
#import "DXTag.h"

@implementation DXTagList

+ (NSDictionary *)objectClassInArray{
    return @{
             @"collected": [DXTag class],
             @"all": [DXTag class]
             };
}

@end
