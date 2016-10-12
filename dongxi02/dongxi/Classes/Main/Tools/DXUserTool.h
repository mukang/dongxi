//
//  DXUserTool.h
//  dongxi
//
//  Created by 穆康 on 15/8/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXUser.h"

@interface DXUserTool : NSObject

/**
 *  存储用户信息
 */
+ (void)save:(DXUser *)user;

/**
 *  获取用户信息
 *
 *  @return 如果过期，返回nil
 */
+ (DXUser *)user;

@end
