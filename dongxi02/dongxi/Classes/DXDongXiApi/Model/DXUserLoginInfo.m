//
//  DXUserLoginInfo.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserLoginInfo.h"
#import "DXFunctions.h"

@implementation DXUserLoginInfo {
    NSMutableDictionary * _account_info;
    NSMutableDictionary * _summery;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _summery = [NSMutableDictionary dictionary];
        [_summery setObject:DXGetDeviceModel() forKey:@"device"];
        [_summery setObject:DXGetDeviceOSVersion() forKey:@"osver"];
        [_summery setObject:DXGetDeviceUUID() forKey:@"uuid"];
        [_summery setObject:DXGetAppVersion() forKey:@"appver"];
        _account_info = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setAccountInfoWithEmail:(NSString *)email andPassword:(NSString *)password {
    NSAssert(email != nil, @"参数email不能为nil");
    NSAssert(password != nil, @"参数password不能为nil");

    _account_type = DXUserLoginAccountTypeEmail;
    [_account_info setObject:email forKey:@"email"];
    [_account_info setObject:DXDigestMD5(password) forKey:@"password"];
}

- (void)setAccountInfoWithMobile:(NSString *)mobile andPassword:(NSString *)password {
    NSAssert(mobile != nil, @"参数mobile不能为nil");
    NSAssert(password != nil, @"参数password不能为nil");
    
    _account_type = DXUserLoginAccountTypeMobile;
    [_account_info setObject:mobile forKey:@"mobile"];
    [_account_info setObject:DXDigestMD5(password) forKey:@"password"];
}

- (NSDictionary *)summery {
    return [_summery copy];
}

- (NSDictionary *)account_info {
    return [_account_info copy];
}

- (void)setPushID:(NSString *)pushID {
    if (pushID) {
        [_summery setObject:pushID forKey:@"push_id"];
    }
}

@end
