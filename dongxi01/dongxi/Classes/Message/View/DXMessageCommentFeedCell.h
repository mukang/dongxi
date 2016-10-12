//
//  DXMessageCommentFeedCell.h
//  dongxi
//
//  Created by 穆康 on 15/11/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXNoticeCommentWrapper;

@protocol DXMessageCommentFeedCellDelegate <NSObject>

@optional
- (void)messageCommentFeedCell:(UITableViewCell *)cell didTapFeedViewWithFeedID:(NSString *)feedID;

@end

@interface DXMessageCommentFeedCell : UITableViewCell

@property (nonatomic, strong) DXNoticeCommentWrapper *commentWrapper;

@property (nonatomic, weak) id<DXMessageCommentFeedCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
