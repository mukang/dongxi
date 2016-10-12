//
//  DXTopicRankUser.h
//  dongxi
//
//  Created by 穆康 on 16/2/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 话题用户积分排行榜上的用户 */
@interface DXTopicRankUser : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nick;
/** 积分 */
@property (nonatomic, assign) NSUInteger points;
/** 用户关系 */
@property (nonatomic, assign) DXUserRelationType relations;
/** 用户认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;
/** 第几名 */
@property (nonatomic, copy) NSString *sort_id;

@end
