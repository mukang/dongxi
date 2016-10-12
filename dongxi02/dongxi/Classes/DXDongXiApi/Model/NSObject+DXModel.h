//
//  NSObject+DXModel.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DXMODEL_SYSTEM_VARIABLES_MAP
#define DXMODEL_SYSTEM_VARIABLES_MAP @{@"ID":@"id"}
#endif

@interface NSObject (DXModel)

- (NSArray *)allPropertyNames;

- (instancetype)initWithObjectDictionary:(NSDictionary *)dic;

+ (NSArray *)objectArrayFromObjectDictionaryArray:(NSArray *)array;

- (NSDictionary *)toObjectDictionary;
- (NSDictionary *)toObjectDictionary:(BOOL)recursive;

+ (NSDictionary *)objectClassInArray;

+ (NSDictionary *)objectClassInDictionary;

- (void)encodeWithCoder:(NSCoder *)aCoder;

- (id)initWithCoder:(NSCoder *)aDecoder;

@end