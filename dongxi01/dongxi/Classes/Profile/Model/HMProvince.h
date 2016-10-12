//
//  HMProvince.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.

#import <Foundation/Foundation.h>

@interface HMProvince : NSObject

@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, copy) NSString *name;

+ (instancetype)provinceWithDict:(NSDictionary *)dict;

@end
