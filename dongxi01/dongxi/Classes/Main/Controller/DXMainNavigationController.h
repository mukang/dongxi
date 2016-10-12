//
//  DXMainNavigationController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXDongXiApi.h"

extern NSString *const DXDeleteFeedNotification;

@interface DXMainNavigationController : UINavigationController

/** 允许交互式推出手势，默认为YES */
@property (nonatomic, assign) BOOL enableInteractivePopGesture;

#pragma mark - 跳转到个人控制器
/**
 *  通过昵称跳转到个人控制器
 *
 *  @param nick 用户的昵称
 *  @param info 事件的相关信息
 */
- (void)pushToProfileViewControllerWithNick:(NSString *)nick info:(NSDictionary *)info;
/**
 *  通过用户ID跳转到个人控制器
 *
 *  @param userID 用户ID
 *  @param info   事件的相关信息
 */
- (void)pushToProfileViewControllerWithUserID:(NSString *)userID info:(NSDictionary *)info;
#pragma mark - 跳转到话题控制器
/**
 *  跳转到话题控制器
 *
 *  @param userID 话题的id
 *  @param info   事件的相关信息
 */
- (void)pushToTopicViewControllerWithTopicID:(NSString *)topicID info:(NSDictionary *)info;
#pragma mark - 显示收藏与分享视图
/**
 *  显示收藏与分享视图
 *
 *  @param feed feed
 *  @param info 事件的相关信息
 */
- (void)showCollectionAndShareViewWithFeed:(DXTimelineFeed *)feed info:(NSDictionary *)info;
#pragma mark - 跳转到点赞的人列表控制器
/**
 *  跳转到点赞的人列表控制器
 *
 *  @param feedID feedID
 *  @param info   事件的相关信息
 */
- (void)pushToLikerListViewControllerWithFeedID:(NSString *)feedID info:(NSDictionary *)info;
#pragma mark - 关注某个用户
/**
 *  关注某个用户
 *
 *  @param userID userID
 *  @param info   事件的相关信息
 */
- (void)followUserWithUserID:(NSString *)userID info:(NSDictionary *)info completion:(void(^)(BOOL success))completion;
#pragma mark - 取消关注某个用户
/**
 *  取消关注某个用户
 *
 *  @param userID userID
 *  @param info   事件的相关信息
 */
- (void)unfollowUserWithUserID:(NSString *)userID info:(NSDictionary *)info completion:(void(^)(BOOL success))completion;
#pragma mark - 跳转到地图控制器
/**
 *  跳转到地图控制器
 *
 *  @param feed feed
 *  @param info 事件的相关信息
 */
- (void)pushToMapViewControllerWithFeed:(DXTimelineFeed *)feed info:(NSDictionary *)info;
#pragma mark - 跳转到邀请码列表控制器
/**
 *  跳转到邀请码列表控制器
 *
 *  @param info 事件的相关信息
 */
- (void)pushToInvitationViewControllerWithInfo:(NSDictionary *)info;
#pragma mark - 据据需要呈现登陆视图
/**
 *  据据需要呈现登陆视图
 *
 *  @return 返回YES表示当前用户未登陆并呈现了登陆视图，反之返回NO
 */
- (BOOL)presentLoginViewIfNeeded;



@end
