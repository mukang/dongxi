//
//  DXUserSession.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXUserEnum.h"

/** 已登陆用户的session */
@interface DXUserSession : NSObject <NSCoding>

/** 已登陆用户的uid */
@property (nonatomic, strong) NSString * uid;
/** 已登陆用户session的id */
@property (nonatomic, strong) NSString * sid;
/** 已登陆用户session的有效时间，为时间戳（秒） */
@property (nonatomic, assign) NSTimeInterval validtime;
/** 用户名（或用户昵称）*/
@property (nonatomic, strong) NSString * nick;
/** 头像地址 */
@property (nonatomic, strong) NSString * avatar;
/** 用户所在地 */
@property (nonatomic, copy) NSString * location;
/** 用户认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;

/*
@property (nonatomic, assign) DXUserGenderType gender;
 */

/** 默认的话题id */
@property (nonatomic, copy) NSString *defaultTopicID;

@end
