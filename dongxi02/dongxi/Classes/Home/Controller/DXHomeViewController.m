//
//  DXHomeViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/4.
//  Copyright (c) 2015年 穆康. All rights reserved.
//

#import "DXHomeViewController.h"
#import "DXHomeSelectionViewController.h"
#import "DXHomeFocusViewController.h"
#import "DXHomeNewestViewController.h"
#import "DXLikeRankViewController.h"
#import "DXTabBarView.h"
#import "UIImage+Extension.h"
#import "UIBarButtonItem+Extension.h"
#import "AppDelegate.h"
#import "DXWebViewController.h"

@interface DXHomeViewController () <UIGestureRecognizerDelegate, DXTabBarViewDelegate>

/** 切换栏 */
@property (nonatomic, weak) DXTabBarView *tabBarView;
/** 精选VC */
@property (nonatomic, weak) DXHomeSelectionViewController *selectionVC;
/** 关注VC */
@property (nonatomic, weak) DXHomeFocusViewController *focusVC;
/** 最新VC */
@property (nonatomic, weak) DXHomeNewestViewController *newestVC;

@end

@implementation DXHomeViewController

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏
    [self setupNav];
    
    // 设置内容
    [self setupContentView];
    
    // 设置DXTabBar
    [self setupDXTabBar];
    [self tabBarView:self.tabBarView didTapButtonAtIndex:0];
    
    // 注册通知
    [self registerNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)dealloc {
    
    // 移除通知
    [self removeNotification];
}

/**
 *  设置导航栏
 */
- (void)setupNav {
    
    UIImage *bgImage = [UIImage imageWithColor:DXRGBColor(247, 250, 251)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:bgImage];

//    self.navigationItem.title = DXName;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = DXCommonColor;
    
    
    UIImage * titleImage = [UIImage imageNamed:@"dx_navbar_2"];
    UIImageView * titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    CGFloat scale = [UIScreen mainScreen].scale < 3 ? MAX(DXRealValue(1), 0.87) : MAX(DXRealValue(1), 0.95);
    titleImageView.frame = CGRectMake(0, 0,
                                      titleImage.size.width * scale,
                                      titleImage.size.height * scale);
    UIView * titleView = [[UIView alloc] initWithFrame:titleImageView.frame];
    [titleView addSubview:titleImageView];
    self.navigationItem.titleView = titleView;
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont fontWithName:DXCommonBoldFontName size:18],
                                                                    NSForegroundColorAttributeName : DXCommonColor
                                                                    };
    
    // 右边一周红人榜图标
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImageName:@"home_like_rank_icon" target:self action:@selector(handleClickRankButtonItem)];
    
    
//    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (![[DXDongXiApi api] needLogin]) {
        [self checkInvitationStatus];
    }
}

// 设置DXTabBar
- (void)setupDXTabBar {
    
    // 标签按钮
    DXTabBarView *tabBarView = [[DXTabBarView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXRealValue(45)) tabCount:3 names:@[@"精选", @"关注", @"最新"]];
    tabBarView.backgroundColor = DXRGBColor(247, 250, 251);
    tabBarView.delegate = self;
    tabBarView.contentInsets = UIEdgeInsetsMake(0, DXRealValue(20), 0, DXRealValue(20));
    [self.view addSubview:tabBarView];
    self.tabBarView = tabBarView;
}

// 设置内容
- (void)setupContentView {
    
    DXHomeSelectionViewController *selectionVC = [[DXHomeSelectionViewController alloc] init];
    [self addChildViewController:selectionVC];
    self.selectionVC = selectionVC;
    
    DXHomeFocusViewController *focusVC = [[DXHomeFocusViewController alloc] init];
    [self addChildViewController:focusVC];
    self.focusVC = focusVC;
    
    DXHomeNewestViewController *newestVC = [[DXHomeNewestViewController alloc] init];
    [self addChildViewController:newestVC];
    self.newestVC = newestVC;
}

#pragma mark - DXTabBarViewDelegate

- (void)tabBarView:(DXTabBarView *)view didTapButtonAtIndex:(NSUInteger)index {
    
    if (index == 0) {
        
        [self.focusVC.view removeFromSuperview];
        [self.newestVC.view removeFromSuperview];
        self.selectionVC.view.frame = self.view.bounds;
        [self.view insertSubview:self.selectionVC.view belowSubview:self.tabBarView];
        
    } else if (index == 1) {
        
        [self.selectionVC.view removeFromSuperview];
        [self.newestVC.view removeFromSuperview];
        self.focusVC.view.frame = self.view.bounds;
        [self.view insertSubview:self.focusVC.view belowSubview:self.tabBarView];
        
    } else {
        
        [self.selectionVC.view removeFromSuperview];
        [self.focusVC.view removeFromSuperview];
        self.newestVC.view.frame = self.view.bounds;
        [self.view insertSubview:self.newestVC.view belowSubview:self.tabBarView];
    }
}

#pragma mark - 点击了邀请按钮

- (void)invitationItemDidClick {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToInvitationViewControllerWithInfo:nil];
}

#pragma mark - 点击了红人榜按钮

- (void)handleClickRankButtonItem {
    
//    NSURL * testURL = [NSURL URLWithString:@"http://www.baidu.com"];
//    DXWebViewController * webVC = [[DXWebViewController alloc] init];
//    webVC.url = testURL;
//    webVC.showControls = NO;
//    webVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:webVC animated:YES];
    
    DXLikeRankViewController *rankVC = [[DXLikeRankViewController alloc] init];
    rankVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rankVC animated:YES];
}

#pragma mark - 通知

- (void)registerNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkInvitationStatus) name:DXDongXiApiNotificationUserDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeInvitationBtn) name:DXDongXiApiNotificationUserDidLogout object:nil];
}

- (void)removeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDongXiApiNotificationUserDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDongXiApiNotificationUserDidLogout object:nil];
}

#pragma mark - 收到通知后执行的方法

- (void)checkInvitationStatus {
    
    __weak typeof(self) weakSelf = self;
    if (![[DXDongXiApi api] needLogin]) {
        [[DXDongXiApi api] checkInvitationStatusWithResult:^(BOOL success, NSError *error) {
            if (success) {
                weakSelf.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"invitation_icon" target:weakSelf action:@selector(invitationItemDidClick)];
            } else {
                weakSelf.navigationItem.leftBarButtonItem = nil;
            }
        }];
    }
}

- (void)removeInvitationBtn {
    
    self.navigationItem.leftBarButtonItem = nil;
}

@end
