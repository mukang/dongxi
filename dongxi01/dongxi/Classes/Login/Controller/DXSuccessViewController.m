//
//  DXSuccessViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSuccessViewController.h"

@interface DXSuccessViewController ()

@end

@implementation DXSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置内容
    [self setupContent];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

/**
 *  设置内容
 */
- (void)setupContent {
    
    // 飞机图
    UIImageView *airflyImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"airfly"]];
    airflyImageV.frame = CGRectMake(DXRealValue(70.0f), DXRealValue(120.0f), DXRealValue(207.0f), DXRealValue(74.0f));
    [self.view addSubview:airflyImageV];
    
    // 文字
    UILabel *successL = [[UILabel alloc] init];
    successL.numberOfLines = 0;
    successL.text = @"感谢您的申请，我们会尽快处理\n记得查收短信- ^o^";
    successL.textColor = DXRGBColor(143, 143, 143);
    successL.textAlignment = NSTextAlignmentCenter;
    successL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17.0f)];
    [successL sizeToFit];
    successL.centerX = DXScreenWidth * 0.5f;
    successL.y = DXRealValue(232.0f);
    [self.view addSubview:successL];
    
    // 按钮
    UIButton *browseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [browseBtn setImage:[UIImage imageNamed:@"button_browse_normal"] forState:UIControlStateNormal];
    [browseBtn setImage:[UIImage imageNamed:@"button_browse_click"] forState:UIControlStateHighlighted];
    [browseBtn addTarget:self action:@selector(browseBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    browseBtn.size = CGSizeMake(DXRealValue(280.0f), DXRealValue(44.0f));
    browseBtn.centerX = DXScreenWidth * 0.5f;
    browseBtn.y = DXRealValue(342.0f);
    [self.view addSubview:browseBtn];
}

- (void)browseBtnDidClick {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
