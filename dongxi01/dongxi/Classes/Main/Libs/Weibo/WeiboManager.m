//
//  WeiboManager.m
//  dongxi
//
//  Created by 穆康 on 15/11/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "WeiboManager.h"

@implementation WeiboManager

DXSingletonImplementation(Manager)

/**
 *  微博代理方法
 */

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(managerDidReceiveWeiboResponse:)]) {
        [self.delegate managerDidReceiveWeiboResponse:response];
    }
}

@end
