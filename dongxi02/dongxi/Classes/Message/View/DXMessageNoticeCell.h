//
//  DXMessageNoticeCell.h
//  dongxi
//
//  Created by 穆康 on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXNotice;
@class DXMessageNoticeCell;

@protocol DXMessageNoticeCellDelegate <NSObject>

@optional
/**
 *  点击头像
 */
- (void)didTapAvatarInMessageNoticeCellWithUserID:(NSString *)userID;

- (void)messageNoticeCell:(DXMessageNoticeCell *)cell didTapNick:(NSString *)nick;

@end

@interface DXMessageNoticeCell : UITableViewCell

@property (nonatomic, strong) DXNotice *notice;

@property (nonatomic, weak) id<DXMessageNoticeCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

/**
 *  返回cell高度
 */
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withNotice:(DXNotice *)notice;

@end
