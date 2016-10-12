//
//  DXSmsCheckViewController.h
//  dongxi
//
//  Created by 穆康 on 15/8/13.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  检查验证码

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DXSmsCheckType) {
    DXSmsCheckTypeRegisterPhone = 1,
    DXSmsCheckTypeBindPhone,
    DXSmsCheckTypeForgetPassword
};

@interface DXSmsCheckViewController : UIViewController

/** 验证类型 */
@property (nonatomic, assign, readonly) DXSmsCheckType smsCheckType;

/** 是否是从邀请码页面跳转过来的 */
@property (nonatomic, assign, getter=isFromHadKeyVC) BOOL fromHadKeyVC;

/**
 *  唯一初始化方法
 */
- (instancetype)initWithSmsCheckType:(DXSmsCheckType)smsCheckType;

@end
