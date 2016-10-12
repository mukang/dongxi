//
//  WeiboManager.h
//  dongxi
//
//  Created by 穆康 on 15/11/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXSingleton.h"
#import <WeiboSDK.h>

@protocol WeiboManagerDelegate <NSObject>

@optional

- (void)managerDidReceiveWeiboResponse:(WBBaseResponse *)response;

@end

@interface WeiboManager : NSObject <WeiboSDKDelegate>

DXSingletonInterface(Manager)

@property (nonatomic, weak) id<WeiboManagerDelegate> delegate;

@end
