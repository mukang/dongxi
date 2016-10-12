//
//  DXMessageNewDetail.h
//  dongxi
//
//  Created by 穆康 on 15/11/23.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  消息页的新消息详情

#import <Foundation/Foundation.h>

/**
 *  该类已废除
 */
@interface DXMessageNewDetail : NSObject

/** 新消息类型是赞 */
@property (nonatomic, assign) BOOL like;
/** 新消息类型是评论 */
@property (nonatomic, assign) BOOL comment;
/** 新消息类型是通知 */
@property (nonatomic, assign) BOOL notice;

@end
