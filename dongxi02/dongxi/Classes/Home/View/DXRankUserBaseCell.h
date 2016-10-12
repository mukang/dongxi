//
//  DXRankUserBaseCell.h
//  dongxi
//
//  Created by 穆康 on 16/3/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DXRankUserBaseCellDelegate;



@interface DXRankUserBaseCell : UITableViewCell

@property (nonatomic, weak) UIImageView *rankNumView;
@property (nonatomic, weak) UILabel *rankNumLabel;
@property (nonatomic, assign) DXUserRelationType relation;

@property (nonatomic, strong) DXRankUser *rankUser;
@property (nonatomic, weak) id<DXRankUserBaseCellDelegate> delegate;

@end




@protocol DXRankUserBaseCellDelegate <NSObject>

@optional
- (void)rankUserCell:(DXRankUserBaseCell *)cell didTapAvatarViewWithUserID:(NSString *)userID;

- (void)rankUserCell:(DXRankUserBaseCell *)cell didTapFollowBtnWithRankUser:(DXRankUser *)rankUser;


@end
