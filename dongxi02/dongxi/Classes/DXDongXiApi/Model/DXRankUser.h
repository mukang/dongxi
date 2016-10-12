//
//  DXRankUser.h
//  dongxi
//
//  Created by 穆康 on 16/3/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 排行榜用户 */
@interface DXRankUser : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nick;
/** 用户关系 */
@property (nonatomic, assign) DXUserRelationType relations;
/** 用户认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;
/** 第几名 */
@property (nonatomic, assign) NSUInteger rank;
/** 点赞人数(一周点赞红人榜) */
@property (nonatomic, assign) NSUInteger like_count;
/** 积分(话题积分排行榜) */
@property (nonatomic, assign) NSUInteger points;

@end
