//
//  DXAnonymousMessageViewController.m
//  dongxi
//
//  Created by 穆康 on 15/12/15.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXAnonymousMessageViewController.h"
#import "DXLoginViewController.h"

#define TopPadding DXRealValue(64)

@interface DXAnonymousMessageViewController ()

@end

@implementation DXAnonymousMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = DXRGBColor(245, 245, 245);
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
//    iconImageView.image = [UIImage imageNamed:@"new"];
//    iconImageView.size = CGSizeMake(DXRealValue(118), DXRealValue(118.5));
    iconImageView.image = [UIImage imageNamed:@"not_login_message_icon"];
    iconImageView.size = CGSizeMake(DXRealValue(149.5), DXRealValue(130));
    iconImageView.centerX = DXScreenWidth * 0.5;
    iconImageView.centerY = DXRealValue(230) - TopPadding;
    [self.view addSubview:iconImageView];
    
    UILabel *noticeLabel = [[UILabel alloc] init];
    noticeLabel.text = @"登录后别人给你留下的评论，给你发送的消息，都会在这里通知";
    noticeLabel.textColor = DXRGBColor(72, 72, 72);
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    noticeLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(40.0/3.0)];
    noticeLabel.numberOfLines = 0;
    CGFloat noticeLabelW = DXRealValue(280);
    CGRect tempRect = [noticeLabel textRectForBounds:CGRectMake(0, 0, noticeLabelW, CGFLOAT_MAX) limitedToNumberOfLines:0];
    noticeLabel.size = tempRect.size;
    noticeLabel.centerX = DXScreenWidth * 0.5;
    noticeLabel.y = DXRealValue(366) - TopPadding;
    [self.view addSubview:noticeLabel];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setImage:[UIImage imageNamed:@"anonymous_login_normal"] forState:UIControlStateNormal];
    [loginBtn setImage:[UIImage imageNamed:@"anonymous_login_highlighted"] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(didClickLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.size = CGSizeMake(DXRealValue(280), DXRealValue(44));
    loginBtn.centerX = DXScreenWidth * 0.5;
    loginBtn.y = DXRealValue(450) - TopPadding;
    [self.view addSubview:loginBtn];
}

- (void)didClickLoginBtn {
    
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
    loginNav.navigationBar.hidden = YES;
    [self presentViewController:loginNav animated:YES completion:nil];
}

@end
