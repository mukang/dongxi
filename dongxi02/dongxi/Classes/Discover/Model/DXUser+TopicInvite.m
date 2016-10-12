//
//  DXUser+TopicInvite.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/29.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUser+TopicInvite.h"
#import <objc/runtime.h>

@implementation DXUser (TopicInvite)

@dynamic invited;

- (void)setInvited:(BOOL)invited {
    objc_setAssociatedObject(self, @selector(invited), @(invited), OBJC_ASSOCIATION_COPY);
}

- (BOOL)invited {
    NSNumber * nInvited = objc_getAssociatedObject(self, @selector(invited));
    if (nInvited) {
        return [nInvited boolValue];
    } else {
        return NO;
    }
}

@end
