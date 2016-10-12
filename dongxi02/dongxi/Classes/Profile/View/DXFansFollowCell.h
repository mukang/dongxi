//
//  DXFansFollowCell.h
//  dongxi
//
//  Created by 邱思雨 on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXDongXiApi.h"

@class DXFansFollowCell;

@protocol DXFansFollowCellDelegate <NSObject>

@optional

/**
 *  点击了头像
 *
 *  @param cell 被点击的头像所属的DXFansFollowCell实例
 *
 *  @author Xu Shiwen
 *  @date   02/11/2015
 */
- (void)didTapAvatarInFansFollowCell:(DXFansFollowCell *)cell;

/**
 *  点击了关注按钮
 *
 *  @param cell 被点击的关注按钮所属的DXFansFollowCell实例
 *
 *  @author Xu Shiwen
 *  @date   02/11/2015
 */
- (void)didTapFollowButtonInFansFollowCell:(DXFansFollowCell *)cell;

@end


@interface DXFansFollowCell : UITableViewCell

//@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) DXAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, assign) DXUserRelationType relation;
@property (nonatomic, weak) id <DXFansFollowCellDelegate> delegate;

@end
