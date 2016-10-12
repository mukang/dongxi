//
//  DXUserPasswordChangeInfo.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserPasswordChangeInfo.h"
#import "DXFunctions.h"

@implementation DXUserPasswordChangeInfo

- (NSString *)key {
    if (self.newpassword) {
        NSString * md5Password = DXDigestMD5(self.newpassword);
        return DXReverseNSString(DXDigestMD5(DXReverseNSString(md5Password)));
    } else {
        return nil;
    }
}

@end
