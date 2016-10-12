//
//  DXTagAlertView.h
//  dongxi
//
//  Created by 穆康 on 16/3/10.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXTagAlertView : UIView

/** 唯一的初始化方法 */
- (instancetype)initWithController:(UIViewController *)controller;
/** 显示 */
- (void)show;

@end
