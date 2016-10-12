//
//  DXUserPasswordResetInfo.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserPasswordResetInfo.h"
#import "DXFunctions.h"

@implementation DXUserPasswordResetInfo

- (NSString *)key {
    if (self.code) {
        return DXReverseNSString(DXDigestMD5(DXReverseNSString(self.code)));
    } else {
        return nil;
    }
}

@end
