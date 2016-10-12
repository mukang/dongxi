//
//  DXDiscoverViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/4.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDiscoverViewController.h"

#import "DXDiscoverTopicViewController.h"
#import "DXDiscoverEventViewController.h"
#import "DXDiscoverUserViewController.h"
#import "DXTabBarController.h"
#import "DXSearchViewController.h"
#import "DXTabBarView.h"

#import "UIBarButtonItem+Extension.h"
#import "UIImage+Extension.h"

#import <UIImageView+WebCache.h>

#import "DXActivityListCell.h"
#import "DXSearchNoResultsCell.h"

#import "DXTagAlertView.h"

#ifndef DX_SWITCH_BAR_HEIGHT
#define DX_SWITCH_BAR_HEIGHT DXRealValue(45.0f)
#endif

@interface DXDiscoverViewController ()
<
DXTabBarViewDelegate
>

@property (nonatomic, strong) DXDiscoverTopicViewController * discoverTopicVC;
@property (nonatomic, strong) DXDiscoverEventViewController * discoverEventVC;
@property (nonatomic, strong) DXDiscoverUserViewController * discoverUserVC;

@property (nonatomic, strong) DXTabBarView * secondNavBar;

@end

@implementation DXDiscoverViewController {
    __weak DXDiscoverViewController *weakSelf;
}

#pragma mark - ViewController生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadSubViews];
    
    [self tabBarView:self.secondNavBar didTapButtonAtIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

- (void)selectTableAtIndex:(NSUInteger)tableIndex {
    if (tableIndex < 3) {
        [self.secondNavBar selectIndex:tableIndex];
        [self tabBarView:self.secondNavBar didTapButtonAtIndex:tableIndex];
    }
}


#pragma mark - Private Methods

- (void)loadSubViews {
//    self.secondNavBar = [[DXTabBarView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DX_SWITCH_BAR_HEIGHT) tabCount:3 names:@[@"找话题",@"找活动",@"找人"]];
    // 隐藏找活动, since v1.2.0
    self.secondNavBar = [[DXTabBarView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DX_SWITCH_BAR_HEIGHT) tabCount:2 names:@[@"找话题",@"找人"]];
    self.secondNavBar.delegate = self;
    self.secondNavBar.contentInsets = UIEdgeInsetsMake(0, DXRealValue(20.0), 0, DXRealValue(20.0));
    self.secondNavBar.backgroundColor = DXRGBColor(0xf7, 0xfa, 0xfb);
    [self.view addSubview:self.secondNavBar];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"GrayPixel"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"TransparentPixel"]];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = DXCommonColor;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont fontWithName:DXCommonBoldFontName size:18],
                                                                    NSForegroundColorAttributeName : DXCommonColor
                                                                    };
    
    self.navigationItem.title = @"发现";
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImageName:@"discover_search_button" target:self action:@selector(searchBtnDidClick)];
}

- (void)adjustTableView:(UIScrollView *)tableView {
    if (tableView) {
        UIEdgeInsets contentInsets = tableView.contentInset;
        contentInsets.top = DX_SWITCH_BAR_HEIGHT;
        tableView.contentInset = contentInsets;
        tableView.scrollIndicatorInsets = contentInsets;
    }
}


#pragma mark - DXTabBarViewDelegate

- (void)tabBarView:(DXTabBarView *)view didTapButtonAtIndex:(NSUInteger)index {
    switch (index) {
        case 0: {
            if (nil == self.discoverTopicVC) {
                self.discoverTopicVC = [[DXDiscoverTopicViewController alloc] init];
                [self addChildViewController:self.discoverTopicVC];
                self.discoverTopicVC.view.frame = self.view.bounds;
                [self adjustTableView:self.discoverTopicVC.tableView];
            }
            self.discoverTopicVC.view.hidden = NO;
            [self.view insertSubview:self.discoverTopicVC.view belowSubview:self.secondNavBar];
            
            self.discoverEventVC.view.hidden = YES;
            [self.discoverEventVC.view removeFromSuperview];
            
            self.discoverUserVC.view.hidden = YES;
            [self.discoverUserVC.view removeFromSuperview];
        }
            break;
            // 隐藏找活动, since v1.2.0
//        case 1: {
//            if (nil == self.discoverEventVC) {
//                self.discoverEventVC = [[DXDiscoverEventViewController alloc] init];
//                [self addChildViewController:self.discoverEventVC];
//                self.discoverEventVC.view.frame = self.view.bounds;
//                [self adjustTableView:self.discoverEventVC.collectionView];
//            }
//            self.discoverTopicVC.view.hidden = YES;
//            [self.discoverTopicVC.view removeFromSuperview];
//            
//            self.discoverEventVC.view.hidden = NO;
//            [self.view insertSubview:self.discoverEventVC.view belowSubview:self.secondNavBar];
//            
//            self.discoverUserVC.view.hidden = YES;
//            [self.discoverUserVC.view removeFromSuperview];
//        }
//            break;
        case 1: {
            if (nil == self.discoverUserVC) {
                self.discoverUserVC = [[DXDiscoverUserViewController alloc] init];
                [self addChildViewController:self.discoverUserVC];
                self.discoverUserVC.view.frame = self.view.bounds;
                [self adjustTableView:self.discoverUserVC.collectionView];
            }
            self.discoverTopicVC.view.hidden = YES;
            [self.discoverTopicVC.view removeFromSuperview];
            
            self.discoverEventVC.view.hidden = YES;
            [self.discoverEventVC.view removeFromSuperview];
            
            self.discoverUserVC.view.hidden = NO;
            [self.view insertSubview:self.discoverUserVC.view belowSubview:self.secondNavBar];
        }
            break;
        default:
            break;
    }
}


#pragma mark - 点击了搜索按钮
/**
 *  点击了搜索按钮
 */
- (void)searchBtnDidClick {
    
//    DXTagAlertView *alertView = [[DXTagAlertView alloc] initWithController:self.tabBarController];
//    [alertView show];
    
    DXSearchViewController *vc = [[DXSearchViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:NO];
    
}

@end
