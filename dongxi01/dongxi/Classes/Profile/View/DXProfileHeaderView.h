//
//  DXProfileHeaderView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/6.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXTabBarView.h"
#import "DXUserProfile.h"

@interface DXProfileHeaderView : UIView

@property (nonatomic, strong, readonly) UIImageView * avatarView;
@property (nonatomic, strong, readonly) DXTabBarView * switchTabBarView;
@property (nonatomic, strong, readonly) UIButton * chatButton;
@property (nonatomic, strong, readonly) UIButton * followButton;
@property (nonatomic, strong, readonly) UILabel * bioLabel;
@property (nonatomic, strong, readonly) UILabel * fansLabel;
@property (nonatomic, strong, readonly) UILabel * followLabel;

@property (nonatomic, assign) BOOL hideSocialButtons;
@property (nonatomic, assign) BOOL showAvatarOnly;

@property (nonatomic, assign) NSUInteger fansCount;
@property (nonatomic, assign) NSUInteger followCount;
//@property (nonatomic, assign) DXUserGenderType gender;
@property (nonatomic, assign) DXUserRelationType relation;
@property (nonatomic, copy) NSString * bio;
@property (nonatomic, copy) NSString * avatar;
/** 认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;

@property (nonatomic, strong) DXUserProfile * profile;

@end
