//
//  DXInvitationCodeCell.h
//  dongxi
//
//  Created by 穆康 on 15/11/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXInvitationCodeCell;
@class DXUserCoupon;

@protocol DXInvitationCodeCellDelegate <NSObject>

@optional
- (void)invitationCodeCell:(DXInvitationCodeCell *)cell shareInvitationCodeWithCouponIndex:(NSInteger)couponIndex;

@end

@interface DXInvitationCodeCell : UITableViewCell

/** 邀请码模型 */
@property (nonatomic, strong) DXUserCoupon *coupon;
/** 序号 */
@property (nonatomic, assign) NSInteger couponIndex;

@property (nonatomic, weak) id<DXInvitationCodeCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
