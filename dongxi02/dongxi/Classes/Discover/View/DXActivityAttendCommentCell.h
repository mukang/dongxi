//
//  DXActivityAttendCommentCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXActivityAttendCommentCellDelegate;


@interface DXActivityAttendCommentCell : UICollectionViewCell


@property (nonatomic, readonly) UIView * containerView;
@property (nonatomic) DXAvatarView * avatarView;
@property (nonatomic) UILabel * nickLabel;
@property (nonatomic) UILabel * timeLabel;
@property (nonatomic) NSUInteger stars;
@property (nonatomic) DXMutiLineLabel * commentLabel;

@property (nonatomic, weak) id<DXActivityAttendCommentCellDelegate> delegate;

@end


@protocol DXActivityAttendCommentCellDelegate <NSObject>

@optional
- (void)userDidTapAvatarInCell:(DXActivityAttendCommentCell *)cell;

@end
