//
//  DXRegisterUserAvatarView.h
//  dongxi
//
//  Created by 穆康 on 16/1/6.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DXRegisterUserAvatarType) {
    DXRegisterUserAvatarTypeFemale = 0,
    DXRegisterUserAvatarTypeMale,
    DXRegisterUserAvatarTypeOther
};

@interface DXRegisterUserAvatarView : UIView

/** 头像上的遮盖 */
@property (nonatomic, weak) UIImageView *addAvatarView;
/** 头像视图 */
@property (nonatomic, weak) UIImageView *avatarImageView;

/** 头像是否是自定义的 */
@property (nonatomic, assign, getter=isCustom) BOOL custom;

/** 注册用户头像类型 */
@property (nonatomic, assign) DXRegisterUserAvatarType avatarType;

@end
