//
//  DXAnonymousProfileViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/12/15.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXAnonymousProfileViewController.h"
#import "DXLoginViewController.h"


@interface DXAnonymousProfileViewController ()

@property (nonatomic, strong) UIView * headContainer;

@property (nonatomic, strong) UIImageView * avatarView;

@property (nonatomic, strong) UIButton * loginButton;

@property (nonatomic, strong) UIView * divider;

@property (nonatomic, strong) UILabel * textLabel;

@end



@implementation DXAnonymousProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = DXRGBColor(245, 245, 245);
    
    [self setupContents];
    [self registerEvents];
}

- (void)setupContents {
    const CGFloat viewHeight = CGRectGetHeight(self.view.bounds) - 49;
    const CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    
    const CGFloat headProp = 0.385;
    const CGFloat headHeight = roundf(viewHeight * headProp);
    const CGFloat bottomHeight = viewHeight - headHeight;
    
    self.headContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, headHeight)];
    self.headContainer.backgroundColor = [UIColor whiteColor];
    
//    UIImage * anoymousAvatar = [UIImage imageNamed:@"anonymous_head_line"];
    UIImage * anoymousAvatar = [UIImage imageNamed:@"not_login_profile_icon"];
    const CGFloat avatarWidth = roundf(DXRealValue(anoymousAvatar.size.width));
    const CGFloat avatarHeight = roundf(DXRealValue(anoymousAvatar.size.height));
    self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, avatarWidth, avatarHeight)];
    self.avatarView.image = anoymousAvatar;
    self.avatarView.center = CGPointMake(viewWidth/2, headHeight/2);
    [self.headContainer addSubview:self.avatarView];
    
    [self.view addSubview:self.headContainer];
    
    self.divider = [[UIView alloc] initWithFrame:CGRectMake(0, headHeight, viewWidth, 0.5)];
    self.divider.backgroundColor = DXRGBColor(221, 221, 221);
    [self.view addSubview:self.divider];
    
    const CGFloat textYProp = 0.081;
    const CGFloat textY = headHeight + roundf(bottomHeight * textYProp);
    const CGFloat textMargin = DXRealValue(40);
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.text = @"登陆后，你发布和收藏的内容会展示在这里";
    self.textLabel.textColor = DXRGBColor(72, 72, 72);
    self.textLabel.font = [DXFont dxDefaultFontWithSize:15];
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    CGRect textRect = [self.textLabel textRectForBounds:CGRectMake(0, 0, viewWidth-textMargin*2, CGFLOAT_MAX)
                                 limitedToNumberOfLines:0];
    CGPoint textCenter = CGPointMake(viewWidth/2, textY + textRect.size.height/2);
    self.textLabel.frame = CGRectMake(0, 0, textRect.size.width, textRect.size.height);
    self.textLabel.center = textCenter;
    [self.view addSubview:self.textLabel];
    
    UIImage * loginImage = [UIImage imageNamed:@"anonymous_login_normal"];
    UIImage * loginImageHightlighted = [UIImage imageNamed:@"anonymous_login_highlighted"];
    
    const CGFloat buttonYProp = 0.447;
    const CGFloat buttonY = bottomHeight * buttonYProp + headHeight;
    const CGFloat buttonWidth = roundf(DXRealValue(loginImage.size.width));
    const CGFloat buttonHeght = roundf(DXRealValue(loginImage.size.height));
    CGPoint buttonCenter = CGPointMake(viewWidth/2, buttonY + buttonHeght/2);
    
    self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeght)];
    [self.loginButton setCenter:buttonCenter];
    [self.loginButton setImage:loginImage forState:UIControlStateNormal];
    [self.loginButton setImage:loginImageHightlighted forState:UIControlStateHighlighted];
    [self.view addSubview:self.loginButton];
}

- (void)registerEvents {
    [self.loginButton addTarget:self action:@selector(loginButtonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 事件

- (void)loginButtonDidTapped:(UIButton *)sender {
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
    loginNav.navigationBar.hidden = YES;
    [self presentViewController:loginNav animated:YES completion:nil];
}

@end
