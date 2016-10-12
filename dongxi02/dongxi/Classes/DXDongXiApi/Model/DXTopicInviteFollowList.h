//
//  DXTopicInviteFollowList.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXTopicInviteFollowList : NSObject

/**
 *  已邀请的人（已是全部数据），包含DXUser对象
 */
@property (nonatomic, strong) NSArray * top;

/**
 *  本次获取到的数据数量
 */
@property (nonatomic, assign) NSUInteger count;

/**
 *  未邀请的人（可能只是部分数据），包含DXUser对象
 */
@property (nonatomic, strong) NSArray * list;

/**
 *  是否还有更多数据
 */
@property (nonatomic, assign) BOOL more;

@end
