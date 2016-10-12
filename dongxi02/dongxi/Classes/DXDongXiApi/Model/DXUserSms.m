//
//  DXUserSms.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserSms.h"
#import "DXFunctions.h"

@implementation DXUserSms

- (void)setMobile:(NSString *)mobile {
    _mobile = mobile;
    _key = DXReverseNSString(DXDigestMD5(DXReverseNSString(mobile)));
}

+ (instancetype)newUserSmsWithMobile:(NSString *)mobile {
    id userSms = [[self class] new];
    [userSms setMobile:mobile];
    return userSms;
}

@end
