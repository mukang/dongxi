//
//  DXStatusBarHUD.h
//  dongxi
//
//  Created by 穆康 on 15/12/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXStatusBarHUD : NSObject

/**
 *  显示正在发布
 *
 *  @param msg 提示信息
 */
+ (void)showPublishingWithMsg:(NSString *)msg;

/**
 *  显示发布成功
 *
 *  @param msg 提示信息
 */
+ (void)showSuccessWithMsg:(NSString *)msg;

/**
 *  显示发布失败
 *
 *  @param msg 提示信息
 */
+ (void)showErrorWithMsg:(NSString *)msg;

@end
