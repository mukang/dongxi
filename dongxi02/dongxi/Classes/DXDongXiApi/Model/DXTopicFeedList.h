//
//  DXTopicFeedList.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DXTopicDetail;

extern NSString * const DXTopicFeedListTypeNew;
extern NSString * const DXTopicFeedListTypeHot;


@interface DXTopicFeedList : NSObject

/** 列表是否还有更多内容未获取完 */
@property (nonatomic, assign) BOOL more;

/** 话题详情 */
@property (nonatomic, strong) DXTopicDetail * topic;

@property (nonatomic, copy) NSString * type;

/** 当前获取到的数量 */
@property (nonatomic, assign) NSInteger count;

/** 当前获取的DXTimelineFeed对象的数组 */
@property (nonatomic, strong) NSArray *feeds;

/** 排行榜 */
@property (nonatomic, strong) NSArray *rank;

@end


@interface DXTopicDetail : NSObject

@property (nonatomic, copy) NSString *topic_id;

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *nick;

@property (nonatomic, copy) NSString *time;

@property (nonatomic, assign) NSInteger joined;

@property (nonatomic, copy) NSString *is_join;

@property (nonatomic, copy) NSString *topic;

@property (nonatomic, copy) NSString *cover;

@property (nonatomic, copy) NSString *txt;
/** 认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;
/** 是否收藏 */
@property (nonatomic, assign) BOOL is_like;
/** 活跃度（feed量） */
@property (nonatomic, assign) NSUInteger activeness;
/** 是否是有奖话题 */
@property (nonatomic, assign) BOOL has_prize;
/** 副标题 */
@property (nonatomic, copy) NSString *title;
/** 讨论区提问个数 */
@property (nonatomic, assign) NSInteger question_quantity;

@end

