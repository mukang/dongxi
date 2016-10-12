//
//  DXMessageLikeCell.h
//  dongxi
//
//  Created by 穆康 on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXNoticeLike;

@protocol DXMessageLikeCellDelegate <NSObject>

@optional
/**
 *  点击头像
 */
- (void)didTapAvatarInMessageLikeCellWithUserID:(NSString *)userID;

@end

@interface DXMessageLikeCell : UITableViewCell

@property (nonatomic, strong) DXNoticeLike *like;

@property (nonatomic, weak) id<DXMessageLikeCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
