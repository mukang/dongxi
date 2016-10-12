//
//  DXUserLoginRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserLoginRequest.h"
#import "DXClientFunctions.h"
#import "DXUserLoginInfo.h"
#import "NSObject+DXModel.h"

@implementation DXUserLoginRequest

- (void)setLoginInfo:(DXUserLoginInfo *)loginInfo {
    _loginInfo = loginInfo;
    NSDictionary * loginData = [loginInfo toObjectDictionary];
    for (NSString * dataKey in loginData.allKeys) {
        [self setValue:[loginData objectForKey:dataKey] forParam:dataKey];
    }
}

@end
