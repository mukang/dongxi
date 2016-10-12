//
//  DXUserPasswordResetInfo.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 用户密码重置资料
 */
@interface DXUserPasswordResetInfo : NSObject

/*! 要重置密码的用户的uid */
@property (nonatomic, copy) NSString * uid;

/*! 用于重置密码的验证码，通过短信或邮件获得 */
@property (nonatomic, copy) NSString * code;

/*! 新密码 */
@property (nonatomic, copy) NSString * newpassword;

/*! 验证信息（只读） */
@property (nonatomic, readonly) NSString * key;

@end
