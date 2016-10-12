//
//  DXWxauthorizerRegisterAndLoginRequest.m
//  dongxi
//
//  Created by 穆康 on 16/6/20.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXWxauthorizerRegisterAndLoginRequest.h"
#import "NSObject+DXModel.h"

@implementation DXWxauthorizerRegisterAndLoginRequest

- (void)setWxRegisterInfo:(DXWechatRegisterInfo *)wxRegisterInfo {
    _wxRegisterInfo = wxRegisterInfo;
    
    NSDictionary *infoData = [wxRegisterInfo toObjectDictionary];
    for (NSString *dataKey in infoData.allKeys) {
        [self setValue:[infoData objectForKey:dataKey] forParam:dataKey];
    }
}

@end
