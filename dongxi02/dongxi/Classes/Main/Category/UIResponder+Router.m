//
//  UIResponder+Router.m
//  dongxi
//
//  Created by 穆康 on 15/9/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "UIResponder+Router.h"

@implementation UIResponder (Router)

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    
    [[self nextResponder] routerEventWithName:eventName userInfo:userInfo];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo result:(void (^)(BOOL))resultBlock {
    
    [[self nextResponder] routerEventWithName:eventName userInfo:userInfo result:resultBlock];
}

@end
