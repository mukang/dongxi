//
//  DXNotice.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DXNoticeTypeWelcome = 0,
    DXNoticeTypeComment,
    DXNoticeTypeLike,
    DXNoticeTypeTopicInvite,
    DXNoticeTypeFollow,
    DXNoticeTypeFeedRefer,
    DXNoticeTypeCommentRefer,
    DXNoticeTypeAnswered,
    DXNoticeTypeAnswerReverted
} DXNoticeType;


/** 消息 */
@interface DXNotice : NSObject

/**
 *  该属性可能为nil，仅当从DXNoticeList获取时可用，用于获取刷新列表参考
 */
@property (nonatomic, copy) NSString *ID;

/** 用户id */
@property (nonatomic, copy) NSString *uid;

/** 头像 */
@property (nonatomic, copy) NSString *avatar;

/** 昵称 */
@property (nonatomic, copy) NSString *nick;

/** 用户认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;

/** 通知内容 */
@property (nonatomic, copy) NSString *txt;

/** 通知时间戳 */
@property (nonatomic, assign) NSTimeInterval time;

/** 格式化后的时间 */
@property (nonatomic, copy) NSString *fmtTime;

/** 通知类型 */
@property (nonatomic, assign) DXNoticeType type;

/** type为4返回0 type为1返回fid */
@property (nonatomic, copy) NSString *fid;

/** type为DXNoticeTypeTopicInvite时使用  */
@property (nonatomic, copy) NSString * topic_id;

/** 是否已读 */
@property (nonatomic, assign) BOOL read;

/** 讨论区路由地址（仅当type为DXNoticeTypeAnswered或DXNoticeTypeAnswerReverted时有值） */
@property (nonatomic, copy) NSString *redirect_url;

@end
