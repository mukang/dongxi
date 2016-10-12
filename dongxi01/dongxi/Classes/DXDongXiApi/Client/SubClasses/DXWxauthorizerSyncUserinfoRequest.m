//
//  DXWxauthorizerSyncUserinfoRequest.m
//  dongxi
//
//  Created by 穆康 on 16/6/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXWxauthorizerSyncUserinfoRequest.h"
#import "NSObject+DXModel.h"

@implementation DXWxauthorizerSyncUserinfoRequest

- (void)setWxUserInfo:(DXWechatUserInfo *)wxUserInfo {
    _wxUserInfo = wxUserInfo;
    
    NSDictionary *userData = [wxUserInfo toObjectDictionary];
    for (NSString *dataKey in userData.allKeys) {
        [self setValue:[userData objectForKey:dataKey] forParam:dataKey];
    }
}

@end
