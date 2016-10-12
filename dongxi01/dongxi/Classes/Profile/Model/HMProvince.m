//
//  HMProvince.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.

#import "HMProvince.h"

@implementation HMProvince

+ (instancetype)provinceWithDict:(NSDictionary *)dict
{
    HMProvince *province = [[self alloc] init];
    
    [province setValuesForKeysWithDictionary:dict];
    
    return province;
}

@end
