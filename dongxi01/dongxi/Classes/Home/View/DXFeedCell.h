//
//  DXFeedCell.h
//  dongxi
//
//  Created by 穆康 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXFeedToolBar.h"

@class DXFeedCell;

@protocol DXFeedCellDelegate <NSObject>

@optional
/**
 *  点击头像
 */
- (void)didTapAvatarViewInFeedCellWithUserID:(NSString *)userID;
/**
 *  点击话题
 */
- (void)didTapTopicViewInFeedCellWithTopicID:(NSString *)topicID;
/**
 *  点击点赞头像
 */
- (void)didTapLikeAvatarViewInFeedCellWithFeedID:(NSString *)feedID;
/**
 *  点赞
 */
- (void)feedCell:(DXFeedCell *)cell didTapLikeViewWithFeed:(DXTimelineFeed *)feed;
/**
 *  评论
 */
- (void)feedCell:(DXFeedCell *)cell didTapCommentViewWithFeed:(DXTimelineFeed *)feed;
/**
 *  私聊
 */
- (void)didTapChatViewInFeedCellWithFeed:(DXTimelineFeed *)feed;
/**
 *  收藏与分享
 */
- (void)didTapShareViewInFeedCellWithFeed:(DXTimelineFeed *)feed;
/**
 *  点击了图片
 */
- (void)feedCell:(DXFeedCell *)cell didTapBigPhotoWithFeed:(DXTimelineFeed *)feed sourceImageView:(UIImageView *)imageView sourceImageContainerView:(UIView *)imageContainerView;
/**
 *  点击了更多按钮
 */
- (void)feedCell:(DXFeedCell *)cell didTapMoreButtonWithFeed:(DXTimelineFeed *)feed;

- (void)feedCell:(DXFeedCell *)cell didSelectReferUserWithUserID:(NSString *)userID;
- (void)feedCell:(DXFeedCell *)cell didSelectReferTopicWithTopicID:(NSString *)topicID;

@end

@interface DXFeedCell : UITableViewCell

@property (nonatomic, strong) DXTimelineFeed *feed;

@property (nonatomic, strong) NSIndexPath *indexPath;

/** 底部工具栏 */
@property (nonatomic, weak) DXFeedToolBar *toolBar;

@property (nonatomic, weak) id<DXFeedCellDelegate> delegate;

/**
 *  返回cell高度
 */
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withFeed:(DXTimelineFeed *)feed;

@end
