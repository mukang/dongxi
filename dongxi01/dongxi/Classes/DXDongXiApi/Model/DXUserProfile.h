//
//  DXUserProfile.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXUser.h"

@class DXUserProfileTag;


/**
 *  用户资料
 */
@interface DXUserProfile : NSObject

/** 用户id */
@property (nonatomic, copy) NSString *uid;

/** 用户认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;

/** 用户名 */
@property (nonatomic, copy) NSString *username;

/** 用户签名  */
@property (nonatomic, copy) NSString *bio;

/** 所在地 */
@property (nonatomic, copy) NSString *location;

/** 头像地址 */
@property (nonatomic, copy) NSString *avatar;

/** 原始大小的头像地址 */
@property (nonatomic, copy) NSString *big_avatar;

/** 封面地址 */
@property (nonatomic, copy) NSString *cover;

/** 相册缩略图 */
@property (nonatomic, strong) NSArray *thumb;

/** 是否限制只有其关注的人才能与其私聊 */
@property (nonatomic, assign) BOOL chat_limit;

/** 内容数 */
@property (nonatomic, assign) NSInteger feeds;

/** 被赞数 */
@property (nonatomic, assign) NSInteger likes;

/** 关注数 */
@property (nonatomic, assign) NSUInteger follows;

/** 粉丝数 */
@property (nonatomic, assign) NSInteger fans;

/** 当前登陆用户的对此人是否已关注 */
@property (nonatomic, assign) BOOL is_followed;

/** 性别，见DXUserGenderType */
@property (nonatomic, assign) DXUserGenderType gender;

/** 与当前已登陆用户之间的关系，见DXUserRelationType */
@property (nonatomic, assign) DXUserRelationType relations;

@property (nonatomic, strong) NSArray *tag;

/** 获取性别的描述，如果gender为DXUserGenderTypeMale则返回“男”，否则返回“女” */
- (NSString *)genderDescription;

@end



@interface DXUserProfileTag : NSObject

@property (nonatomic, copy) NSString *topic;

@property (nonatomic, copy) NSString *topic_id;

@end

