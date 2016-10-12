//
//  DXUserPasswordChangeInfo.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 用户密码修改信息
 */
@interface DXUserPasswordChangeInfo : NSObject

/*! 旧密码 */
@property (nonatomic, copy) NSString * oldpassword;

/*! 新密码 */
@property (nonatomic, copy) NSString * newpassword;

/*! 验证信息（只读） */
@property (nonatomic, readonly) NSString * key;

@end
