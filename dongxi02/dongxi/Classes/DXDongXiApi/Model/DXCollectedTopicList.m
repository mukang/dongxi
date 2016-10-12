//
//  DXCollectedTopicList.m
//  dongxi
//
//  Created by 穆康 on 16/1/26.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCollectedTopicList.h"

@implementation DXCollectedTopicList

+ (NSDictionary *)objectClassInArray{
    return @{
             @"list": [DXTopic class]
             };
}

@end
