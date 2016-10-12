//
//  DXComment.h
//  dongxi
//
//  Created by 穆康 on 15/9/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXComment : NSObject

/** 用作刷新参考的ID */
@property (nonatomic, copy) NSString *ID;
/** 发布评论的用户ID */
@property (nonatomic, copy) NSString *uid;
/** 发布评论的用户头像 */
@property (nonatomic, copy) NSString *avatar;
/** 发布评论的用户认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;
/** 发布评论的用户昵称 */
@property (nonatomic, copy) NSString *nick;
/** 评论内容 */
@property (nonatomic, copy) NSString *txt;
/** 被评论人的ID */
@property (nonatomic, copy) NSString *at_uid;
/** 被评论人的昵称 */
@property (nonatomic, copy) NSString *at_nick;
/** 评论时间戳 */
@property (nonatomic, assign) NSTimeInterval time;
/** 格式化后的时间 */
@property (nonatomic, copy) NSString *fmtTime;
/** 此条评论是不是自己发的 */
@property (nonatomic, assign, getter=isOwn) BOOL own;
/** 内容块 */
@property (nonatomic, strong) NSArray *content_pieces;

@end
