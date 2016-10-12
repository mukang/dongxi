//
//  DXUserChangeProfileRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserChangeProfileRequest.h"
#import "NSObject+DXModel.h"
#import "DXUserProfileChange.h"

@implementation DXUserChangeProfileRequest

- (void)setProfileChange:(DXUserProfileChange *)profileChange {
    _profileChange = profileChange;
    NSDictionary * profileNewData = [profileChange toObjectDictionary];
    for (NSString * dataKey in profileNewData.allKeys) {
        id dataValue = [profileNewData objectForKey:dataKey];
        if (dataValue) {
            [self setValue:dataValue forParam:dataKey];
        }
    }
}

@end
