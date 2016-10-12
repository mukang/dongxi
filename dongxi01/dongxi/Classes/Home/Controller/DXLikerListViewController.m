//
//  DXLikerListViewController.m
//  dongxi
//
//  Created by 穆康 on 15/10/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLikerListViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "DXLikerCell.h"
#import "DXDongXiApi.h"
#import "DXMainNavigationController.h"
#import "DXLoginViewController.h"
#import <MJRefresh.h>
#import "DXNoneDataTableViewCell.h"

@interface DXLikerListViewController () <DXLikerCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, assign) BOOL firstTimeLoaded;
@property (nonatomic, copy) NSString * errorDescription;

@end

@implementation DXLikerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_PhotoLikes;
    
    self.tableView.backgroundColor = DXRGBColor(222, 222, 222);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 设置导航栏
    [self setupNavBar];
    
    // 添加上下拉刷新
    self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
    self.tableView.mj_footer.hidden = YES;
    [self.tableView registerClass:[DXNoneDataTableViewCell class] forCellReuseIdentifier:@"DXNoneDataTableViewCell"];
    
    // 首次获取数据
    [self loadDataFirst];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserDidLoginNotification:) name:DXDongXiApiNotificationUserDidLogin object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  设置导航栏
 */
- (void)setupNavBar {
    
    self.title = @"赞";
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(backBtnDidClick)];
}

- (void)loadDataFirst {
    
    __weak __typeof(self) weakSelf = self;
    [[DXDongXiApi api] getLikeUsersOfFeed:self.feedID pullType:DXDataListPullFirstTime count:20 lastID:nil result:^(DXUserWrapper *users, NSError *error) {
        weakSelf.firstTimeLoaded = YES;
        if (users.list.count) {
            [weakSelf.dataList addObjectsFromArray:users.list];
            if (weakSelf.tableView.mj_footer.isHidden && users.list.count == 20) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        } else {
            weakSelf.errorDescription = @"0人点赞";
            if (error) {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
            }
        }
        
        [weakSelf.tableView reloadData];
    }];
}

- (void)loadNewData {

    DXUser *user = [self.dataList firstObject];
    DXDataListPullType pullType;
    if (user.ID) {
        pullType = DXDataListPullNewerList;
    } else {
        pullType = DXDataListPullFirstTime;
    }
    __weak __typeof(self) weakSelf = self;
    [[DXDongXiApi api] getLikeUsersOfFeed:self.feedID pullType:pullType count:20 lastID:user.ID result:^(DXUserWrapper *users, NSError *error) {
        if (users.list.count) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, users.list.count)];
            [weakSelf.dataList insertObjects:users.list atIndexes:indexSet];
            if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer.isHidden && users.list.count == 20) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        } else {
            weakSelf.errorDescription = @"0人点赞";
            if (error) {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

- (void)loadOldData {
    
    DXUser *user = [self.dataList lastObject];
    DXDataListPullType pullType;
    if (user.ID) {
        pullType = DXDataListPullOlderList;
    } else {
        pullType = DXDataListPullFirstTime;
    }
    __weak __typeof(self) weakSelf = self;
    [[DXDongXiApi api] getLikeUsersOfFeed:self.feedID pullType:pullType count:20 lastID:user.ID result:^(DXUserWrapper *users, NSError *error) {
        if (users.list.count) {
            [weakSelf.dataList addObjectsFromArray:users.list];
        }
        if (error) {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
            if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
        }
        [weakSelf.tableView reloadData];
        
        DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.tableView.mj_footer;
        if (error) {
            [footer endRefreshingWithError];
        } else {
            if (!users.more) {
                weakSelf.tableView.mj_footer.hidden = YES;
            } else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.firstTimeLoaded && self.dataList.count == 0) {
        return 1;
    } else {
        return self.dataList.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataList.count == 0) {
        DXNoneDataTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXNoneDataTableViewCell" forIndexPath:indexPath];
        cell.text = self.errorDescription;
        return cell;
    } else {
        DXLikerCell *cell = [DXLikerCell cellWithTableView:tableView];
        
        DXUser *user = self.dataList[indexPath.row];
        
        cell.user = user;
        cell.delegate = self;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataList.count == 0) {
        return DXRealValue(120);
    } else {
        return DXRealValue(62);
    }
}

#pragma mark - DXLikerCellDelegate

- (void)didTapAvatarInLikerCellWithUserID:(NSString *)userID {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

- (void)didTapFollowBtnInLikerCell:(DXLikerCell *)cell withUser:(DXUser *)user {
    typeof(self) __weak weakSelf = self;
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

    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    
    typeof(cell) __weak weakCell = cell;
    
    switch (cell.relation) {
        case DXUserRelationTypeNone: {
            user.relations = DXUserRelationTypeFollowed;
            cell.relation = DXUserRelationTypeFollowed;
            [nav followUserWithUserID:user.uid info:nil completion:^(BOOL success) {
                if (!success) {
                    user.relations = DXUserRelationTypeNone;
                    weakCell.relation = DXUserRelationTypeNone;
                }
            }];
        }
            break;
        case DXUserRelationTypeFollower: {
            user.relations = DXUserRelationTypeFriend;
            cell.relation = DXUserRelationTypeFriend;
            [nav followUserWithUserID:user.uid info:nil completion:^(BOOL success) {
                if (!success) {
                    user.relations = DXUserRelationTypeFollower;
                    weakCell.relation = DXUserRelationTypeFollower;
                }
            }];
        }
            break;
        case DXUserRelationTypeFollowed: {
            user.relations = DXUserRelationTypeNone;
            cell.relation = DXUserRelationTypeNone;
            [nav unfollowUserWithUserID:user.uid info:nil completion:^(BOOL success) {
                if (!success) {
                    user.relations = DXUserRelationTypeFollowed;
                    weakCell.relation = DXUserRelationTypeFollowed;
                }
            }];
        }
            break;
        case DXUserRelationTypeFriend: {
            user.relations = DXUserRelationTypeFollower;
            cell.relation = DXUserRelationTypeFollower;
            [nav unfollowUserWithUserID:user.uid info:nil completion:^(BOOL success) {
                if (!success) {
                    user.relations = DXUserRelationTypeFriend;
                    weakCell.relation = DXUserRelationTypeFriend;
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 点击按钮执行的方法

/**
 *  点击返回按钮
 */
- (void)backBtnDidClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 懒加载

- (NSMutableArray *)dataList {
    
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

#pragma mark - Notifications

- (void)onUserDidLoginNotification:(NSNotification *)noti {
    typeof(self) __weak weakSelf = self;
    [[DXDongXiApi api] getLikeUsersOfFeed:self.feedID pullType:DXDataListPullFirstTime count:self.dataList.count lastID:nil result:^(DXUserWrapper *users, NSError *error) {
        if (users) {
            [weakSelf.dataList removeAllObjects];
            [weakSelf.dataList addObjectsFromArray:users.list];
            [weakSelf.tableView reloadData];
        }
    }];
}

@end
