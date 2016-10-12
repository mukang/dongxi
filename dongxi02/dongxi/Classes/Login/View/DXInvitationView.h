//
//  DXInvitationView.h
//  dongxi
//
//  Created by 穆康 on 15/11/26.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  登陆页邀请视图

#import <UIKit/UIKit.h>

@protocol DXInvitationViewDelegate <NSObject>

@required
/** 点击有邀请码按钮 */
- (void)didTapHadKeyBtn;
/** 点击获取邀请码按钮 */
- (void)didTapGetKeyBtn;

@end

@interface DXInvitationView : UIView

@property (nonatomic, weak) id<DXInvitationViewDelegate> delegate;

/** 唯一的初始化方法 */
- (instancetype)initWithController:(UIViewController *)controller;

/** 显示 */
- (void)show;

@end
