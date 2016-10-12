//
//  DXProfileViewController.h
//  dongxi
//
//  Created by 穆康 on 15/8/4.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXDongXiApi.h"
#import "DXFeedPublishViewController.h"
#import "DXRouteManager.h"

/** 个人页控制器类型枚举 */
typedef enum : NSUInteger {
    /** 个人页控制器类型：当前登陆用户 */
    DXProfileViewControllerLoginUser,
    /** 个人页控制器类型：通过用户的uid来访问 */
    DXProfileViewControllerUserUID,
    /** 个人页控制器类型：通过用户的nick来访问 */
    DXProfileViewControllerUserNick,
} DXProfileViewControllerType;



@interface DXProfileViewController : UIViewController<DXFeedPublishDelegateController, DXRouteControler>

/**
 *  指定的初始化方法
 *
 *  @param controllerType 控制类型，见DXProfileViewControllerType
 *
 *  @return 返回DXProfileViewController实例
 *
 *  @author Xu Shiwen
 *  @date   16/11/2015
 */
- (instancetype)initWithControllerType:(DXProfileViewControllerType)controllerType;

@property (nonatomic, copy) NSString * nick;
@property (nonatomic, copy) NSString * uid;
@property (nonatomic, readonly, assign) DXProfileViewControllerType controllerType;

@end
