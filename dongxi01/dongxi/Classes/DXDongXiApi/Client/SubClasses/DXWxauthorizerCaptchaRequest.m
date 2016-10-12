//
//  DXWxauthorizerCaptchaRequest.m
//  dongxi
//
//  Created by 穆康 on 16/6/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXWxauthorizerCaptchaRequest.h"

@implementation DXWxauthorizerCaptchaRequest

- (void)setSms:(DXUserSms *)sms {
    _sms = sms;
    [self setValue:sms.mobile forParam:@"mobile"];
    [self setValue:sms.key forParam:@"key"];
}

@end
