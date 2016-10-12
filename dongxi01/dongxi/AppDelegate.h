//
//  AppDelegate.h
//  dongxi
//
//  Created by 穆康 on 15/8/3.
//  Copyright (c) 2015年 穆康. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *launchWindow;

/** 显示启动视窗 */
- (void)showLaunchWindow;

/** 检查登陆状态 */
- (void)checkLoginStatus;

@end

