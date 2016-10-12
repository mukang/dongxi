//
//  DXSmsCheckViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/13.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSmsCheckViewController.h"
#import "DXPhonePasswordViewController.h"
#import "DXAnimationButtonCover.h"
#import "DXDongXiApi.h"
#import "DXGetSmsKeyView.h"
#import <YYText.h>
#import "DXUserAgreementViewController.h"
#import "DXPrivacyPolicyViewController.h"
#import "WXApiManager.h"
#import "JPUSHService.h"

@interface DXSmsCheckViewController () <UITextFieldDelegate, DXGetSmsKeyViewDelegate>

/** 手机图片 */
@property (nonatomic, weak) UIImageView *phoneImageV;
/** 手机下划线 */
@property (nonatomic, weak) UIView *phoneUnderLine;
/** 手机输入框 */
@property (nonatomic, weak) UITextField *phoneF;
/** 验证码下划线 */
@property (nonatomic, weak) UIView *smsCheckUnderLine;
/** 获取验证码 */
@property (nonatomic, weak) DXGetSmsKeyView *getSmsKeyView;
/** 验证码入框 */
@property (nonatomic, weak) UITextField *smsCheckF;
/** 提交按钮 */
@property (nonatomic, weak) UIButton *commitBtn;
/** 按钮的动画遮盖 */
@property (nonatomic, weak) DXAnimationButtonCover *cover;
/** 错误提示 */
@property (nonatomic, weak) UILabel *warnL;
/** 用户ID */
@property (nonatomic, copy) NSString *userID;
/** 服务协议和隐私声明 */
@property (nonatomic, weak) YYLabel *noticeLabel;

@end

@implementation DXSmsCheckViewController {
    __weak DXSmsCheckViewController *weakSelf;
}

- (instancetype)initWithSmsCheckType:(DXSmsCheckType)smsCheckType {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _smsCheckType = smsCheckType;
    }
    return self;
}

#pragma mark - 初始化方法

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    
    switch (self.smsCheckType) {
        case DXSmsCheckTypeRegisterPhone:
            self.dt_pageName = DXDataTrackingPage_RegisterPhoneVerify;
            break;
        case DXSmsCheckTypeBindPhone:
            self.dt_pageName = DXDataTrackingPage_RegisterWechatVerify;
            break;
        case DXSmsCheckTypeForgetPassword:
            self.dt_pageName = DXDataTrackingPage_RecoverPhoneVerify;
            break;
            
        default:
            break;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTitleView];
    
    [self setupContentView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self registNotification];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.phoneF becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self.phoneF isFirstResponder]) {
        [self.phoneF resignFirstResponder];
    }
    if ([self.smsCheckF isFirstResponder]) {
        [self.smsCheckF resignFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 将提交按钮变为正常状态
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
}

- (void)setupTitleView {
    
    if (!self.isFromHadKeyVC) {
        // 返回按钮
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setImage:[UIImage imageNamed:@"button_back_login"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(clickbackBtn) forControlEvents:UIControlEventTouchUpInside];
        backBtn.contentEdgeInsets = UIEdgeInsetsMake(DXRealValue(21), DXRealValue(12), DXRealValue(21), DXRealValue(12));
        backBtn.frame = CGRectMake(DXRealValue(55), DXRealValue(84), DXRealValue(36), DXRealValue(63));
        [self.view addSubview:backBtn];
    }
    
    // title
    UILabel *titleL = [[UILabel alloc] init];
    switch (self.smsCheckType) {
        case DXSmsCheckTypeRegisterPhone:
            titleL.text = @"注册新用户";
            break;
        case DXSmsCheckTypeBindPhone:
            titleL.text = @"绑定手机号";
            break;
        case DXSmsCheckTypeForgetPassword:
            titleL.text = @"找回密码";
            break;
            
        default:
            break;
    }
    titleL.textColor = DXRGBColor(72, 72, 72);
    titleL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(24)];
    [titleL sizeToFit];
    titleL.center = CGPointMake(DXScreenWidth * 0.5, DXRealValue(115.5f));
    [self.view addSubview:titleL];
}


- (void)setupContentView {
    
    // 手机图片
    UIImageView *phoneImageV = [[UIImageView alloc] init];
    phoneImageV.image = [UIImage imageNamed:@"icon_phone_black"];
    phoneImageV.highlightedImage = [UIImage imageNamed:@"icon_phone_grew"];
    phoneImageV.frame = CGRectMake(DXRealValue(84), DXRealValue(211), DXRealValue(17), DXRealValue(17));
    [self.view addSubview:phoneImageV];
    self.phoneImageV = phoneImageV;
    
    // 下划线
    UIView *phoneUnderLine = [[UIView alloc] init];
    phoneUnderLine.size = CGSizeMake(DXRealValue(280), 0.5);
    phoneUnderLine.center = CGPointMake(DXScreenWidth * 0.5, CGRectGetMaxY(phoneImageV.frame) + 12);
    phoneUnderLine.backgroundColor = DXRGBColor(64, 189, 206);
    [self.view addSubview:phoneUnderLine];
    self.phoneUnderLine = phoneUnderLine;
    
    // 输入框
    UITextField *phoneF = [[UITextField alloc] init];
    CGFloat phoneFW = CGRectGetMaxX(phoneUnderLine.frame) - CGRectGetMaxX(phoneImageV.frame) - DXRealValue(4);
    CGFloat phoneFH = 30;
    phoneF.size = CGSizeMake(phoneFW, phoneFH);
    phoneF.centerY = phoneImageV.centerY;
    phoneF.x = CGRectGetMaxX(phoneImageV.frame) + DXRealValue(4);
    phoneF.attributedPlaceholder = [self attributedWithString:@"请输入手机号" color:DXRGBColor(143, 143, 143)];
    phoneF.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    phoneF.textColor = DXRGBColor(72, 72, 72);
    phoneF.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneF.keyboardType = UIKeyboardTypeNumberPad;
    phoneF.delegate = self;
    [self.view addSubview:phoneF];
    self.phoneF = phoneF;
    
    // 下划线
    UIView *smsCheckUnderLine = [[UIView alloc] init];
    smsCheckUnderLine.size = phoneUnderLine.size;
    smsCheckUnderLine.x = phoneUnderLine.x;
    smsCheckUnderLine.y = CGRectGetMaxY(phoneUnderLine.frame) + DXRealValue(59) + DXRealValue(17);
    smsCheckUnderLine.backgroundColor = DXRGBColor(64, 189, 206);
    [self.view addSubview:smsCheckUnderLine];
    self.smsCheckUnderLine = smsCheckUnderLine;
    
    // 获取验证码
    DXGetSmsKeyView *getSmsKeyView = [[DXGetSmsKeyView alloc] init];
    CGFloat getSmsKeyViewW = DXRealValue(80);
    CGFloat getSmsKeyViewH = DXRealValue(26);
    CGFloat getSmsKeyViewX = CGRectGetMaxX(smsCheckUnderLine.frame) - getSmsKeyViewW;
    CGFloat getSmsKeyViewY = CGRectGetMaxY(smsCheckUnderLine.frame) - getSmsKeyViewH - DXRealValue(7);
    getSmsKeyView.frame = CGRectMake(getSmsKeyViewX, getSmsKeyViewY, getSmsKeyViewW, getSmsKeyViewH);
    getSmsKeyView.delegate = self;
    [self.view addSubview:getSmsKeyView];
    self.getSmsKeyView = getSmsKeyView;
    
    // 验证码输入框
    UITextField *smsCheckF = [[UITextField alloc] init];
    smsCheckF.width = getSmsKeyView.x - phoneF.x;
    smsCheckF.height = phoneF.height;
    smsCheckF.x = phoneF.x;
    smsCheckF.centerY = getSmsKeyView.centerY;
    smsCheckF.attributedPlaceholder = [self attributedWithString:@"请输入验证码" color:DXRGBColor(143, 143, 143)];
    smsCheckF.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    smsCheckF.textColor = DXRGBColor(72, 72, 72);
    smsCheckF.keyboardType = UIKeyboardTypeNumberPad;
    smsCheckF.delegate = self;
    [self.view addSubview:smsCheckF];
    self.smsCheckF = smsCheckF;
    
    // 提交
    UIButton *commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commitBtn.size = CGSizeMake(DXRealValue(280), DXRealValue(44));
    commitBtn.centerX = DXScreenWidth * 0.5;
    commitBtn.y = smsCheckUnderLine.y + DXRealValue(80);
    [commitBtn setImage:[UIImage imageNamed:@"button_commit_blue_normal"] forState:UIControlStateNormal];
    [commitBtn setImage:[UIImage imageNamed:@"button_commit_blue_click"] forState:UIControlStateHighlighted];
    [commitBtn addTarget:self action:@selector(clickCommitBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commitBtn];
    self.commitBtn = commitBtn;
    
    // 按钮的动画遮盖
    DXAnimationButtonCover *cover = [[DXAnimationButtonCover alloc] initWithFrame:commitBtn.frame];
    [self.view addSubview:cover];
    self.cover = cover;
    
    // 错误提示
    UILabel *warnL = [[UILabel alloc] init];
    warnL.textAlignment = NSTextAlignmentCenter;
    warnL.textColor = DXRGBColor(255, 109, 119);
    warnL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(12)];
    warnL.size = CGSizeMake(commitBtn.width, 12);
    warnL.centerX = commitBtn.centerX;
    warnL.y = commitBtn.y - 20;
    warnL.hidden = YES;
    [self.view addSubview:warnL];
    self.warnL = warnL;
    
    // 服务协议和隐私声明
    if (self.smsCheckType != DXSmsCheckTypeForgetPassword) {
        YYLabel *noticeLabel = [[YYLabel alloc] init];
        
        NSString *userAgreementStr = @"服务协议";
        NSString *privacyPolicyStr = @"隐私声明";
        NSString *noticeStr = [NSString stringWithFormat:@"注册代表你同意我们的%@和%@", userAgreementStr, privacyPolicyStr];
        
        NSRange userAgreementRange = [noticeStr rangeOfString:userAgreementStr];
        NSRange privacyPolicyRange = [noticeStr rangeOfString:privacyPolicyStr];
        
        YYTextHighlight *userAgreementHighlight = [[YYTextHighlight alloc] init];
        userAgreementHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            DXUserAgreementViewController *vc = [[DXUserAgreementViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        };
        YYTextHighlight *privacyPolicyHighlight = [[YYTextHighlight alloc] init];
        privacyPolicyHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            DXPrivacyPolicyViewController *vc = [[DXPrivacyPolicyViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:noticeStr];
        attText.yy_font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(14)];
        attText.yy_color = DXRGBColor(72, 72, 72);
        [attText yy_setColor:DXRGBColor(109, 197, 255) range:userAgreementRange];
        [attText yy_setColor:DXRGBColor(109, 197, 255) range:privacyPolicyRange];
        [attText yy_setUnderlineColor:DXRGBColor(109, 197, 255) range:userAgreementRange];
        [attText yy_setUnderlineColor:DXRGBColor(109, 197, 255) range:privacyPolicyRange];
        [attText yy_setUnderlineStyle:NSUnderlineStyleSingle range:userAgreementRange];
        [attText yy_setUnderlineStyle:NSUnderlineStyleSingle range:privacyPolicyRange];
        [attText yy_setTextHighlight:userAgreementHighlight range:userAgreementRange];
        [attText yy_setTextHighlight:privacyPolicyHighlight range:privacyPolicyRange];
        
        noticeLabel.attributedText = attText;
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        noticeLabel.frame = CGRectMake(0, CGRectGetMaxY(commitBtn.frame) + DXRealValue(20), DXScreenWidth, DXRealValue(20));
        [self.view addSubview:noticeLabel];
        self.noticeLabel = noticeLabel;
    }
}

#pragma mark - 通知
- (void)registNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGFloat keyboardY = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].origin.y;
    
    CGFloat contentMaxY = CGRectGetMaxY(self.commitBtn.frame) + DXRealValue(50);
    
    if (contentMaxY <= keyboardY) return;
    
    [UIView animateWithDuration:duration animations:^{
        self.view.y = keyboardY - contentMaxY;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    
    if (self.view.y == 0) return;
    
    [UIView animateWithDuration:duration animations:^{
        self.view.y = 0;
    }];
}


#pragma mark - <UITextFieldDelegate>
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.phoneF) {
        self.phoneImageV.highlighted = NO;
    } else {
        self.phoneImageV.highlighted = YES;
    }
    
    if (self.warnL.hidden == NO) {
        self.warnL.hidden = YES;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    if (textField == self.phoneF) {
        self.phoneImageV.highlighted = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.isFirstResponder) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.phoneF.isFirstResponder) {
        [self.phoneF resignFirstResponder];
    } else if (self.smsCheckF.isFirstResponder) {
        [self.smsCheckF resignFirstResponder];
    }
}

#pragma mark - DXGetSmsKeyViewDelegate

// 点击获取验证码
- (void)didClickGetSmsKeyInGetSmsKeyView:(DXGetSmsKeyView *)view {
    
    // 退出键盘
    if (self.phoneF.isFirstResponder) {
        [self.phoneF resignFirstResponder];
    } else if (self.smsCheckF.isFirstResponder) {
        [self.smsCheckF resignFirstResponder];
    }
    
    // 判断手机号是否是11位
    if (self.phoneF.text.length != 11) {
        self.warnL.text = @"请输入正确的手机号";
        self.warnL.hidden = NO;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    }
    
    // 将获取验证码的view设为不可点击
    self.getSmsKeyView.userInteractionEnabled = NO;
    
    // 判断验证类型
    switch (self.smsCheckType) {
        case DXSmsCheckTypeRegisterPhone: // 注册新用户
        {
            // 验证手机号是否可用 - 注册新用户的情况需要用户还未注册，才可以获取验证码
            [[DXDongXiApi api] isMobile:self.phoneF.text valid:^(BOOL valid, NSError *error) {
                if (valid == NO) {
                    weakSelf.getSmsKeyView.userInteractionEnabled = YES;
                    weakSelf.warnL.text = @"该号码已注册";
                    weakSelf.warnL.hidden = NO;
                    [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
                } else {
                    // 发送短信验证码
                    [weakSelf sendSms];
                }
            }];
        }
            break;
            
        case DXSmsCheckTypeBindPhone: // 绑定手机号
        {
            [self sendBindPhoneSms];
        }
            break;
            
        case DXSmsCheckTypeForgetPassword: // 忘记密码，需要找回密码
        {
            // 验证手机号是否可用 - 找回密码的情况需要用户已经注册了，才可以获取验证码
            [[DXDongXiApi api] isMobile:self.phoneF.text valid:^(BOOL valid, NSError *error) {
                if (valid == YES) {
                    weakSelf.getSmsKeyView.userInteractionEnabled = YES;
                    weakSelf.warnL.text = @"该号码还未注册";
                    weakSelf.warnL.hidden = NO;
                    [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
                } else {
                    // 发送重置密码的短信验证码
                    [weakSelf sendResetSms];
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

// 发送注册短信验证码
- (void)sendSms {
    
    DXUserSms *userSms = [DXUserSms newUserSmsWithMobile:self.phoneF.text];
    
    [[DXDongXiApi api] sendSms:userSms result:^(BOOL success, NSError *error) {
        
        weakSelf.getSmsKeyView.userInteractionEnabled = YES;
        
        if (success) {
            [weakSelf.getSmsKeyView startCountDown];
        }
    }];
}

// 发送绑定手机号短信验证码
- (void)sendBindPhoneSms {
    
    DXUserSms *userSms = [DXUserSms newUserSmsWithMobile:self.phoneF.text];
    [[DXDongXiApi api] sendWechatSms:userSms result:^(BOOL success, NSError *error) {
        weakSelf.getSmsKeyView.userInteractionEnabled = YES;
        if (success) {
            [weakSelf.getSmsKeyView startCountDown];
        }
    }];
}

// 发送重置密码短信验证码
- (void)sendResetSms {
    
    DXUserSms *userSms = [DXUserSms newUserSmsWithMobile:self.phoneF.text];
    
    [[DXDongXiApi api] sendResetPasswordSms:userSms result:^(DXUserResetPassSmsStatus status, NSString *nick, NSString *uid, NSError *error) {
       
        weakSelf.getSmsKeyView.userInteractionEnabled = YES;
        
        if (status == DXUserResetPassSmsSended) {
            weakSelf.userID = uid;
            [weakSelf.getSmsKeyView startCountDown];
        }
    }];
}

#pragma mark - 点击按钮执行的方法

// 点击返回按钮
- (void)clickbackBtn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 点击提交按钮
- (void)clickCommitBtn {
    
    if (self.phoneF.isFirstResponder) {
        [self.phoneF resignFirstResponder];
    } else if (self.smsCheckF.isFirstResponder) {
        [self.smsCheckF resignFirstResponder];
    }
    
    if (self.phoneF.text.length != 11) {
        self.warnL.text = @"请输入正确的手机号";
        self.warnL.hidden = NO;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    }
    
    if (self.smsCheckF.text.length == 0) {
        self.warnL.text = @"请输入验证码";
        self.warnL.hidden = NO;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    }
    
    switch (self.smsCheckType) {
        case DXSmsCheckTypeRegisterPhone:
            [self commitRegisterUserSms];
            break;
        case DXSmsCheckTypeBindPhone:
            [self wechatLoginByRequestForUserInfo];
            break;
        case DXSmsCheckTypeForgetPassword:
            [self commitResetPasswordSms];
            break;
            
        default:
            break;
    }
}


#pragma mark - 提交注册用户的验证码
- (void)commitRegisterUserSms {
    
    DXUserSmsCheck *userSmsCheck = [[DXUserSmsCheck alloc] init];
    userSmsCheck.mobile = self.phoneF.text;
    userSmsCheck.code = self.smsCheckF.text;
    
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateLoading];
    // 设置整个页面不可点击
    self.view.userInteractionEnabled = NO;
    
    [[DXDongXiApi api] checkSms:userSmsCheck result:^(BOOL valid, NSError *error) {
        
        if (valid) {
            
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 设置页面可点击
                weakSelf.view.userInteractionEnabled = YES;
                // 跳转到设置密码页
                DXPhonePasswordViewController *vc = [[DXPhonePasswordViewController alloc] init];
                vc.mobile = weakSelf.phoneF.text;
                vc.forgetPassword = NO;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            });
            
        } else {
            // 设置页面可点击
            weakSelf.view.userInteractionEnabled = YES;
            
            weakSelf.warnL.text = @"验证失败，请重试";
            weakSelf.warnL.hidden = NO;
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.warnL.hidden = YES;
                [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
            });
        }
    }];
}

#pragma mark - 提交重置密码的验证码
- (void)commitResetPasswordSms {
    
    if (!self.userID) {
        self.warnL.text = @"请输入正确的验证码";
        self.warnL.hidden = NO;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    }
    
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateLoading];
    // 设置整个页面不可点击
    self.view.userInteractionEnabled = NO;
    
    [[DXDongXiApi api] checkResetPasswordSmsCode:self.smsCheckF.text forUser:self.userID result:^(BOOL valid, NSError *error) {
        if (valid) {
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 设置页面可点击
                weakSelf.view.userInteractionEnabled = YES;
                // 跳转到设置密码页
                DXPhonePasswordViewController *vc = [[DXPhonePasswordViewController alloc] init];
                vc.mobile = weakSelf.phoneF.text;
                vc.userID = weakSelf.userID;
                vc.smsCode = weakSelf.smsCheckF.text;
                vc.forgetPassword = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            });
        } else {
            // 设置页面可点击
            weakSelf.view.userInteractionEnabled = YES;
            
            weakSelf.warnL.text = @"验证失败，请重试";
            weakSelf.warnL.hidden = NO;
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.warnL.hidden = YES;
                [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
            });
        }
    }];
}

#pragma mark - 提交注册微信的相关信息及用户信息
/**
 *  向微信请求用户信息
 */
- (void)wechatLoginByRequestForUserInfo {
    
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateLoading];
    // 设置整个页面不可点击
    self.view.userInteractionEnabled = NO;
    
    DXWechatLoginInfo *loginInfo = [[WXApiManager sharedManager] wechatLoginInfo];
    [[WXApiManager sharedManager] getUserInfoWithAccessToken:loginInfo.access_token openID:loginInfo.open_id result:^(NSDictionary *responseData, NSError *error) {
        if (responseData) {
            DXWechatRegisterInfo *registerInfo = [[DXWechatRegisterInfo alloc] init];
            registerInfo.open_id = [responseData objectForKey:@"openid"];
            registerInfo.nick_name = [responseData objectForKey:@"nickname"];
            registerInfo.gender = [[responseData objectForKey:@"sex"] intValue];
            registerInfo.province = [responseData objectForKey:@"province"];
            registerInfo.city = [responseData objectForKey:@"city"];
            registerInfo.country = [responseData objectForKey:@"country"];
            registerInfo.avatar = [responseData objectForKey:@"headimgurl"];
            registerInfo.privilege = [responseData objectForKey:@"privilege"];
            registerInfo.unionid = [responseData objectForKey:@"unionid"];
            [weakSelf registerWechatAndBindPhoneWithWechatRegisterInfo:registerInfo];
        } else {
            // 设置页面可点击
            weakSelf.view.userInteractionEnabled = YES;
            weakSelf.warnL.text = @"绑定失败，请重试";
            weakSelf.warnL.hidden = NO;
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.warnL.hidden = YES;
                [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
            });
        }
    }];
}
/**
 *  提交注册微信的相关信息及用户信息
 */
- (void)registerWechatAndBindPhoneWithWechatRegisterInfo:(DXWechatRegisterInfo *)registerInfo {
    DXWechatLoginInfo *loginInfo = [[WXApiManager sharedManager] wechatLoginInfo];
    registerInfo.mobile = self.phoneF.text;
    registerInfo.code = self.smsCheckF.text;
    registerInfo.access_token = loginInfo.access_token;
    registerInfo.refresh_token = loginInfo.refresh_token;
    registerInfo.expires_in = loginInfo.expires_in;
    registerInfo.scope = loginInfo.scope;
    registerInfo.push_id = [JPUSHService registrationID];
    [[DXDongXiApi api] registerWechatUser:registerInfo result:^(DXWechatRegisterStatus registerStatus, DXUserSession *session, NSError *error) {
        if (registerStatus == DXWechatRegisterStatusSuccess) {
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 设置页面可点击
                weakSelf.view.userInteractionEnabled = YES;
                [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            // 设置页面可点击
            weakSelf.view.userInteractionEnabled = YES;
            if (registerStatus == DXWechatRegisterStatusMobileHasBinded) {
                weakSelf.warnL.text = @"该手机号已被绑定";
            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请重试";
                weakSelf.warnL.text = [NSString stringWithFormat:@"绑定失败，%@", reason];
            }
            weakSelf.warnL.hidden = NO;
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.warnL.hidden = YES;
                [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
            });
        }
    }];
}

#pragma mark - 返回NSMutableAttributedString方法
- (NSMutableAttributedString *)attributedWithString:(NSString *)string color:(UIColor *)color {
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attStr addAttributes:@{
                            NSFontAttributeName: [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)],
                            NSForegroundColorAttributeName: color
                            } range:NSMakeRange(0, string.length)];
    return attStr;
}

@end
