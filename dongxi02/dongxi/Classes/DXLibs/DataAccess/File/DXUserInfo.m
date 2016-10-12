//
//  DXUserInfo.m
//  dongxi
//
//  Created by Xu Shiwen on 15/12/8.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserInfo.h"
#import "NSObject+DXModel.h"

@implementation DXUserInfo

- (BOOL)isEqualToUserInfo:(DXUserInfo *)userInfo {
    if (userInfo == nil) {
        return NO;
    }
    
    BOOL nameEquality = (!self.nickname && !userInfo.nickname) || [self.nickname isEqualToString:userInfo.nickname];
    BOOL avatarEquality = (!self.avatar && !userInfo.avatar) || [self.avatar isEqualToString:userInfo.avatar];
    
    return nameEquality && avatarEquality;
}

- (id)copyWithZone:(NSZone *)zone {
    DXUserInfo * userInfo = [[DXUserInfo allocWithZone:zone] init];
    userInfo.nickname = [self.nickname copy];
    userInfo.avatar = [self.avatar copy];
    userInfo.updateTime = self.updateTime;
    
    return userInfo;
}

@end
