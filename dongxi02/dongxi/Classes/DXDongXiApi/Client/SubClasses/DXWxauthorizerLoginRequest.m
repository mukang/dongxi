//
//  DXWxauthorizerLoginRequest.m
//  dongxi
//
//  Created by 穆康 on 16/6/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXWxauthorizerLoginRequest.h"
#import "NSObject+DXModel.h"

@implementation DXWxauthorizerLoginRequest

- (void)setLoginInfo:(DXWechatLoginInfo *)loginInfo {
    _loginInfo = loginInfo;
    
    NSDictionary *loginData = [loginInfo toObjectDictionary];
    for (NSString *dataKey in loginData.allKeys) {
        [self setValue:[loginData objectForKey:dataKey] forParam:dataKey];
    }
}

@end
