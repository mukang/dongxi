//
//  DXUserChangePwdRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserChangePwdRequest.h"
#import "DXFunctions.h"

@implementation DXUserChangePwdRequest

- (void)prepareToSend {
    NSString * newpassword = [self valueForKey:@"newpassword"];
    if (newpassword) {
        [self setValue:DXDigestMD5(newpassword) forKey:@"newpassword"];
    }
    
    NSString * oldpassword = [self valueForKey:@"oldpassword"];
    if (oldpassword) {
        [self setValue:DXDigestMD5(oldpassword) forKey:@"oldpassword"];
    }
}

@end
