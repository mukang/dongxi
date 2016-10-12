//
//  DXPhonePasswordViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/13.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPhonePasswordViewController.h"
#import "DXUser.h"
#import "DXAnimationButtonCover.h"
#import "DXPhoneLoginViewController.h"
#import "DXDongXiApi.h"
#import "DXLoginEaseMob.h"
#import "JPUSHService.h"
#import <YYText.h>
#import "DXUserAgreementViewController.h"
#import "DXPrivacyPolicyViewController.h"
#import "DXRegisterUserInfoViewController.h"

@interface DXPhonePasswordViewController () <UITextFieldDelegate>

/** 密码图片 */
@property (nonatomic, weak) UIImageView *passwordImageV;
/** 密码下划线 */
@property (nonatomic, weak) UIView *passwordUnderLine;
/** 确认密码输入框 */
@property (nonatomic, weak) UITextField *passwordF;
/** 确认密码下划线 */
@property (nonatomic, weak) UIView *confirmUnderLine;
/** 确认密码输入框 */
@property (nonatomic, weak) UITextField *confirmF;
/** 提交按钮 */
@property (nonatomic, weak) UIButton *commitBtn;
/** 按钮的动画遮盖 */
@property (nonatomic, weak) DXAnimationButtonCover *cover;
/** 错误提示 */
@property (nonatomic, weak) UILabel *warnL;
/** 服务协议和隐私声明 */
@property (nonatomic, weak) YYLabel *noticeLabel;

@end

@implementation DXPhonePasswordViewController {
    __weak DXPhonePasswordViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    if (self.forgetPassword) {
        self.dt_pageName = DXDataTrackingPage_RecoverPassword;
    } else {
        self.dt_pageName = DXDataTrackingPage_RegisterPassword;
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
    
    [self.passwordF becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self.passwordF isFirstResponder]) {
        [self.passwordF resignFirstResponder];
    }
    if ([self.confirmF isFirstResponder]) {
        [self.confirmF resignFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 将提交按钮变为正常状态
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
}

- (void)setupTitleView {
    
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"button_back_login"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickbackBtn) forControlEvents:UIControlEventTouchUpInside];
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(DXRealValue(21), DXRealValue(12), DXRealValue(21), DXRealValue(12));
    backBtn.frame = CGRectMake(DXRealValue(55), DXRealValue(84), DXRealValue(36), DXRealValue(63));
    [self.view addSubview:backBtn];
    
    // title
    UILabel *titleL = [[UILabel alloc] init];
    if (self.isForgetPassword) {
        titleL.text = @"重置密码";
    } else {
        titleL.text = @"注册新用户";
    }
    titleL.textColor = DXRGBColor(72, 72, 72);
    titleL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(24)];
    [titleL sizeToFit];
    titleL.center = CGPointMake(DXScreenWidth * 0.5, backBtn.centerY);
    [self.view addSubview:titleL];
}

- (void)setupContentView {
    
    // 密码图片
    UIImageView *passwordImageV = [[UIImageView alloc] init];
    passwordImageV.image = [UIImage imageNamed:@"icon_key_black"];
    passwordImageV.highlightedImage = [UIImage imageNamed:@"icon_key_grew"];
    passwordImageV.frame = CGRectMake(DXRealValue(84), DXRealValue(211), DXRealValue(17), DXRealValue(17));
    [self.view addSubview:passwordImageV];
    self.passwordImageV = passwordImageV;
    
    // 下划线
    UIView *passwordUnderLine = [[UIView alloc] init];
    passwordUnderLine.size = CGSizeMake(DXRealValue(280), 0.5);
    passwordUnderLine.center = CGPointMake(DXScreenWidth * 0.5, CGRectGetMaxY(passwordImageV.frame) + DXRealValue(12));
    passwordUnderLine.backgroundColor = DXRGBColor(72, 72, 72);
    [self.view addSubview:passwordUnderLine];
    self.passwordUnderLine = passwordUnderLine;
    
    // 输入框
    UITextField *passwordF = [[UITextField alloc] init];
    CGFloat passwordFW = CGRectGetMaxX(passwordUnderLine.frame) - CGRectGetMaxX(passwordImageV.frame) - DXRealValue(4);
    CGFloat passwordFH = 30;
    passwordF.size = CGSizeMake(passwordFW, passwordFH);
    passwordF.centerY = passwordImageV.centerY;
    passwordF.x = CGRectGetMaxX(passwordImageV.frame) + DXRealValue(4);
    passwordF.attributedPlaceholder = [self attributedWithString:@"请设置密码" color:DXRGBColor(143, 143, 143)];
    passwordF.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    passwordF.textColor = DXRGBColor(72, 72, 72);
    passwordF.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordF.secureTextEntry = YES;
    passwordF.delegate = self;
    [self.view addSubview:passwordF];
    self.passwordF = passwordF;
    
    // 确认密码下划线
    UIView *confirmUnderLine = [[UIView alloc] init];
    confirmUnderLine.size = passwordUnderLine.size;
    confirmUnderLine.x = passwordUnderLine.x;
    confirmUnderLine.y = CGRectGetMaxY(passwordUnderLine.frame) + DXRealValue(59) + DXRealValue(17);
    confirmUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
    [self.view addSubview:confirmUnderLine];
    self.confirmUnderLine = confirmUnderLine;
    
    // 确认密码输入框
    UITextField *confirmF = [[UITextField alloc] init];
    confirmF.size = passwordF.size;
    confirmF.x = passwordF.x;
    CGFloat margin = passwordUnderLine.y - passwordF.y;
    confirmF.y = confirmUnderLine.y - margin;
    confirmF.attributedPlaceholder = [self attributedWithString:@"请确认密码" color:DXRGBColor(143, 143, 143)];
    confirmF.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    confirmF.textColor = DXRGBColor(72, 72, 72);
    confirmF.clearButtonMode = UITextFieldViewModeWhileEditing;
    confirmF.secureTextEntry = YES;
    confirmF.delegate = self;
    [self.view addSubview:confirmF];
    self.confirmF = confirmF;
    
    // 提交
    UIButton *commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commitBtn.size = CGSizeMake(DXRealValue(280), DXRealValue(44));
    commitBtn.centerX = DXScreenWidth * 0.5;
    commitBtn.y = confirmUnderLine.y + DXRealValue(80);
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
    if (!self.isForgetPassword) {
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
    
    CGFloat loginBtnMaxY = CGRectGetMaxY(self.commitBtn.frame) + DXRealValue(50);
    
    if (loginBtnMaxY <= keyboardY) return;
    
    [UIView animateWithDuration:duration animations:^{
        self.view.y = keyboardY - loginBtnMaxY;
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
    
    if (textField == self.passwordF) {
        self.passwordImageV.highlighted = NO;
        self.passwordUnderLine.backgroundColor = DXRGBColor(72, 72, 72);
        self.confirmUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
    } else {
        self.passwordImageV.highlighted = YES;
        self.passwordUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
        self.confirmUnderLine.backgroundColor = DXRGBColor(72, 72, 72);
    }
    
    if (self.warnL.hidden == NO) {
        self.warnL.hidden = YES;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    self.passwordImageV.highlighted = YES;
    self.passwordUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
    self.confirmUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.isFirstResponder) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.passwordF.isFirstResponder) {
        [self.passwordF resignFirstResponder];
    } else if (self.confirmF.isFirstResponder) {
        [self.confirmF resignFirstResponder];
    }
}

#pragma mark - 点击按钮

// 点击返回按钮
- (void)clickbackBtn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 点击提交按钮
- (void)clickCommitBtn {
    
    if (self.passwordF.isFirstResponder) {
        [self.passwordF resignFirstResponder];
    } else if (self.confirmF.isFirstResponder) {
        [self.confirmF resignFirstResponder];
    }
    
    if (self.passwordF.text.length == 0) {
        self.warnL.text = @"请输入密码";
        self.warnL.hidden = NO;
        self.passwordUnderLine.backgroundColor = DXRGBColor(255, 109, 119);
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    } else if (self.confirmF.text.length == 0) {
        self.warnL.text = @"请输入确认密码";
        self.warnL.hidden = NO;
        self.confirmUnderLine.backgroundColor = DXRGBColor(255, 109, 119);
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    } else if (![self.passwordF.text isEqualToString:self.confirmF.text]) {
        self.warnL.text = @"您输入的密码和确认密码不相同";
        self.warnL.hidden = NO;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    }
    
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateLoading];
    // 设置整个页面不可点击
    self.view.userInteractionEnabled = NO;
    
    if (self.forgetPassword) {
        [self resetPassword];
    } else {
        // 注册一个新用户
        [self registerUser];
    }
}

#pragma mark - 注册一个新用户

- (void)registerUser {
    
    DXUserRegisterInfo *userRegisterInfo = [[DXUserRegisterInfo alloc] init];
    userRegisterInfo.mobile = self.mobile;
    userRegisterInfo.password = self.confirmF.text;
    userRegisterInfo.push_id = [JPUSHService registrationID];
    
    [[DXDongXiApi api] registerUser:userRegisterInfo result:^(BOOL success, NSError *error) {
        
        if (success) {
            
            [weakSelf autoLogin];
            
        } else {
            
            // 设置页面可以点击
            weakSelf.view.userInteractionEnabled = YES;
            
            weakSelf.warnL.text = @"注册失败，请重试";
            weakSelf.warnL.hidden = NO;
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.warnL.hidden = YES;
                [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
            });
        }
    }];
}

// 自动登陆

- (void)autoLogin {
    
    DXUserLoginInfo *userLoginInfo = [[DXUserLoginInfo alloc] init];
    [userLoginInfo setAccountInfoWithMobile:self.mobile andPassword:self.passwordF.text];
    [userLoginInfo setPushID:[JPUSHService registrationID]];
    
    [[DXDongXiApi api] login:userLoginInfo isNewRegistered:YES result:^(DXUserSession *user, NSError *error) {
        if (user) {
            
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                // 设置页面可以点击
                weakSelf.view.userInteractionEnabled = YES;
                
                // 跳转到设置昵称和性别页
                DXRegisterUserInfoViewController *vc = [[DXRegisterUserInfoViewController alloc] init];
                vc.isNewRegistered = YES;
                [self.navigationController pushViewController:vc animated:YES];
            });
            
        } else {
            
            // 设置页面可以点击
            weakSelf.view.userInteractionEnabled = YES;
            
            self.warnL.text = @"登陆失败，请重试";
            self.warnL.hidden = NO;
            [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.warnL.hidden = YES;
                [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
            });
        }
    }];
}

#pragma mark - 重置密码

- (void)resetPassword {
    
    DXUserPasswordResetInfo *info = [[DXUserPasswordResetInfo alloc] init];
    info.uid = self.userID;
    info.code = self.smsCode;
    info.newpassword = self.confirmF.text;
    
    [[DXDongXiApi api] resetPasswordWithInfo:info result:^(DXUserResetPasswordStatus status, NSError *error) {
        
        switch (status) {
            case DXUserResetPasswordOK:
                [weakSelf resetPasswordOK];
                break;
            case DXUserResetPasswordFailed:
                [weakSelf resetPasswordFailed];
                break;
            case DXUserResetPasswordWrongCode:
                [weakSelf resetPasswordWrongCode];
                break;
                
            default:
                break;
        }
    }];
}

- (void)resetPasswordOK {
    
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 设置页面可以点击
        weakSelf.view.userInteractionEnabled = YES;
        
        DXPhoneLoginViewController *vc = [[DXPhoneLoginViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    });
}

- (void)resetPasswordFailed {
    
    // 设置页面可以点击
    self.view.userInteractionEnabled = YES;
    
    self.warnL.text = @"重置密码失败，请重试";
    self.warnL.hidden = NO;
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.warnL.hidden = YES;
        [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
    });
}

- (void)resetPasswordWrongCode {
    
    // 设置页面可以点击
    self.view.userInteractionEnabled = YES;
    
    self.warnL.text = @"验证码错误，请返回重新申请验证码";
    self.warnL.hidden = NO;
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.warnL.hidden = YES;
        [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
    });
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
