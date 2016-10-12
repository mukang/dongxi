//
//  DXLikeRankAlertView.h
//  dongxi
//
//  Created by 穆康 on 16/3/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXLikeRankAlertView : UIView

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content fromController:(UIViewController *)controller;

- (void)show;

@end
