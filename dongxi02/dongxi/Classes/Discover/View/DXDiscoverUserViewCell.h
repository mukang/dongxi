//
//  DXDiscoverUserViewCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXDiscoverUserViewCellDelegate;


@interface DXDiscoverUserViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIView * containerView;

@property (nonatomic, strong) UIImageView * photoView1;
@property (nonatomic, strong) UIImageView * photoView2;
@property (nonatomic, strong) UIImageView * photoView3;
@property (nonatomic, strong) DXAvatarView * avatarView;
@property (nonatomic, strong) NSString * nick;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, assign) NSUInteger relation;

@property (nonatomic, weak) id <DXDiscoverUserViewCellDelegate> delegate;


@end



@protocol DXDiscoverUserViewCellDelegate <NSObject>

@optional

- (void)didTapAvatarInDiscoverUserViewCell:(DXDiscoverUserViewCell *)cell;

- (void)didTapFollowButtonInDiscoverUserViewCell:(DXDiscoverUserViewCell *)cell;

@end