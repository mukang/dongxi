//
//  DXUserLoginInfo.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DXUserLoginAccountTypeMobile = 1,
    DXUserLoginAccountTypeEmail,
} DXUserLoginAccountType;

/**
 * 用户登陆信息
 */
@interface DXUserLoginInfo : NSObject

/*! 登陆账号类型（只读），见DXUserLoginAccountType，无需手动修改 */
@property (nonatomic, assign, readonly) DXUserLoginAccountType account_type;

/*! 登陆账号信息（只读），无需手动修改 */
@property (nonatomic, strong, readonly) NSDictionary * account_info;

/*! 登陆设备信息（只读），无需手动修改 */
@property (nonatomic, strong, readonly) NSDictionary * summery;

/**
 * 以邮箱+密码方式设置登陆信息
 *
 * @param email     用户邮箱地址
 * @param password  登陆密码
 */
- (void)setAccountInfoWithEmail:(NSString *)email andPassword:(NSString *)password;

/**
 * 以手机+密码方式设置登陆信息
 *
 * @param mobile    用户手机号码
 * @param password  登陆密码
 */
- (void)setAccountInfoWithMobile:(NSString *)mobile andPassword:(NSString *)password;

/*! 设置推送ID，会自动更新summery内容 */
- (void)setPushID:(NSString *)pushID;

@end
