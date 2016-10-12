//
//  DXUserInfoManager.h
//  dongxi
//
//  Created by Xu Shiwen on 15/12/8.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXUserInfo.h"


@interface DXUserInfoManager : NSObject


+ (instancetype)sharedManager;

- (DXUserInfo *)userInfoForUID:(NSString *)uid;

- (void)setUserInfo:(DXUserInfo *)userInfo forUID:(NSString *)uid;

- (void)addLabelObserver:(UILabel * __weak)label forNicknameWithUID:(NSString *)uid;

- (void)addImageViewObserver:(UIImageView * __weak)imageView forAvatarWithUID:(NSString *)uid;


+ (NSString *)getNewestNicknameWithCurrentNickname:(NSString *)nickname updateTime:(NSTimeInterval)updateTime forUID:(NSString *)uid;

+ (NSString *)getNewestAvatarWithCurrentAvatar:(NSString *)avatar updateTime:(NSTimeInterval)updateTime forUID:(NSString *)uid;

+ (DXUserInfo *)userInfoForUID:(NSString *)uid;

+ (void)setUserInfo:(DXUserInfo *)userInfo forUID:(NSString *)uid;

@end



@interface UIImageView (DXUserInfoManager)

- (void)hookAvatarImageForUID:(NSString *)uid;

@end


@interface UILabel (DXUserInfoManager)

- (void)hookNicknameTextForUID:(NSString *)uid;


@end
