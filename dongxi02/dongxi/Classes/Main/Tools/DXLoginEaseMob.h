//
//  DXLoginEaseMob.h
//  dongxi
//
//  Created by 穆康 on 15/10/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DXUserSession;

@interface DXLoginEaseMob : NSObject

+ (void)loginEaseMobWithUserSession:(DXUserSession *)userSession;

+ (void)loginEaseMobWithUserSession:(DXUserSession *)userSession completion:(void(^)(BOOL success))completionBlock;

@end
