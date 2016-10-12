//
//  DXActivityWishAttendCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXActivityWishAttendCellDelegate;

@interface DXActivityWishAttendCell : UICollectionViewCell

@property (nonatomic, weak) id<DXActivityWishAttendCellDelegate> delegate;

@property (nonatomic, readonly) UIView * containerView;
@property (nonatomic) NSUInteger wisherCount;
@property (nonatomic) NSArray * wisherAvatars;

@end


@protocol DXActivityWishAttendCellDelegate <NSObject>

@optional

- (void)wishAttendCell:(DXActivityWishAttendCell *)cell didSelectAvatarAtIndex:(NSUInteger)index;

- (void)wishAttendCell:(DXActivityWishAttendCell *)cell didSelectMoreButton:(UIView *)sender;

@end
