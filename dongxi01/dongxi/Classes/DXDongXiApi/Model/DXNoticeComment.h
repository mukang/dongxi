//
//  DXNoticeComment.h
//  dongxi
//
//  Created by 穆康 on 15/11/4.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXNoticeComment : NSObject

/** 我的uid comment_type为1时为0 */
@property (nonatomic, copy) NSString *uid;

/** 我的昵称 */
@property (nonatomic, copy) NSString *nick;



/** 我评论的内容 */
@property (nonatomic, copy) NSString *txt;

/** 1评论了别人的feed,2评论了别人的评论 (仅别人发的feed有值) */
@property (nonatomic, assign) NSInteger type;

/** 我回复了谁的uid（当type为2时有值） */
@property (nonatomic, copy) NSString *at_uid;

/** 我回复了谁的昵称（当type为2时有值） */
@property (nonatomic, copy) NSString *at_nick;

/** 该条评论的ID */
@property (nonatomic, copy) NSString *comment_id;

/** 回复者UID */
@property (nonatomic, copy) NSString *comment_uid;

/** 回复者昵称 */
@property (nonatomic, copy) NSString *comment_nick;

/** 回复者头像 */
@property (nonatomic, copy) NSString *comment_avatar;

/** 回复者认证类型 */
@property (nonatomic, assign) DXUserVerifiedType comment_verified;

/** 回复内容 */
@property (nonatomic, copy) NSString *comment_txt;

/** 回复时间 */
@property (nonatomic, assign) NSTimeInterval comment_time;

/** 回复时间(格式化后的) */
@property (nonatomic, copy) NSString *fmtTime;

/** 1评论我的feed,2评论我的评论 */
@property (nonatomic, assign) NSInteger comment_type;

/** 内容块 */
@property (nonatomic, strong) NSArray *content_pieces;

@end
