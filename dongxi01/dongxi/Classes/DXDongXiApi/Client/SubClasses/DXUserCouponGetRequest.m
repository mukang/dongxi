//
//  DXUserCouponGetRequest.m
//  dongxi
//
//  Created by 穆康 on 15/11/3.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserCouponGetRequest.h"

@implementation DXUserCouponGetRequest

- (void)setMobile:(NSString *)mobile {
    
    _mobile = mobile;
    
    if (mobile) {
        [self setValue:mobile forParam:@"mobile"];
    }
}

@end