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

@interface DXSmsCheckViewController () <UITextFieldDelegate>

/** 手机图片 */
@property (nonatomic, weak) UIImageView *phoneImageV;
/** 手机下划线 */
@property (nonatomic, weak) UIView *phoneUnderLine;
/** 手机输入框 */
@property (nonatomic, weak) UITextField *phoneF;
/** 验证码下划线 */
@property (nonatomic, weak) UIView *smsCheckUnderLine;
/** 获取验证码按钮 */
@property (nonatomic, weak) UIButton *smsCheckBtn;
/** 验证码入框 */
@property (nonatomic, weak) UITextField *smsCheckF;
/** 提交按钮 */
@property (nonatomic, weak) UIButton *commitBtn;
/** 按钮的动画遮盖 */
@property (nonatomic, weak) DXAnimationButtonCover *cover;
/** 错误提示 */
@property (nonatomic, weak) UILabel *warnL;


@end

@implementation DXSmsCheckViewController

#pragma mark - 初始化方法

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTitleView {
    
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"button_back_login"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickbackBtn) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(DXRealValue(55), DXRealValue(84), 36, 63);
    [self.view addSubview:backBtn];
    
    // title
    UILabel *titleL = [[UILabel alloc] init];
    if (self.isForgetPassword) {
        titleL.text = @"找回密码";
    } else {
        titleL.text = @"注册新用户";
    }
    titleL.textColor = DXRGBColor(72, 72, 72);
    titleL.font = [UIFont fontWithName:DXCommonFontName size:24];
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
    phoneF.attributedPlaceholder = [self attributedWithString:@"请输入手机号" color:DXRGBColor(177, 177, 177)];
    phoneF.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    phoneF.textColor = DXRGBColor(177, 177, 177);
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
    
    // 验证码按钮
    UIButton *smsCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [smsCheckBtn setImage:[UIImage imageNamed:@"button_getkey"] forState:UIControlStateNormal];
    smsCheckBtn.size = CGSizeMake(80, 26);
    smsCheckBtn.x = CGRectGetMaxX(smsCheckUnderLine.frame) - smsCheckBtn.width;
    smsCheckBtn.y = CGRectGetMaxY(smsCheckUnderLine.frame) - smsCheckBtn.height - DXRealValue(7);
    [smsCheckBtn addTarget:self action:@selector(clickSmsCheckBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:smsCheckBtn];
    self.smsCheckBtn = smsCheckBtn;
    
    // 验证码输入框
    UITextField *smsCheckF = [[UITextField alloc] init];
    smsCheckF.width = smsCheckBtn.x - phoneF.x;
    smsCheckF.height = phoneF.height;
    smsCheckF.x = phoneF.x;
    smsCheckF.centerY = smsCheckBtn.centerY;
    smsCheckF.attributedPlaceholder = [self attributedWithString:@"请输入验证码" color:DXRGBColor(177, 177, 177)];
    smsCheckF.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    smsCheckF.textColor = DXRGBColor(177, 177, 177);
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
    
    CGFloat loginBtnMaxY = CGRectGetMaxY(self.commitBtn.frame);
    
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
    } else {
        self.phoneImageV.highlighted = YES;
    }
    
    if (self.warnL.hidden == NO) {
        self.warnL.hidden = YES;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
    }
}

//- (void)textFieldDidEndEditing:(UITextField *)textField {
//
//    if (textField.text.length == 0) return;
//
//    if (textField == self.phoneF && textField.text.length != 11) {
//        DXLog(@"请输入正确手机号");
//    }
//}

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

#pragma mark - 点击按钮执行的方法

// 点击返回按钮
- (void)clickbackBtn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 点击获取验证码按钮
- (void)clickSmsCheckBtn {
    
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
    
    if (self.forgetPassword) {
        
        // 如果是忘记密码，就不需要检测手机号
        DXLog(@"发送重置手机密码的验证码");
        
    } else {
        
        // 验证手机号是否已被使用
        [[DXDongXiApi api] isMobile:self.phoneF.text valid:^(BOOL valid, NSError *error) {
            DXLog(@"%@", error);
            
            if (valid == NO) {
                self.warnL.text = @"该号码不可用，或已注册";
                self.warnL.hidden = NO;
                [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
                return;
            }
            
            // 发送短信验证码
            [self sendSms];
        }];
    }
}

// 发送注册短信验证码
- (void)sendSms {
    
    DXUserSms *userSms = [[DXUserSms alloc] init];
    userSms.mobile = self.phoneF.text;
    
    [[DXDongXiApi api] sendSms:userSms result:^(BOOL success, NSError *error) {
        
        if (success) {
            
            DXLog(@"短信验证码发送成功");
        }
    }];
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
    
    // 验证手机注册短信验证码
    [self commit];
}


#pragma mark - 验证手机注册短信验证码
- (void)commit {
    
    DXUserSmsCheck *userSmsCheck = [[DXUserSmsCheck alloc] init];
    userSmsCheck.mobile = self.phoneF.text;
    userSmsCheck.code = self.smsCheckF.text;
    
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateLoading];
    
    [[DXDongXiApi api] checkSms:userSmsCheck result:^(BOOL valid, NSError *error) {
        
        if (valid) {
            
            [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 跳转到设置密码页
                DXPhonePasswordViewController *vc = [[DXPhonePasswordViewController alloc] init];
                vc.mobile = self.phoneF.text;
                vc.forgetPassword = self.forgetPassword;
                [self.navigationController pushViewController:vc animated:YES];
            });
            
        } else {
            
            self.warnL.text = @"验证失败，请重试";
            self.warnL.hidden = NO;
            [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.warnL.hidden = YES;
                [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
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
