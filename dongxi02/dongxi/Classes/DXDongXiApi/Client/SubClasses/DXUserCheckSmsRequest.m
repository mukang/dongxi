//
//  DXUserCheckSmsRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserCheckSmsRequest.h"
#import "DXUserSmsCheck.h"

@implementation DXUserCheckSmsRequest

- (void)setSmsCheck:(DXUserSmsCheck *)smsCheck {
    _smsCheck = smsCheck;
    NSAssert(smsCheck.mobile, @"验证手机号不能为空");
    NSAssert(smsCheck.code, @"验证码不能为空");
    [self setValue:smsCheck.mobile forParam:@"mobile"];
    [self setValue:smsCheck.code forParam:@"code"];
}

@end
