//
//  DXRegisterUserInfoViewController.h
//  dongxi
//
//  Created by 穆康 on 16/1/6.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//  注册用户信息

#import <UIKit/UIKit.h>

@interface DXRegisterUserInfoViewController : UIViewController

@property (nonatomic, copy) void(^registerCompletionBlock)();

/** 是否是新注册的 */
@property (nonatomic, assign) BOOL isNewRegistered;

@end
