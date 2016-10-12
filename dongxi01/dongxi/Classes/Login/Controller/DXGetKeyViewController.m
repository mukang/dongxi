//
//  DXGetKeyViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXGetKeyViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "DXButton.h"
#import "DXHadKeyViewController.h"
#import "DXSuccessViewController.h"
#import "DXAnimationButtonCover.h"

@interface DXGetKeyViewController () <UITextFieldDelegate>

/** 手机下划线 */
@property (nonatomic, weak) UIView *phoneUnderLine;
/** 手机号： */
@property (nonatomic, weak) UILabel *phoneL;
/** 手机输入框 */
@property (nonatomic, weak) UITextField *phoneF;
/** 按钮的动画遮盖 */
@property (nonatomic, weak) DXAnimationButtonCover *cover;
/** 错误提示 */
@property (nonatomic, weak) UILabel *warnL;

@end

@implementation DXGetKeyViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置导航栏
    [self setupTitleView];
    
    // 设置内容
    [self setupContent];
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
    titleL.text = @"申请邀请码";
    titleL.textColor = DXRGBColor(72, 72, 72);
    titleL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(24)];
    [titleL sizeToFit];
    titleL.center = CGPointMake(DXScreenWidth * 0.5, backBtn.centerY);
    [self.view addSubview:titleL];
}

/**
 *  设置内容
 */
- (void)setupContent {
    
    // 下划线
    UIView *phoneUnderLine = [[UIView alloc] init];
    phoneUnderLine.size = CGSizeMake(DXRealValue(280.0f), 0.5f);
    phoneUnderLine.center = CGPointMake(DXScreenWidth * 0.5f, DXRealValue(281.0f));
    phoneUnderLine.backgroundColor = DXRGBColor(72, 72, 72);
    [self.view addSubview:phoneUnderLine];
    self.phoneUnderLine = phoneUnderLine;
    
    // 手机号
    UILabel *phoneL = [[UILabel alloc] init];
    phoneL.text = @"手机号：";
    phoneL.textColor = DXRGBColor(143, 143, 143);
    phoneL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17.0f)];
    [phoneL sizeToFit];
    phoneL.y = phoneUnderLine.y - DXRealValue(5.0f) - phoneL.height;
    phoneL.x = phoneUnderLine.x;
    [self.view addSubview:phoneL];
    self.phoneL = phoneL;
    
    // 输入框
    UITextField *phoneF = [[UITextField alloc] init];
    CGFloat phoneFW = phoneUnderLine.width - phoneL.width;
    CGFloat phoneFH = DXRealValue(30.0f);
    phoneF.size = CGSizeMake(phoneFW, phoneFH);
    phoneF.centerY = phoneL.centerY;
    phoneF.x = CGRectGetMaxX(phoneL.frame);
    phoneF.attributedPlaceholder = [self attributedWithString:@"（我们不会骚扰你···）" color:DXRGBColor(143, 143, 143)];
    phoneF.textColor = DXRGBColor(72, 72, 72);
    phoneF.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17.0f)];
    phoneF.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneF.keyboardType = UIKeyboardTypeNumberPad;
    phoneF.delegate = self;
    [self.view addSubview:phoneF];
    self.phoneF = phoneF;
    
    // 申请按钮
    UIButton *applyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [applyBtn setImage:[UIImage imageNamed:@"button_apply_normal"] forState:UIControlStateNormal];
    [applyBtn setImage:[UIImage imageNamed:@"button_apply_click"] forState:UIControlStateHighlighted];
    [applyBtn addTarget:self action:@selector(applyBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    applyBtn.size = CGSizeMake(DXRealValue(280.0f), DXRealValue(44.0f));
    applyBtn.centerX = DXScreenWidth * 0.5f;
    applyBtn.y = DXRealValue(342.0f);
    [self.view addSubview:applyBtn];
    
    // 按钮的动画遮盖
    DXAnimationButtonCover *cover = [[DXAnimationButtonCover alloc] initWithFrame:applyBtn.frame];
    [self.view addSubview:cover];
    self.cover = cover;
    
    // 错误提示
    UILabel *warnL = [[UILabel alloc] init];
    warnL.textAlignment = NSTextAlignmentCenter;
    warnL.textColor = DXRGBColor(255, 109, 119);
    warnL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(12)];
    warnL.size = CGSizeMake(applyBtn.width, 12);
    warnL.centerX = applyBtn.centerX;
    warnL.y = applyBtn.y - 20;
    warnL.hidden = YES;
    [self.view addSubview:warnL];
    self.warnL = warnL;
}

#pragma mark - <UITextFieldDelegate>
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.phoneF) {
        self.phoneL.textColor = DXRGBColor(72, 72, 72);
        self.phoneUnderLine.backgroundColor = DXRGBColor(72, 72, 72);
    }
    
    if (self.warnL.hidden == NO) {
        self.warnL.hidden = YES;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.phoneF) {
        self.phoneL.textColor = DXRGBColor(143, 143, 143);
        self.phoneUnderLine.backgroundColor = DXRGBColor(177, 177, 177);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([self.phoneF isFirstResponder]) {
        [self.phoneF resignFirstResponder];
    }
}

#pragma mark - 点击按钮执行的方法

/**
 *  点击返回按钮
 */
- (void)clickbackBtn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  点击申请按钮
 */
- (void)applyBtnDidClick {
    
    // 收回键盘
    if ([self.phoneF isFirstResponder]) {
        [self.phoneF resignFirstResponder];
    }
    
    // 检查手机号是否为11位
    if (self.phoneF.text.length != 11) {
        self.warnL.text = @"请输入正确的手机号码";
        self.warnL.hidden = NO;
        self.phoneUnderLine.backgroundColor = DXRGBColor(255, 109, 119);
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        return;
    }
    
    // 设置不可交互
    self.view.userInteractionEnabled = NO;
    
    // 检查该手机号是否已注册，已注册的手机号不可申请邀请码
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateLoading];
    __weak typeof(self) weakSelf = self;
    [[DXDongXiApi api] isMobile:self.phoneF.text valid:^(BOOL valid, NSError *error) {
        if (valid == NO) { // 已注册
            
            // 设置可交互
            weakSelf.view.userInteractionEnabled = YES;
            
            weakSelf.warnL.text = @"该号码已注册";
            weakSelf.warnL.hidden = NO;
            weakSelf.phoneUnderLine.backgroundColor = DXRGBColor(255, 109, 119);
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
        } else {
            [weakSelf apply];
        }
    }];
}

- (void)apply {
    
    __weak typeof(self) weakSelf = self;
    [[DXDongXiApi api] getUserCouponWithMobile:self.phoneF.text result:^(BOOL success, NSError *error) {
        if (success) {
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                // 设置可交互
                weakSelf.view.userInteractionEnabled = YES;
                
                // 跳转到申请成功页面
                DXSuccessViewController *successVC = [[DXSuccessViewController alloc] init];
                [weakSelf.navigationController pushViewController:successVC animated:YES];
            });
        } else {
            
            // 设置可交互
            weakSelf.view.userInteractionEnabled = YES;
            
            weakSelf.warnL.text = @"申请失败，请重试";
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
                            NSFontAttributeName: [UIFont fontWithName:DXCommonFontName size:DXRealValue(17.0f)],
                            NSForegroundColorAttributeName: color
                            } range:NSMakeRange(0, string.length)];
    return attStr;
}

@end
