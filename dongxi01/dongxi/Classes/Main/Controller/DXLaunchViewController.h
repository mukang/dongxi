//
//  DXLaunchViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const DXNotificationLaunchWindowDidAppear;
extern NSString * const DXNotificationLaunchWindowDidDisappear;

@interface DXLaunchViewController : UIViewController

@property (nonatomic, weak) UIWindow * launchWindow;

@end
