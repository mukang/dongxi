//
//  DXNoticeLike.h
//  dongxi
//
//  Created by 穆康 on 15/10/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXNoticeLike : NSObject

/** 用于排序 */
@property (nonatomic, copy) NSString *ID;

/** FeedID */
@property (nonatomic, copy) NSString *fid;

/** 点赞人的用户id */
@property (nonatomic, copy) NSString *uid;

/** 头像地址 */
@property (nonatomic, copy) NSString *avatar;

/** 点赞人昵称 */
@property (nonatomic, copy) NSString *nick;

/** 用户认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;

/** 暂无用 */
@property (nonatomic, copy) NSString *txt;

/** 点赞日期(时间戳) */
@property (nonatomic, assign) NSTimeInterval time;

/** 点赞日期 */
@property (nonatomic, copy) NSString *likeTime;

/** feed缩略图地址 */
@property (nonatomic, copy) NSString *photo;

/** 是否已读，0未读，1已读 */
@property (nonatomic, assign) NSInteger read;

/** 暂无用 */
@property (nonatomic, assign) NSInteger type;

@end
