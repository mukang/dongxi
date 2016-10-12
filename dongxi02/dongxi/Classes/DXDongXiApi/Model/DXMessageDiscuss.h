//
//  DXMessageDiscuss.h
//  dongxi
//
//  Created by 穆康 on 15/9/15.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  私聊会话
 */
@interface DXMessageDiscuss : NSObject

/** 用于排序 */
@property (nonatomic, copy) NSString *ID;

/** FeedID */
@property (nonatomic, copy) NSString *fid;

/** 物品缩略图地址(暂时没用) */
@property (nonatomic, copy) NSString *photo;

/** 聊天置顶图地址(暂时没用) */
@property (nonatomic, copy) NSString *preview;

/** 和谁聊(服务器上的uid) */
@property (nonatomic, copy) NSString *uid;

/** 头像地址 */
@property (nonatomic, copy) NSString *avatar;

/** 聊天对象昵称 */
@property (nonatomic, copy) NSString *nick;

/** 用户认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;

/** 最后聊天内容 */
@property (nonatomic, copy) NSString *txt;

/** 最后聊天日期 */
@property (nonatomic, assign) NSTimeInterval time;

/** 格式化后的最后聊天日期 */
@property (nonatomic, copy) NSString *lastTime;

/** 1置顶 0非置顶 */
@property (nonatomic, assign) NSInteger top;

/** 1有新消息 0无新消息 */
@property (nonatomic, assign) NSInteger new_message;

@end
