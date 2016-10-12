//
//  DXTimelineFeed.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DXTimelineFeed;
@class DXTimelineFeedContent;
@class DXTimelineFeedTopicInfo;
@class DXTimelineFeedLiker;
@class DXTimelineFeedTag;
@class DXTimelineFeedPhoto;
@class DXTimelineFeedComment;


@interface DXTimelineFeed : NSObject

/**
 *  ID，仅当从DXTimelineFeedWrapper或DXTopicFeedList获取到时存在，用于拉取列表
 */
@property (nonatomic, copy) NSString * ID;

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *nick;

@property (nonatomic, assign) DXUserVerifiedType verified;

@property (nonatomic, assign) NSInteger time;
/** 获取feed的时间节点 */
@property (nonatomic, assign) NSTimeInterval getFeedTime;

@property (nonatomic, assign) BOOL lock;

@property (nonatomic, strong) DXTimelineFeedContent *data;

@property (nonatomic, copy) NSString *fid;

@property (nonatomic, assign) NSInteger group;

@property (nonatomic, assign) NSInteger type;

@end


@interface DXTimelineFeedContent : NSObject

@property (nonatomic, assign) BOOL is_like;

@property (nonatomic, assign) BOOL is_hot;

@property (nonatomic, strong) NSArray *comments;

@property (nonatomic, copy) NSString *place;

@property (nonatomic, assign) CGFloat lat;

@property (nonatomic, assign) CGFloat lng;

@property (nonatomic, assign) NSInteger total_like;

@property (nonatomic, strong) NSArray *likes;

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, assign) NSInteger hot;

@property (nonatomic, assign) NSInteger total_comments;

@property (nonatomic, strong) DXTimelineFeedTopicInfo *topic;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) NSArray *content_pieces;

@property (nonatomic, strong) NSArray *photo;

@property (nonatomic, assign) BOOL is_report;

/**
 *  当前显示的照片索引
 */
@property (nonatomic, assign) NSInteger photoIndex;
/**
 *  是否收藏过
 */
@property (nonatomic, assign) BOOL is_save;


@end


@interface DXTimelineFeedTopicInfo : NSObject

@property (nonatomic, copy) NSString *topic;

@property (nonatomic, copy) NSString *topic_id;

@property (nonatomic, assign) NSInteger topic_type;

@end


@interface DXTimelineFeedLiker : NSObject

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, assign) DXUserVerifiedType verified;

@end


@interface DXTimelineFeedTag : NSObject

@property (nonatomic, copy) NSString *tag;

@property (nonatomic, copy) NSString * tag_id;

@end


@interface DXTimelineFeedPhoto : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *preview;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) NSInteger width;

@property (nonatomic, assign) NSInteger height;

@end


@interface DXTimelineFeedComment : NSObject

@property (nonatomic, copy) NSString * ID;

@property (nonatomic, copy) NSString *txt;

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *nick;

@property (nonatomic, assign) NSInteger time;

@property (nonatomic, copy) NSString *avatar;

/** 被@人的UID */
//@property (nonatomic, copy) NSString *at_uid;

@end
