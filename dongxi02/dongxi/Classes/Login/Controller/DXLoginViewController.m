//
//  DXLoginViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLoginViewController.h"
#import "DXTabBarController.h"
#import "DXPhoneLoginViewController.h"
#import "DXSmsCheckViewController.h"
#import "DXHadKeyViewController.h"
#import "DXGetKeyViewController.h"

#import "UIImage+Extension.h"

#import "DXInvitationView.h"

#import "WXApiManager.h"
#import "JPUSHService.h"

#import <MBProgressHUD.h>

@interface DXLoginViewController () <DXInvitationViewDelegate, WXApiManagerDelegate>

@property (nonatomic, strong) NSMutableArray *dotsAnimationImages;

@property (nonatomic, weak) UIImageView *dotsImageView;

@end

@implementation DXLoginViewController {
    __weak DXLoginViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    self.dt_pageName = DXDataTrackingPage_Login;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 将WXApiManager的代理设置为self
    [WXApiManager sharedManager].delegate = self;
    
    // 设置NavBar
    [self setupNavBar];
    
    // 设置内容
    [self setupContent];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"login_emotion01@3x.png" ofType:nil];
    self.dotsImageView.image =  [UIImage imageWithContentsOfFile:filePath];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"login_emotion46@3x.png" ofType:nil];
    self.dotsImageView.image =  [UIImage imageWithContentsOfFile:filePath];
    [self.dotsImageView startAnimating];
}

/**
 *  设置NavBar
 */
- (void)setupNavBar {
    
    UIImage *bgImage = [UIImage imageWithColor:DXRGBColor(247, 250, 251)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:bgImage];
    
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont fontWithName:DXCommonBoldFontName size:18],
                                                                    NSForegroundColorAttributeName : DXCommonColor
                                                                    };
}

// 设置内容
- (void)setupContent {
    
    // 背景图片 1242 × 1453
    UIImageView *bgImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, DXScreenHeight - DXRealValue(484), DXScreenWidth, DXRealValue(484))];
    bgImageV.image = [UIImage imageNamed:@"bg_login"];
    [self.view addSubview:bgImageV];
    
    // logo
    UIImageView *logoImageV = [[UIImageView alloc] init];
    logoImageV.size = CGSizeMake(DXRealValue(133), DXRealValue(84));
    logoImageV.centerX = DXScreenWidth * 0.5;
    logoImageV.y = DXRealValue(70);
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"logo_login@3x" ofType:@"png"];
    logoImageV.image = [UIImage imageWithContentsOfFile:filePath];
    [self.view addSubview:logoImageV];
    
    // 动画图片
    for (int i=1; i<=46; i++) {
        NSString *fileName = [NSString stringWithFormat:@"login_emotion%02d@3x.png", i];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        [self.dotsAnimationImages addObject:image];
    }
    UIImageView *dotsImageView = [[UIImageView alloc] init];
    dotsImageView.animationImages = self.dotsAnimationImages;
    dotsImageView.animationRepeatCount = 1;
    dotsImageView.animationDuration = 1.5f;
    dotsImageView.frame = CGRectMake(0, CGRectGetMaxY(logoImageV.frame), DXRealValue(414), DXRealValue(11));
    [self.view addSubview:dotsImageView];
    self.dotsImageView = dotsImageView;
    
    // 概述
    UILabel *summaryL = [[UILabel alloc] init];
    summaryL.text = @"收集一切生活趣味";
    summaryL.textColor = DXRGBColor(72, 72, 72);
    summaryL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(16)];
    [summaryL sizeToFit];
    summaryL.centerX = DXScreenWidth * 0.5;
    summaryL.y = CGRectGetMaxY(dotsImageView.frame) + DXRealValue(20);
    [self.view addSubview:summaryL];
    
    // 登陆 1002 × 132
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setImage:[UIImage imageNamed:@"button_login_normal"] forState:UIControlStateNormal];
    [loginBtn setImage:[UIImage imageNamed:@"button_login_click"] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(clickLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.size = CGSizeMake(DXRealValue(334), DXRealValue(44));
    loginBtn.centerX = DXScreenWidth * 0.5;
    loginBtn.y = DXRealValue(248);
    [self.view addSubview:loginBtn];
    
    // 注册
    UIButton *signinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [signinBtn setImage:[UIImage imageNamed:@"button_signup_normal"] forState:UIControlStateNormal];
    [signinBtn setImage:[UIImage imageNamed:@"button_signup_click"] forState:UIControlStateHighlighted];
    [signinBtn addTarget:self action:@selector(clicSigninBtn) forControlEvents:UIControlEventTouchUpInside];
    signinBtn.size = CGSizeMake(DXRealValue(334), DXRealValue(44));
    signinBtn.centerX = DXScreenWidth * 0.5;
    signinBtn.y = DXRealValue(312);
    [self.view addSubview:signinBtn];
    
    // 随便逛逛 193 × 52
    UIButton *visitorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [visitorBtn setImage:[UIImage imageNamed:@"button_guest"] forState:UIControlStateNormal];
    [visitorBtn addTarget:self action:@selector(clickVisitorBtn) forControlEvents:UIControlEventTouchUpInside];
    visitorBtn.size = CGSizeMake(DXRealValue(64), DXRealValue(17));
    visitorBtn.centerX = DXScreenWidth * 0.5;
    visitorBtn.y = DXScreenHeight - visitorBtn.height - DXRealValue(30);
    [self.view addSubview:visitorBtn];
    
    // 取消按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * closeImage = [UIImage imageNamed:@"button_login_close"];
    [closeBtn setImage:closeImage forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(clickVisitorBtn) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.frame = CGRectMake(DXRealValue(20), DXRealValue(10) + 20, DXRealValue(closeImage.size.width), DXRealValue(closeImage.size.height));
    [self.view addSubview:closeBtn];
    
    // 其他登录方式标题
    UIImageView *otherImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_other_way"]];
    otherImageView.size = CGSizeMake(DXRealValue(254.5), DXRealValue(11));
    otherImageView.centerX = DXScreenWidth * 0.5;
    otherImageView.y = DXRealValue(387);
    [self.view addSubview:otherImageView];
    
    // 微信登陆按钮
    UIButton *wechatBtn = [self setupButtonWithImageName:@"login_wechat_normal" highlightedImageName:@"login_wechat_click" disabledImageName:@"login_wechat_disabled"];
    [wechatBtn addTarget:self action:@selector(handleWechatLoginClick) forControlEvents:UIControlEventTouchUpInside];
    wechatBtn.size = CGSizeMake(DXRealValue(40.5), DXRealValue(40.5));
    wechatBtn.centerX = otherImageView.centerX;
    wechatBtn.y = DXRealValue(411);
    [self.view addSubview:wechatBtn];
    
    if (![WXApi isWXAppInstalled]) {
        wechatBtn.enabled = NO;
    }
}

- (UIButton *)setupButtonWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName disabledImageName:(NSString *)disabledImageName {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:disabledImageName] forState:UIControlStateDisabled];
    
    return btn;
}


#pragma mark - 点击按钮执行的方法
// 点击登陆按钮
- (void)clickLoginBtn {
    
    DXPhoneLoginViewController *vc = [[DXPhoneLoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

// 点击注册按钮
- (void)clicSigninBtn {
    
    // 检查是否要走邀请流程
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DXDongXiApi api] checkInvitationStatusWithResult:^(BOOL success, NSError *error) {
        if (error) {
            NSString *message;
            if (error.localizedDescription) {
                message = [NSString stringWithFormat:@"%@，无法注册", error.localizedDescription];
            } else {
                message = @"出现异常，无法注册";
            }
            hud.mode = MBProgressHUDModeText;
            hud.labelText = message;
            [hud hide:YES afterDelay:2.0];
        } else {
            [hud hide:YES];
            if (success) { // 走邀请流程
                DXInvitationView *invitationView = [[DXInvitationView alloc] initWithController:self];
                invitationView.delegate = self;
                [invitationView show];
            } else {
                DXSmsCheckViewController *vc = [[DXSmsCheckViewController alloc] initWithSmsCheckType:DXSmsCheckTypeRegisterPhone];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }];
}

// 点击随便逛逛
- (void)clickVisitorBtn {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    /*
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DXHomeSelectionVCShouldReloadDataNotification object:nil];
    }];
     */
}

// 点击微信登录
- (void)handleWechatLoginClick {
    
    [self wechatLogin];
    
    /*
    DXWechatLoginInfo *wechatLoginInfo = [[WXApiManager sharedManager] wechatLoginInfo];
    if (wechatLoginInfo.access_token && wechatLoginInfo.open_id) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[WXApiManager sharedManager] refreshAccessTokenWithRefreshToken:wechatLoginInfo.refresh_token result:^(NSDictionary *responseData, NSError *error) {
            if (responseData) {
                DXWechatLoginInfo *newLoginInfo = [[DXWechatLoginInfo alloc] init];
                newLoginInfo.access_token = [responseData objectForKey:@"access_token"];
                newLoginInfo.refresh_token = [responseData objectForKey:@"refresh_token"];
                newLoginInfo.expires_in = [[responseData objectForKey:@"expires_in"] intValue];
                newLoginInfo.open_id = [responseData objectForKey:@"openid"];
                newLoginInfo.scope = [responseData objectForKey:@"scope"];
                [[WXApiManager sharedManager] saveWechatLoginInfo:newLoginInfo];
                [weakSelf wechatLoginOnServerWithLoginInfo:newLoginInfo];
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [weakSelf wechatLogin];
            }
        }];
    } else {
        [self wechatLogin];
    }
     */
}

#pragma mark - 微信登录

- (void)wechatLogin {
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"dongxiApp";
        [WXApi sendReq:req];
    } else {
        // 未安装微信客户端
        DXLog(@"未安装微信客户端");
    }
}

- (void)wechatLoginOnServerWithLoginInfo:(DXWechatLoginInfo *)loginInfo {
    loginInfo.push_id = [JPUSHService registrationID];
    [[DXDongXiApi api] loginWithWechatLoginInfo:loginInfo result:^(DXWechatLoginStatus loginStatus, DXUserSession *user, NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if (loginStatus == DXWechatLoginStatusSuccess) {
            [hud hide:NO];
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else if (loginStatus == DXWechatLoginStatusNeedBindingMobile) {
            [hud hide:NO];
            DXSmsCheckViewController *vc = [[DXSmsCheckViewController alloc] initWithSmsCheckType:DXSmsCheckTypeBindPhone];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else {
            NSString *message;
            if (error.localizedDescription) {
                message = [NSString stringWithFormat:@"登录失败，%@", error.localizedDescription];
            } else {
                message = @"登录失败，请重试";
            }
            hud.mode = MBProgressHUDModeText;
            hud.labelText = message;
            [hud hide:YES afterDelay:2.0];
        }
    }];
}

#pragma mark - <WXApiManagerDelegate>

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (response.errCode != 0) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"用户拒绝或取消授权";
        [hud hide:YES afterDelay:2.0];
        return;
    }
    
    [[WXApiManager sharedManager] getAccessTokenWithCode:response.code result:^(NSDictionary *responseData, NSError *error) {
        if (responseData) {
            NSString *accessToken = [responseData objectForKey:@"access_token"];
            NSString *openID = [responseData objectForKey:@"openid"];
            NSString *refreshToken = [responseData objectForKey:@"refresh_token"];
            int expiresIn = [[responseData objectForKey:@"expires_in"] intValue];
            NSString *scope = [responseData objectForKey:@"scope"];
            NSString *unionID = [responseData objectForKey:@"unionid"];
            if (accessToken && ![accessToken isEqualToString:@""] && openID && ![openID isEqualToString:@""]) {
                DXWechatLoginInfo *loginInfo = [[DXWechatLoginInfo alloc] init];
                loginInfo.access_token = accessToken;
                loginInfo.open_id = openID;
                loginInfo.refresh_token = refreshToken;
                loginInfo.expires_in = expiresIn;
                loginInfo.scope = scope;
                loginInfo.union_id = unionID;
                [[WXApiManager sharedManager] saveWechatLoginInfo:loginInfo];
                [weakSelf wechatLoginOnServerWithLoginInfo:loginInfo];
                
            } else {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"登录失败，请重试";
                [hud hide:YES afterDelay:2.0];
            }
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"登录失败，请重试";
            [hud hide:YES afterDelay:2.0];
        }
    }];
}

#pragma mark - <DXInvitationViewDelegate>

- (void)didTapHadKeyBtn {
    
    DXHadKeyViewController *vc = [[DXHadKeyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapGetKeyBtn {
    
    DXGetKeyViewController *vc = [[DXGetKeyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSMutableArray *)dotsAnimationImages {
    
    if (_dotsAnimationImages == nil) {
        _dotsAnimationImages = [NSMutableArray array];
    }
    return _dotsAnimationImages;
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
