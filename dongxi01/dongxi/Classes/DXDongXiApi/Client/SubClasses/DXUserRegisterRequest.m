//
//  DXUserRegisterRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserRegisterRequest.h"
#import "DXUserRegisterInfo.h"
#import "DXFunctions.h"
#import "NSObject+DXModel.h"

@implementation DXUserRegisterRequest

- (void)setUserRegister:(DXUserRegisterInfo *)userRegister {
    _userRegister = userRegister;
    NSDictionary * userReigsterData = [userRegister toObjectDictionary];
    for (NSString * dataKey in userReigsterData.allKeys) {
        [self setValue:[userReigsterData objectForKey:dataKey] forParam:dataKey];
    }
}

- (void)prepareToSend {
    NSString * password = [self valueForParam:@"password"];
    [self setValue:DXDigestMD5(password) forParam:@"password"];
}

@end
