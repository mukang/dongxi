//
//  DXUserCouponSendRequest.m
//  dongxi
//
//  Created by 穆康 on 15/10/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserCouponSendRequest.h"

@implementation DXUserCouponSendRequest

- (void)setCode:(NSString *)code {
    
    _code = code;
    
    if (code) {
        [self setValue:code forParam:@"code"];
    }
}

@end
