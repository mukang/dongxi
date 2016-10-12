//
//  DXUserRegisterInfo.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXUserRegisterInfo.h"
#import "DXFunctions.h"

@implementation DXUserRegisterInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _device = DXGetDeviceModel();
        _uuid = DXGetDeviceUUID();
        _gender = DXUserGenderTypeMale;
    }
    return self;
}

@end
