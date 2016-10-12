//
//  DXShareInvitationCodeView.h
//  dongxi
//
//  Created by 穆康 on 15/11/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXShareInvitationCodeView;

@protocol DXShareInvitationCodeViewDelegate <NSObject>

@optional
/* 点击取消按钮 */
- (void)didClickCancellBtnInShareInvitationCodeView:(DXShareInvitationCodeView *)view;
/* 点击短信按钮 */
- (void)didTapSmsBtnInShareInvitationCodeView:(DXShareInvitationCodeView *)view;
/* 点击邮件按钮 */
- (void)didTapEmailBtnInShareInvitationCodeView:(DXShareInvitationCodeView *)view;
/* 点击微信按钮 */
- (void)shareInvitationCodeView:(DXShareInvitationCodeView *)view didTapWechatBtnWithSence:(int)sence;

@end

@interface DXShareInvitationCodeView : UIView

@property (nonatomic, weak) id<DXShareInvitationCodeViewDelegate> delegate;

@end
