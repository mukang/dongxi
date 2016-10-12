//
//  DXTopicUserInviteCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/29.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXTopicUserInviteCell;
@protocol DXTopicUserInviteCellDelegate;


typedef void(^DXTopicUserInviteCellTapBlock)(DXTopicUserInviteCell * sender);



@interface DXTopicUserInviteCell : UITableViewCell

@property (nonatomic, weak) id <DXTopicUserInviteCellDelegate> delegate;
@property (nonatomic, copy) DXTopicUserInviteCellTapBlock tapBlock;

@property (nonatomic, strong) DXAvatarView * avatarView;
@property (nonatomic, strong) NSString * nick;
@property (nonatomic, strong) NSString * location;
@property (nonatomic, assign) BOOL invited;

@end



@protocol DXTopicUserInviteCellDelegate <NSObject>

@optional
- (void)userInviteCell:(DXTopicUserInviteCell *)cell didTapAvatarView:(UIImageView *)avatarView;

@end