//
//  DXUserValidateRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserValidateRequest.h"

@interface DXUserValidateRequest ()

@end

@implementation DXUserValidateRequest

+ (NSDictionary *)validateTypeInfo {
    return @{
             @(DXUserValidateTypeUserName)  : @"username",
             @(DXUserValidateTypeMobile)    : @"mobile",
             @(DXUserValidateTypeEmail)     : @"email"
             };
}

- (void)validate:(DXUserValidateType)type value:(NSString *)value {
    NSDictionary * validateTypeInfo = [[self class] validateTypeInfo];
    NSString * typeString = [validateTypeInfo objectForKey:@(type)];
    NSAssert(typeString != nil, @"无效的验证类型");
    [self setValue:value forParam:typeString];
}

@end
