//
//  DXBarButtonItem.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXBarButtonItem : UIBarButtonItem

/**
 * 获取默认的工具栏返回按钮
 */
+ (instancetype)defaultSystemBackItemForController:(UIViewController *)controller;

@end
