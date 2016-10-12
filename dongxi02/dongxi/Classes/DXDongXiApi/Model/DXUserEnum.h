//
//  DXUserEnum.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#ifndef dongxi_DXUserEnum_h
#define dongxi_DXUserEnum_h

/** 用户关系枚举定义 */
typedef enum : NSUInteger {
    /** 无关系 */
    DXUserRelationTypeNone = 0,
    /** 已关注 */
    DXUserRelationTypeFollowed,
    /** 已被关注 */
    DXUserRelationTypeFollower,
    /** 互相关注（好友） */
    DXUserRelationTypeFriend,
    /** 当前用户 */
    DXUserRelationTypeCurrentUser
} DXUserRelationType;


/** 用户性别枚举定义 */
typedef enum : NSUInteger {
    /** 性别为女 */
    DXUserGenderTypeFemale = 0,
    /** 性别为男 */
    DXUserGenderTypeMale,
    /** 性别为其他 */
    DXUserGenderTypeOther
} DXUserGenderType;


/**
 * 用户重置密码短信发送状态定义
 */
typedef enum : NSUInteger {
    /*! 短信发送失败 */
    DXUserResetPassSmsFailed = 0,
    /*! 短信发送成功 */
    DXUserResetPassSmsSended,
    /*! 用户不存在 */
    DXUserResetPassSmsTargetUserNotExisted,
} DXUserResetPassSmsStatus;

/**
 * 用户重置密码结果状态定义
 */
typedef enum : NSUInteger {
    /*! 重置密码失败 */
    DXUserResetPasswordFailed = 0,
    /*! 重置密码成功 */
    DXUserResetPasswordOK,
    /*! 错误的验证码 */
    DXUserResetPasswordWrongCode,
} DXUserResetPasswordStatus;

/**
 * 用户修改密码结果状态定义
 */
typedef enum : NSInteger {
    /*! 密码修改时有错误发生 */
    DXUserChangePasswordErrorOccurred = -1,
    /*! 新密码与原密码一致 */
    DXUserChangePasswordNewPasswordIdenticalToOldOne = 0,
    /*! 修改密码成功 */
    DXUserChangePasswordOK,
    /*! 原密码不正确 */
    DXUserChangePasswordWrongOldPassword,
} DXUserChangePasswordStatus;

/** 用户认证枚举定义 */
typedef enum : NSInteger {
    /** 无认证 */
    DXUserVerifiedTypeNone = 0,
    /** 东西官方认证 */
    DXUserVerifiedTypeOfficial = 3
} DXUserVerifiedType;

#endif
