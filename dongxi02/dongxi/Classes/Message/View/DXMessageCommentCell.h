//
//  DXMessageCommentCell.h
//  dongxi
//
//  Created by 穆康 on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXNoticeComment;
@class DXMessageCommentCell;

@protocol DXMessageCommentCellDelegate <NSObject>

@optional
/** 点击了回复按钮 */
- (void)messageCommentCell:(DXMessageCommentCell *)cell didTapReplyBtnWithComment:(DXNoticeComment *)comment feedID:(NSString *)feedID;
/** 点击了头像 */
- (void)messageCommentCell:(DXMessageCommentCell *)cell didTapAvatarWithUserID:(NSString *)userID;

- (void)messageCommentCell:(DXMessageCommentCell *)cell didSelectReferUserWithUserID:(NSString *)userID;
- (void)messageCommentCell:(DXMessageCommentCell *)cell didSelectReferTopicWithTopicID:(NSString *)topicID;

@end

@interface DXMessageCommentCell : UITableViewCell

@property (nonatomic, strong) DXNoticeComment *comment;

@property (nonatomic, copy) NSString *feedID;

@property (nonatomic, weak) id<DXMessageCommentCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

/**
 *  返回cell高度
 */
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withComment:(DXNoticeComment *)comment;

@end
