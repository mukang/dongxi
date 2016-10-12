//
//  DXLikeRankViewController.m
//  dongxi
//
//  Created by 穆康 on 16/3/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLikeRankViewController.h"
#import "DXProfileViewController.h"
#import "DXLoginViewController.h"

#import "DXLikeRankUserCell.h"
#import "DXNoneDataTableViewCell.h"
#import "DXLikeRankAlertView.h"

#import "UIBarButtonItem+Extension.h"

#import <MJRefresh.h>

static NSString *const LikeRankUserCell         = @"LikeRankUserCell";
static NSString *const NoneDataTableViewCell    = @"NoneDataTableViewCell";

@interface DXLikeRankViewController () <UITableViewDataSource, UITableViewDelegate, DXRankUserBaseCellDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, copy) NSString *errorDescription;
@property (nonatomic, copy) NSString *alertTitle;
@property (nonatomic, copy) NSString *alertContent;

@end

@implementation DXLikeRankViewController {
    __weak DXLikeRankViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    self.dt_pageName = DXDataTrackingPage_LikeRank;
    
    [self setupNav];
    [self setupContent];
    [self loadNetData];
    
    // 添加上下拉刷新
    self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNetData)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handelUserDidLoginNotification) name:DXDongXiApiNotificationUserDidLogin object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNav {
    
    self.title = @"一周红人榜";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(handleBackButtonTap)];
}

- (void)setupRightBarButtonItem {
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImageName:@"discover_rank_issue" target:self action:@selector(handleIssueButtonTap)];
}

- (void)setupContent {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    [tableView registerClass:[DXLikeRankUserCell class] forCellReuseIdentifier:LikeRankUserCell];
    [tableView registerClass:[DXNoneDataTableViewCell class] forCellReuseIdentifier:NoneDataTableViewCell];
    self.tableView = tableView;
}

- (void)loadNetData {
    
    [[DXDongXiApi api] getLikeRankUserWrapper:^(DXLikeRankUserWrapper *rankUserWrapper, NSError *error) {
        if (rankUserWrapper.list.count) {
            weakSelf.dataList = rankUserWrapper.list;
            weakSelf.alertTitle = rankUserWrapper.info.title;
            weakSelf.alertContent = rankUserWrapper.info.content;
            [weakSelf setupRightBarButtonItem];
        } else {
            weakSelf.errorDescription = @"暂无排行";
            if (error) {
                NSString *reson = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reson];
            }
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - table view dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataList.count) {
        return self.dataList.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataList.count) {
        DXLikeRankUserCell *cell = [tableView dequeueReusableCellWithIdentifier:LikeRankUserCell forIndexPath:indexPath];
        cell.rankUser = self.dataList[indexPath.row];
        cell.delegate = self;
        return cell;
    } else {
        DXNoneDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NoneDataTableViewCell forIndexPath:indexPath];
        cell.text = self.errorDescription;
        return cell;
    }
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataList.count) {
        return DXRealValue(62);
    } else {
        return DXRealValue(120);
    }
}

#pragma mark - topicRankUserCell delegate

- (void)rankUserCell:(DXRankUserBaseCell *)cell didTapAvatarViewWithUserID:(NSString *)userID {
    DXProfileViewController *vc = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
    vc.uid = userID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rankUserCell:(DXRankUserBaseCell *)cell didTapFollowBtnWithRankUser:(DXRankUser *)rankUser {
    if ([[DXDongXiApi api] needLogin]) {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才可关注你感兴趣的人，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
        return;
    }
    
    typeof(cell) __weak weakCell = cell;
    typeof(rankUser) __weak weakRankUser = rankUser;
    switch (cell.relation) {
        case DXUserRelationTypeNone: {
            rankUser.relations = DXUserRelationTypeFollowed;
            cell.relation = DXUserRelationTypeFollowed;
            [self followUserWithUserID:rankUser.uid result:^(BOOL success) {
                if (!success) {
                    weakRankUser.relations = DXUserRelationTypeNone;
                    weakCell.relation = DXUserRelationTypeNone;
                }
            }];
        }
            break;
        case DXUserRelationTypeFollower: {
            rankUser.relations = DXUserRelationTypeFriend;
            cell.relation = DXUserRelationTypeFriend;
            [self followUserWithUserID:rankUser.uid result:^(BOOL success) {
                if (!success) {
                    weakRankUser.relations = DXUserRelationTypeFollower;
                    weakCell.relation = DXUserRelationTypeFollower;
                }
            }];
        }
            break;
        case DXUserRelationTypeFollowed: {
            rankUser.relations = DXUserRelationTypeNone;
            cell.relation = DXUserRelationTypeNone;
            [self unfollowUserWithUserID:rankUser.uid result:^(BOOL success) {
                if (!success) {
                    weakRankUser.relations = DXUserRelationTypeFollowed;
                    weakCell.relation = DXUserRelationTypeFollowed;
                }
            }];
        }
            break;
        case DXUserRelationTypeFriend: {
            rankUser.relations = DXUserRelationTypeFollower;
            cell.relation = DXUserRelationTypeFollower;
            [self unfollowUserWithUserID:rankUser.uid result:^(BOOL success) {
                if (!success) {
                    weakRankUser.relations = DXUserRelationTypeFriend;
                    weakCell.relation = DXUserRelationTypeFriend;
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)followUserWithUserID:(NSString *)userID result:(void(^)(BOOL success))resultBlock {
    [[DXDongXiApi api] followUser:userID result:^(BOOL success, DXUserRelationType relation, NSError *error) {
        if (success) {
            DXLog(@"关注成功");
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            NSString *message = [NSString stringWithFormat:@"关注失败，%@", reason];
            [MBProgressHUD showHUDWithMessage:message];
        }
        if (resultBlock) {
            resultBlock(success);
        }
    }];
}

- (void)unfollowUserWithUserID:(NSString *)userID result:(void(^)(BOOL success))resultBlock {
    [[DXDongXiApi api] unfollowUser:userID result:^(BOOL success, DXUserRelationType relation, NSError *error) {
        if (success) {
            DXLog(@"取消关注成功");
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            NSString *message = [NSString stringWithFormat:@"取消关注失败，%@", reason];
            [MBProgressHUD showHUDWithMessage:message];
        }
        if (resultBlock) {
            resultBlock(success);
        }
    }];
}

#pragma mark - 处理按钮点击事件

- (void)handleBackButtonTap {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleIssueButtonTap {
    DXLikeRankAlertView *alertView = [[DXLikeRankAlertView alloc] initWithTitle:self.alertTitle content:self.alertContent fromController:self.tabBarController];
    [alertView show];
}

#pragma mark - 处理通知

- (void)handelUserDidLoginNotification {
    [self loadNetData];
}

#pragma mark - 懒加载

- (NSArray *)dataList {
    if (_dataList == nil) {
        _dataList = [[NSArray alloc] init];
    }
    return _dataList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
