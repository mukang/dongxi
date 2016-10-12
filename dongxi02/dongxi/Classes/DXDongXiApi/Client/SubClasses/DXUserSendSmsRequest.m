//
//  DXUserSendSmsRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserSendSmsRequest.h"
#import "DXUserSms.h"

@implementation DXUserSendSmsRequest

- (void)setSms:(DXUserSms *)sms {
    _sms = sms;
    [self setValue:sms.mobile forParam:@"mobile"];
    [self setValue:sms.key forParam:@"key"];
}

@end
