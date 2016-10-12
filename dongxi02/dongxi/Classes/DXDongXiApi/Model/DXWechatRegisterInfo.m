//
//  DXWechatRegisterInfo.m
//  dongxi
//
//  Created by 穆康 on 16/6/17.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXWechatRegisterInfo.h"
#import "DXFunctions.h"

@interface DXWechatRegisterInfo ()

@property (nonatomic, copy) NSString *key;

@end

@implementation DXWechatRegisterInfo

- (void)setMobile:(NSString *)mobile {
    _mobile = mobile;
    _key = DXReverseNSString(DXDigestMD5(DXReverseNSString(mobile)));
}

@end
