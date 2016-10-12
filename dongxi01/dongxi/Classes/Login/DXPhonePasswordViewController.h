//
//  DXPhonePasswordViewController.h
//  dongxi
//
//  Created by 穆康 on 15/8/13.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXPhonePasswordViewController : UIViewController

/** 手机号码 */
@property (nonatomic, copy) NSString *mobile;

/** 是否是忘记密码 */
@property (nonatomic, assign, getter=isForgetPassword) BOOL forgetPassword;

@end
