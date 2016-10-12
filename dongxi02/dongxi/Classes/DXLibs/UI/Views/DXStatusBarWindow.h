//
//  DXStatusBarWindow.h
//  dongxi
//
//  Created by 穆康 on 15/12/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXStatusBarWindow : UIWindow

/** 中间文字的距离 */
@property (nonatomic, assign) CGFloat distance;

/** 开始动画 */
- (void)startAnimating;

/** 结束动画 */
- (void)stopAnimating;

@end
