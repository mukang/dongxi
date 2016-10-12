//
//  DXUser.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXUserEnum.h"


/**
 *  代表用户的Class
 */
@interface DXUser : NSObject

/**
 *  此ID仅当从DXUserWrapper对象得到时存在，拉取用户列表相关接口时使用
 */
@property (nonatomic, copy) NSString * ID;

/**
 *  用户uid，唯一识别用户的id
 */
@property (nonatomic, copy) NSString * uid;

/**
 *  用户名（或用户昵称）
 */
@property (nonatomic, copy) NSString * nick;

/**
 *  头像地址
 */
@property (nonatomic, copy) NSString * avatar;

/**
 * 用户名拼音索引
 */
@property (nonatomic, copy) NSString * py;

/**
 *  用户所在地
 */
@property (nonatomic, copy) NSString * location;

/**
 *  与该用户的关系，见DXUserRelationType
 */
@property (nonatomic, assign) DXUserRelationType relations;

/**
 *  用户认证类型
 */
@property (nonatomic, assign) DXUserVerifiedType verified;


@end
