//
//  DXDetailTextCell.h
//  dongxi
//
//  Created by 穆康 on 15/8/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXTimelineFeed;
@class DXDetailTextCell;

@protocol DXDetailTextCellDelegate <NSObject>

@optional
/**
 *  点击头像
 */
- (void)didTapAvatarViewInDetailTextCellWithUserID:(NSString *)userID;
/**
 *  点击话题
 */
- (void)didTapTopicViewInDetailTextCellWithTopicID:(NSString *)topicID;

- (void)detailTextCell:(DXDetailTextCell *)cell didSelectReferUserWithUserID:(NSString *)userID;
- (void)detailTextCell:(DXDetailTextCell *)cell didSelectReferTopicWithTopicID:(NSString *)topicID;

@end

@interface DXDetailTextCell : UITableViewCell

@property (nonatomic, strong) DXTimelineFeed *feed;

@property (nonatomic, weak) id<DXDetailTextCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

/**
 *  返回cell高度
 */
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withFeed:(DXTimelineFeed *)feed;

@end
