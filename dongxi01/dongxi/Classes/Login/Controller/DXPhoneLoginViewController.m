//
//  DXPhoneLoginViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPhoneLoginViewController.h"
#import "DXSmsCheckViewController.h"
#import "DXAnimationButtonCover.h"
#import "DXDongXiApi.h"
#import "DXLoginEaseMob.h"
#import "JPUSHService.h"

@interface DXPhoneLoginViewController () <UITextFieldDelegate>

/** 手机图片 */
@property (nonatomic, weak) UIImageView *phoneImageV;
/** 手机下划线 */
@property (nonatomic, weak) UIView *phoneUnderLine;
/** 手机输入框 */
@property (nonatomic, weak) UITextField *phoneF;
/** 密码图片 */
@property (nonatomic, weak) UIImageView *passwordImageV;
/** 密码下划线 */
@property (nonatomic, weak) UIView *passwordUnderLine;
/** 密码输入框 */
@property (nonatomic, weak) UITextField *passwordF;
/** 登陆按钮 */
@property (nonatomic, weak) UIButton *loginBtn;
/** 按钮的动画遮盖 */
@property (nonatomic, weak) DXAnimationButtonCover *cover;
/** 错误提示 */
@property (nonatomic, weak) UILabel *warnL;

@end

@implementation DXPhoneLoginViewController

#pragma mark - 初始化方法

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_LoginByPhone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTitleView];
    
    [self setupContentView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
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
    if ([self.passwordF isFirstResponder]) {
        [self.passwordF resignFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    titleL.text = @"手机号登陆";
    titleL.textColor = DXRGBColor(72, 72, 72);
    titleL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(24)];
    [titleL sizeToFit];
    titleL.center = CGPointMake(DXScreenWidth * 0.5, backBtn.centerY);
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
    phoneUnderLine.center = CGPointMake(DXScreenWidth * 0.5, CGRectGetMaxY(phoneImageV.frame) + DXRealValue(12));
    phoneUnderLine.backgroundColor = DXRGBColor(72, 72, 72);
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
    phoneF.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneF.keyboardType = UIKeyboardTypeNumberPad;
    phoneF.delegate = self;
    [self.view addSubview:phoneF];
    self.phoneF = phoneF;
    
    // 密码图片
    UIImageView *passwordImageV = [[UIImageView alloc] init];
    passwordImageV.image = [UIImage imageNamed:@"icon_key_black"];
    passwordImageV.highlightedImage = [UIImage imageNamed:@"icon_key_grew"];
    passwordImageV.highlighted = YES;
    passwordImageV.size = CGSizeMake(DXRealValue(17), DXRealValue(17));
    passwordImageV.x = phoneImageV.x;
    passwordImageV.y = CGRectGetMaxY(phoneImageV.frame) + DXRealValue(59);
    [self.view addSubview:passwordImageV];
    self.passwordImageV = passwordImageV;
    
    // 下划线
    UIView *passwordUnderLine = [[UIView alloc] init];
    passwordUnderLine.size = phoneUnderLine.size;
    passwordUnderLine.x = phoneUnderLine.x;
    passwordUnderLine.y = CGRectGetMaxY(passwordImageV.frame) + DXRealValue(12);
    passwordUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
    [self.view addSubview:passwordUnderLine];
    self.passwordUnderLine = passwordUnderLine;
    
    // 密码输入框
    UITextField *passwordF = [[UITextField alloc] init];
    passwordF.size = phoneF.size;
    passwordF.x = phoneF.x;
    passwordF.centerY = passwordImageV.centerY;
    passwordF.attributedPlaceholder = [self attributedWithString:@"请输入密码" color:DXRGBColor(143, 143, 143)];
    passwordF.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    passwordF.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordF.returnKeyType = UIReturnKeyDone;
    passwordF.secureTextEntry = YES;
    passwordF.delegate = self;
    [self.view addSubview:passwordF];
    self.passwordF = passwordF;
    
    // 忘记密码
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetBtn.size = CGSizeMake(DXRealValue(55), DXRealValue(16));
    forgetBtn.y = CGRectGetMaxY(passwordUnderLine.frame) + DXRealValue(22);
    forgetBtn.x = CGRectGetMaxX(passwordUnderLine.frame) - forgetBtn.width;
    [forgetBtn setImage:[UIImage imageNamed:@"button_forgot_key"] forState:UIControlStateNormal];
    [forgetBtn addTarget:self action:@selector(clickForgetBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetBtn];
    
    // 登陆
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.size = CGSizeMake(DXRealValue(280), DXRealValue(44));
    loginBtn.centerX = DXScreenWidth * 0.5;
    loginBtn.y = passwordUnderLine.y + DXRealValue(80);
    [loginBtn setImage:[UIImage imageNamed:@"button_login_blue_normal"] forState:UIControlStateNormal];
    [loginBtn setImage:[UIImage imageNamed:@"button_login_blue_click"] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(clickloginBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    self.loginBtn = loginBtn;
    
    // 按钮的动画遮盖
    DXAnimationButtonCover *cover = [[DXAnimationButtonCover alloc] initWithFrame:loginBtn.frame];
    [self.view addSubview:cover];
    self.cover = cover;
    
    // 错误提示
    UILabel *warnL = [[UILabel alloc] init];
    warnL.textAlignment = NSTextAlignmentCenter;
    warnL.textColor = DXRGBColor(255, 109, 119);
    warnL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(12)];
    warnL.size = CGSizeMake(loginBtn.width, 12);
    warnL.centerX = loginBtn.centerX;
    warnL.y = loginBtn.y - 20;
    warnL.hidden = YES;
    [self.view addSubview:warnL];
    self.warnL = warnL;
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
    
    CGFloat loginBtnMaxY = CGRectGetMaxY(self.loginBtn.frame);
    
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
    
    if (textField == self.phoneF) {
        self.phoneImageV.highlighted = NO;
        self.phoneUnderLine.backgroundColor = DXRGBColor(72, 72, 72);
        self.passwordImageV.highlighted = YES;
        self.passwordUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
    } else {
        self.phoneImageV.highlighted = YES;
        self.phoneUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
        self.passwordImageV.highlighted = NO;
        self.passwordUnderLine.backgroundColor = DXRGBColor(72, 72, 72);
    }
    
    if (self.warnL.hidden == NO) {
        self.warnL.hidden = YES;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.phoneF) {
        self.phoneImageV.highlighted = YES;
        self.phoneUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
    } else {
        self.passwordImageV.highlighted = YES;
        self.passwordUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
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
    } else if (self.passwordF.isFirstResponder) {
        [self.passwordF resignFirstResponder];
    }
}

#pragma mark - 点击按钮执行的方法

// 点击返回按钮
- (void)clickbackBtn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 点击忘记密码按钮
- (void)clickForgetBtn {
    
    DXSmsCheckViewController *vc = [[DXSmsCheckViewController alloc] initWithSmsCheckType:DXSmsCheckTypeForgetPassword];
    [self.navigationController pushViewController:vc animated:YES];
}

// 点击登陆按钮
- (void)clickloginBtn {
    
    if (self.phoneF.isFirstResponder) {
        [self.phoneF resignFirstResponder];
    } else if (self.passwordF.isFirstResponder) {
        [self.passwordF resignFirstResponder];
    }
    
    if (self.phoneF.text.length != 11) {
        self.warnL.text = @"请输入正确的手机号";
        self.warnL.hidden = NO;
        self.phoneUnderLine.backgroundColor = DXRGBColor(255, 109, 119);
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
    } else if (self.passwordF.text.length == 0) {
        self.warnL.text = @"请输入密码";
        self.warnL.hidden = NO;
        self.passwordUnderLine.backgroundColor = DXRGBColor(255, 109, 119);
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
    } else {
        [self login];
    }
}


#pragma mark - 登陆
- (void)login {
    
    DXUserLoginInfo *userLoginInfo = [[DXUserLoginInfo alloc] init];
    [userLoginInfo setAccountInfoWithMobile:self.phoneF.text andPassword:self.passwordF.text];
    [userLoginInfo setPushID:[JPUSHService registrationID]];
    
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateLoading];
    // 设置整个页面不可点击
    self.view.userInteractionEnabled = NO;
    
    __weak typeof(self) weakSelf = self;
    [[DXDongXiApi api] login:userLoginInfo result:^(DXUserSession *user, NSError *error) {
        if (user) {
            
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 设置页面可点击
                weakSelf.view.userInteractionEnabled = YES;
                
                [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
            });
            
        } else {
            // 设置页面可点击
            weakSelf.view.userInteractionEnabled = YES;
            
            weakSelf.warnL.text = error.localizedDescription;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
