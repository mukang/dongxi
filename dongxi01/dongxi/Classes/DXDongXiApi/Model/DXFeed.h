//
//  DXFeed.h
//  dongxi
//
//  Created by 穆康 on 16/8/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DXFeedRecommend;

@interface DXFeed : NSObject

/** 当前拉取的热门/精选的记录ID */
@property (nonatomic, copy) NSString *hot_id;
/** 当前feed的ID */
@property (nonatomic, copy) NSString *fid;
/** 当前feed的正文内容 */
@property (nonatomic, copy) NSString *content;
/** 当前feed的总的点赞数量 */
@property (nonatomic, assign) NSUInteger total_like;
/** 当前feed的总的评论数量 */
@property (nonatomic, assign) NSUInteger total_comment;
/** 当前feed的创建时间 */
@property (nonatomic, assign) NSTimeInterval time;
/** 当前feed中涉及到的话题列表 */
@property (nonatomic, strong) NSArray *topics;
/** 当前feed的照片列表 */
@property (nonatomic, strong) NSArray *photos;
/** 为什么feed被推荐的相关信息 */
@property (nonatomic, strong) DXFeedRecommend *recommend;
/** 当前feed创建者信息 */
@property (nonatomic, strong) DXUser *creator;
/** 当前用户的信息 */
@property (nonatomic, strong) DXUser *current_user;

@end


/**
 *  feed中的照片相关信息
 */
@interface DXFeedPhotoInfo : NSObject

/** 照片原图url */
@property (nonatomic, copy) NSString *url;
/** 照片缩略图url */
@property (nonatomic, copy) NSString *preview;
/** 照片宽度 */
@property (nonatomic, assign) NSInteger width;
/** 照片高度 */
@property (nonatomic, assign) NSInteger height;

@end


/**
 *  为什么feed被推荐的相关信息
 */
@interface DXFeedRecommend : NSObject

/** 推荐原因 */
@property (nonatomic, copy) NSString *reason;

@end





