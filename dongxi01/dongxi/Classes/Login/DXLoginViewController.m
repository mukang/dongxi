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

@interface DXLoginViewController ()

@end

@implementation DXLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置内容
    [self setupContent];
}

// 设置内容
- (void)setupContent {
    
    // 背景图片 1242 × 1453
    UIImageView *bgImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, DXScreenHeight - DXRealValue(484), DXScreenWidth, DXRealValue(484))];
    bgImageV.image = [UIImage imageNamed:@"bg_login"];
    [self.view addSubview:bgImageV];
    
    // logo
    UIImageView *logoImageV = [[UIImageView alloc] init];
    logoImageV.size = CGSizeMake(DXRealValue(133), DXRealValue(65));
    logoImageV.centerX = DXScreenWidth * 0.5;
    logoImageV.y = DXRealValue(70);
    logoImageV.image = [UIImage imageNamed:@"logo_login"];
    [self.view addSubview:logoImageV];
    
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
    
    //
//    UILabel *visitorL = [[UILabel alloc] init];
//    visitorL.userInteractionEnabled = YES;
//    NSString *str = @"随便逛逛";
//    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
//    [attStr addAttributes:@{
//                            NSFontAttributeName: [UIFont fontWithName:DXCommonFontName size:16],
//                            NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle],
//                            NSForegroundColorAttributeName: DXRGBColor(72, 72, 72)
//                            } range:NSMakeRange(0, str.length)];
//    visitorL.attributedText = attStr;
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickVisitorL)];
//    [visitorL addGestureRecognizer:tapGesture];
//    [visitorL sizeToFit];
//    visitorL.centerX = DXScreenWidth * 0.5;
//    visitorL.y = DXScreenHeight - visitorL.height - DXRealValue(30);
//    [self.view addSubview:visitorL];
    // 随便逛逛 193 × 52
    UIButton *visitorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [visitorBtn setImage:[UIImage imageNamed:@"button_guest"] forState:UIControlStateNormal];
    [visitorBtn addTarget:self action:@selector(clickVisitorBtn) forControlEvents:UIControlEventTouchUpInside];
    visitorBtn.size = CGSizeMake(64, 17);
    visitorBtn.centerX = DXScreenWidth * 0.5;
    visitorBtn.y = DXScreenHeight - visitorBtn.height - DXRealValue(30);
    [self.view addSubview:visitorBtn];
}



// 点击登陆按钮
- (void)clickLoginBtn {
    
    DXPhoneLoginViewController *vc = [[DXPhoneLoginViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

// 点击注册按钮
- (void)clicSigninBtn {
    
    DXSmsCheckViewController *vc = [[DXSmsCheckViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

// 点击随便逛逛
- (void)clickVisitorBtn {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
