//
//  DXCommentCell.h
//  dongxi
//
//  Created by 穆康 on 15/8/23.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXComment;
@class DXCommentCell;

@protocol DXCommentCellDelegate <NSObject>

@optional
/**
 *  点击头像
 */
- (void)commentCell:(DXCommentCell *)cell didTapAvatarViewWithUserID:(NSString *)userID;

- (void)commentCell:(DXCommentCell *)cell didSelectReferUserWithUserID:(NSString *)userID;
- (void)commentCell:(DXCommentCell *)cell didSelectReferTopicWithTopicID:(NSString *)topicID;

@end

@interface DXCommentCell : UITableViewCell

@property (nonatomic, strong) DXComment *comment;

@property (nonatomic, weak) id<DXCommentCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

/**
 *  返回cell高度
 */
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withComment:(DXComment *)comment;

@end
