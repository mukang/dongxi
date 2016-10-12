//
//  DXActivityWishUserCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXActivityWishUserCellDelegate;




@interface DXActivityWishUserCell : UITableViewCell

@property (nonatomic, weak) id <DXActivityWishUserCellDelegate> delegate;

@property (nonatomic, strong) DXAvatarView * avatarView;
@property (nonatomic, strong) NSString * nick;
@property (nonatomic, strong) NSString * location;

@end



@protocol DXActivityWishUserCellDelegate <NSObject>

@optional
- (void)wishUserCell:(DXActivityWishUserCell *)cell didTapAvatarView:(UIImageView *)avatarView;

@end