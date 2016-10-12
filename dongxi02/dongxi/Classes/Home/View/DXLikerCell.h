//
//  DXLikerCell.h
//  dongxi
//
//  Created by 穆康 on 15/10/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXUser;

@protocol DXLikerCellDelegate;


@interface DXLikerCell : UITableViewCell

@property (nonatomic, strong) DXUser *user;

@property (nonatomic, weak) id<DXLikerCellDelegate> delegate;

@property (nonatomic, assign) DXUserRelationType relation;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end



@protocol DXLikerCellDelegate <NSObject>

@optional

- (void)didTapAvatarInLikerCellWithUserID:(NSString *)userID;

- (void)didTapFollowBtnInLikerCellWithUser:(DXUser *)user;

- (void)didTapFollowBtnInLikerCell:(DXLikerCell *)cell withUser:(DXUser *)user;

@end