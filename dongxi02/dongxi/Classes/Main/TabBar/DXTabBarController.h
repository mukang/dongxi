//
//  DXTabBarController.h
//  dongxi
//
//  Created by 穆康 on 15/8/4.
//  Copyright (c) 2015年 穆康. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXTabBarController : UITabBarController

/** 新通知详情（评论、赞和通知） */
@property (nonatomic, strong) DXUserCheckResultNotification *notificationDetail;

/**
 *  统计新消息（评论、赞和通知）
 *
 *  @param resultBlock 结果
 */
- (void)checkNormalUnreadMessage;

/**
 *  统计新消息（环信）
 */
//- (void)checkEaseMobUnreadMessage;
- (void)checkChatUnreadMessage;

/**
 *  统计未读消息包括私聊、评论、赞和通知的消息
 */
- (void)checkUnreadMessage;


@end
