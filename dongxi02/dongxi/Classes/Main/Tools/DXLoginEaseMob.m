//
//  DXLoginEaseMob.m
//  dongxi
//
//  Created by 穆康 on 15/10/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLoginEaseMob.h"
#import <EaseMob.h>
#import "DXDongXiApi.h"

static NSString *const password = @"hx123456";

@implementation DXLoginEaseMob

+ (void)loginEaseMobWithUserSession:(DXUserSession *)userSession {
    
    NSString *userName = [NSString stringWithFormat:@"cuser%@", userSession.uid];
    NSString *userNick = userSession.nick;
    
    BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
    if (!isAutoLogin) {
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:userName password:password completion:^(NSDictionary *loginInfo, EMError *error) {
            if (!error) {
                DXLog(@"登陆环信成功");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // 设置自动登录
                    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                    //设置推送设置
                    [[EaseMob sharedInstance].chatManager setApnsNickname:userNick];
                });
            } else {
                DXLog(@"登陆环信失败 -- %@", error);
            }
        } onQueue:nil];
    }
}

+ (void)loginEaseMobWithUserSession:(DXUserSession *)userSession completion:(void (^)(BOOL))completionBlock {
    
    NSString *userName = [NSString stringWithFormat:@"cuser%@", userSession.uid];
    NSString *userNick = userSession.nick;
    
    BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
    if (!isAutoLogin) {
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:userName password:password completion:^(NSDictionary *loginInfo, EMError *error) {
            if (!error) {
                DXLog(@"登陆环信成功");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // 设置自动登录
                    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                    //设置推送设置
                    [[EaseMob sharedInstance].chatManager setApnsNickname:userNick];
                });
            } else {
                DXLog(@"登陆环信失败 -- %@", error);
            }
            if (completionBlock) {
                BOOL success = (error != nil);
                completionBlock(success);
            }
        } onQueue:nil];
    }
}

@end
