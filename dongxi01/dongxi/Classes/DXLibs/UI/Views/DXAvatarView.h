//
//  DXAvatarView.h
//  dongxi
//
//  Created by 穆康 on 15/12/31.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DXCertificationIconSize) {
    DXCertificationIconSizeSmall,
    DXCertificationIconSizeMedium,
    DXCertificationIconSizeLarge
};

@interface DXAvatarView : UIView

/** 头像 */
@property (nonatomic, weak) UIImageView *avatarImageView;

/** 认证图标 */
@property (nonatomic, weak) UIImageView *certificationIconView;

/** 隐藏认证图标 */
@property (nonatomic, assign) BOOL certificationIconHidden;

/** 认证图标大小 */
@property (nonatomic, assign) DXCertificationIconSize certificationIconSize;

/** 认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;

@end
