//
//  DXActivity.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/26.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DXActivityDetail,DXActivityComment,DXActivityWantUserInfo;

/**
 活动类型
 */
typedef enum : NSUInteger {
    /** 活动类型 - 未知 */
    DXActivityTypeUnknown = 0,
    /** 活动类型 - 展览 */
    DXActivityTypeExhibition,
    /** 活动类型 - 活动 */
    DXActivityTypeEvent,
    /** 活动类型 - 沙龙 */
    DXActivityTypeSalon,
} DXActivityType;


/**
 *  活动信息
 */
@interface DXActivity : NSObject

/** 活动ID */
@property (nonatomic, copy) NSString *activity_id;

/** 活动名称 */
@property (nonatomic, copy) NSString *activity;

/** 一句话描述 */
@property (nonatomic, copy) NSString * abstract;

/** 活动题图 */
@property (nonatomic, copy) NSString *cover;

/** 活动缩略图 */
@property (nonatomic, copy) NSString *avatar;

/** 评级星星数量 */
@property (nonatomic, assign) NSInteger star;

/** 是否为推荐活动 */
@property (nonatomic, assign) BOOL is_top;

/** 我是否想去 */
@property (nonatomic, assign) BOOL is_want;

/** 我是否参加  */
@property (nonatomic, assign) BOOL is_join;

/** 我的评分 */
@property (nonatomic, assign) NSUInteger my_star;

/** 我的评论 */
@property (nonatomic, copy) NSString * my_comment;

/** 活动类型 */
@property (nonatomic, assign) DXActivityType type;

/** 活动类型（文字） */
@property (nonatomic, strong) NSString * typeText;

/** 活动城市 */
@property (nonatomic, copy) NSString * city;

/** 活动开始日期 */
@property (nonatomic, copy) NSString * days;

/** 活动详情 */
@property (nonatomic, strong) DXActivityDetail *detail;

/** 参加人数 */
@property (nonatomic, assign) NSInteger joined;

/** 想去此活动的人，数组，包含DXActivityWantUserInfo对象 */
@property (nonatomic, strong) NSArray *want;

/** 活动评论，数组，包含DXActivityComment对象 */
@property (nonatomic, strong) NSArray *comment;

@end


/**
 *  活动详情
 */
@interface DXActivityDetail : NSObject

/** 活动地 */
@property (nonatomic, copy) NSString *place;

/** 活动描述（简要） */
@property (nonatomic, copy) NSString *intro;

/** 活动描述 */
@property (nonatomic, copy) NSString *txt;

/** 活动价格/票价 */
@property (nonatomic, copy) NSString *price;

/** 活动时间 */
@property (nonatomic, copy) NSString *time;

/** 活动地址 */
@property (nonatomic, copy) NSString *address;

@end


/**
 *  活动评论
 */
@interface DXActivityComment : NSObject

/** 评论用户uid */
@property (nonatomic, copy) NSString *uid;

/** 评论用户名称 */
@property (nonatomic, copy) NSString *nick;

/** 用户认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;

/** 评论时间 */
@property (nonatomic, assign) NSTimeInterval time;

/** 经过格式化后的评论时间 */
@property (nonatomic, strong) NSString * formattedTime;

/** 评论头像地址 */
@property (nonatomic, copy) NSString *avatar;

/** 评论星级 */
@property (nonatomic, assign) NSInteger star;

/** 评论内容 */
@property (nonatomic, copy) NSString *txt;

@end


/**
 *  想去此活动的用户信息
 */
@interface DXActivityWantUserInfo : NSObject

/** 用户uid */
@property (nonatomic, copy) NSString *uid;

/** 用户头像 */
@property (nonatomic, copy) NSString *avatar;

/** 用户昵称 */
@property (nonatomic, copy) NSString * nick;

/** 用户认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;

/** 用户位置 */
@property (nonatomic, copy) NSString * location;

@end

