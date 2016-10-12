//
//  DXHadKeyViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXHadKeyViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "DXButton.h"
#import "DXGetKeyViewController.h"
#import "DXSuccessViewController.h"
#import "DXDongXiApi.h"
#import "DXAnimationButtonCover.h"
#import "DXSmsCheckViewController.h"

@interface DXHadKeyViewController () <UITextFieldDelegate>

/** 邀请码下划线 */
@property (nonatomic, weak) UIView *underLine;
/** 邀请码输入框 */
@property (nonatomic, weak) UITextField *keyF;
/** 完成按钮 */
@property (nonatomic, weak) UIButton *finishBtn;
/** 按钮的动画遮盖 */
@property (nonatomic, weak) DXAnimationButtonCover *cover;
/** 错误提示 */
@property (nonatomic, weak) UILabel *warnL;

@end

@implementation DXHadKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置标题视图
    [self setupTitleView];
    
    // 设置内容
    [self setupContent];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.keyF becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self.keyF isFirstResponder]) {
        [self.keyF resignFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
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
    titleL.text = @"输入邀请码";
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
    UIView *underLine = [[UIView alloc] init];
    underLine.size = CGSizeMake(DXRealValue(280.0f), 0.5f);
    underLine.center = CGPointMake(DXScreenWidth * 0.5f, DXRealValue(281.0f));
    underLine.backgroundColor = DXRGBColor(72, 72, 72);
    [self.view addSubview:underLine];
    self.underLine = underLine;
    
    // 输入框
    UITextField *keyF = [[UITextField alloc] init];
    CGFloat keyFH = DXRealValue(30.0f);
    keyF.frame = CGRectMake(underLine.x, underLine.y - keyFH, underLine.width, keyFH);
    keyF.attributedPlaceholder = [self attributedWithString:@"输入6位邀请码" color:DXRGBColor(143, 143, 143)];
    keyF.textColor = DXRGBColor(72, 72, 72);
    keyF.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17.0f)];
    keyF.textAlignment = NSTextAlignmentCenter;
    keyF.clearButtonMode = UITextFieldViewModeWhileEditing;
    keyF.delegate = self;
    [self.view addSubview:keyF];
    self.keyF = keyF;
    
    // 完成按钮
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishBtn setImage:[UIImage imageNamed:@"button_finish_normal"] forState:UIControlStateNormal];
    [finishBtn setImage:[UIImage imageNamed:@"button_finish_click"] forState:UIControlStateHighlighted];
    [finishBtn addTarget:self action:@selector(finishBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    finishBtn.size = CGSizeMake(DXRealValue(280.0f), DXRealValue(44.0f));
    finishBtn.centerX = DXScreenWidth * 0.5f;
    finishBtn.y = DXRealValue(342.0f);
    [self.view addSubview:finishBtn];
    self.finishBtn = finishBtn;
    
    // 按钮的动画遮盖
    DXAnimationButtonCover *cover = [[DXAnimationButtonCover alloc] initWithFrame:finishBtn.frame];
    [self.view addSubview:cover];
    self.cover = cover;
    
    // 错误提示
    UILabel *warnL = [[UILabel alloc] init];
    warnL.textAlignment = NSTextAlignmentCenter;
    warnL.textColor = DXRGBColor(255, 109, 119);
    warnL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(12)];
    warnL.size = CGSizeMake(finishBtn.width, 12);
    warnL.centerX = finishBtn.centerX;
    warnL.y = finishBtn.y - 20;
    warnL.hidden = YES;
    [self.view addSubview:warnL];
    self.warnL = warnL;
}


#pragma mark - <UITextFieldDelegate>
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.keyF) {
        self.underLine.backgroundColor = DXRGBColor(72, 72, 72);
    }
    
    if (self.warnL.hidden == NO) {
        self.warnL.hidden = YES;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.keyF) {
        self.underLine.backgroundColor = DXRGBColor(177, 177, 177);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([self.keyF isFirstResponder]) {
        [self.keyF resignFirstResponder];
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
 *  点击完成按钮
 */
- (void)finishBtnDidClick {
    
    if ([self.keyF isFirstResponder]) {
        [self.keyF resignFirstResponder];
    }
    
    if (self.keyF.text.length) {
        [self commit];
    } else {
        self.warnL.text = @"请输入邀请码";
        self.warnL.hidden = NO;
        self.underLine.backgroundColor = DXRGBColor(255, 109, 119);
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
    }
}

- (void)commit {
    
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateLoading];
    self.view.userInteractionEnabled = NO;
    
    __weak typeof(self) weakSelf = self;
    [[DXDongXiApi api] useUserCouponWithCode:self.keyF.text result:^(BOOL success, NSError *error) {
        if (success) {
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                self.view.userInteractionEnabled = YES;
                // 跳转到注册页
                DXSmsCheckViewController *vc = [[DXSmsCheckViewController alloc] initWithSmsCheckType:DXSmsCheckTypeRegisterPhone];
                vc.fromHadKeyVC = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            });
            
        } else {
            
            self.view.userInteractionEnabled = YES;
            
            weakSelf.warnL.text = @"邀请码验证失败，请重试";
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
