//
//  DXChatRecord.h
//  dongxi
//
//  Created by 穆康 on 15/10/23.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXChatRecord : NSObject

/** 会话对方的环信ID */
@property (nonatomic, copy) NSString *chatter;
/** 会话对方的用户ID */
@property (nonatomic, copy) NSString *userID;
/** 会话对方的昵称 */
@property (nonatomic, copy) NSString *nick;
/** 会话对方的头像 */
@property (nonatomic, copy) NSString *avatar;
/** 内容 */
@property (nonatomic, copy) NSString *text;
/** 时间 */
@property (nonatomic, copy) NSString *time;
/** 未读条数 */
@property (nonatomic, assign) NSInteger unReadCount;

@end
