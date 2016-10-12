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

@end

@implementation DXPhonePasswordViewController

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
    
    [self.passwordF becomeFirstResponder];
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
    passwordF.attributedPlaceholder = [self attributedWithString:@"请设置密码" color:DXRGBColor(177, 177, 177)];
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
    confirmF.attributedPlaceholder = [self attributedWithString:@"请确认密码" color:DXRGBColor(177, 177, 177)];
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
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    } else if (self.confirmF.text.length == 0) {
        self.warnL.text = @"请输入确认密码";
        self.warnL.hidden = NO;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    } else if (![self.passwordF.text isEqualToString:self.confirmF.text]) {
        self.warnL.text = @"您输入的密码和确认密码不相同";
        self.warnL.hidden = NO;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    }
    
    if (self.forgetPassword) {
        [self resetPassword];
    } else {
        // 注册一个新用户
        [self registerUser];
    }
}

// 注册一个新用户
- (void)registerUser {
    
    DXUserRegisterInfo *userRegisterInfo = [[DXUserRegisterInfo alloc] init];
    userRegisterInfo.mobile = self.mobile;
    userRegisterInfo.password = self.confirmF.text;
    
    [[DXDongXiApi api] registerUser:userRegisterInfo result:^(BOOL success, NSError *error) {
        
        if (success) {[self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 跳转到登陆页
                DXPhoneLoginViewController *vc = [[DXPhoneLoginViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            });
            
        } else {
            
            self.warnL.text = @"注册失败，请重试";
            self.warnL.hidden = NO;
            [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.warnL.hidden = YES;
                [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
            });
        }
    }];
}

- (void)resetPassword {
    
    DXLog(@"重置密码");
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
