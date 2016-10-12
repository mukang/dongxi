//
//  DXFollowViewController.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFollowViewController.h"
#import "DXFansFollowCell.h"
#import <UIImageView+WebCache.h>
#import "DXProfileViewController.h"
#import "DXLoginViewController.h"
#import <MJRefresh.h>
#import "DXDongXiApi.h"
#import "DXNoneDataTableViewCell.h"

@interface DXFollowViewController ()<DXFansFollowCellDelegate>

@property (nonatomic, strong) NSMutableArray *followList;
@property (nonatomic, assign) BOOL firstTimeLoaded;
@property (nonatomic, copy) NSString * errorDescription;

@end

@implementation DXFollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_ProfileFollowing;

    //请求网络数据
    [self loadMorePreviousData:nil];
    
    /**
     *  对于UITableViewController而言，要在设置separatorStyle前调用registerClass:forCellReuseIdentifier:
     *
     *  @author Xu Shiwen
     *  @date   02/11/2015
     */
    [self.tableView registerClass:[DXFansFollowCell class] forCellReuseIdentifier:@"DXFansFollowCell"];
    [self.tableView registerClass:[DXNoneDataTableViewCell class] forCellReuseIdentifier:@"DXNoneDataTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = DXRGBColor(222, 222, 222);
    
    // 添加上下拉刷新
    self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    self.title = @"关注";
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserDidLoginNotification:) name:DXDongXiApiNotificationUserDidLogin object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Property Accessors

- (NSMutableArray *)followList {
    if (nil == _followList) {
        _followList = [NSMutableArray array];
    }
    return _followList;
}

#pragma mark - 上下拉

- (void)refreshFollowCount:(dispatch_block_t)completion {
    typeof(self) __weak weakSelf = self;
    [[DXDongXiApi api] getProfileOfUser:self.userProfile.uid result:^(DXUserProfile *profile, NSError *error) {
        if (profile) {
            weakSelf.userProfile.follows = profile.follows;
        }
        
        if (completion) {
            completion();
        }
    }];
}

- (void)loadNewData {
    
    __weak typeof(self) weakSelf = self;
    [self loadMoreNewData:^(BOOL hasMoreData, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

- (void)loadOldData {
    
    __weak typeof(self) weakSelf = self;
    [self loadMorePreviousData:^(BOOL hasMoreData, NSError *error) {
        DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.tableView.mj_footer;
        if (error) {
            [footer endRefreshingWithError];
        } else {
            if (hasMoreData) {
                [footer endRefreshing];
            } else {
                footer.hidden = YES;
            }
        }
    }];
}

#pragma mark - 网络请求


/**
 *  加载更多数据（上拉）
 *
 *  @param completion 加载完Block回调
 *
 *  @author Xu Shiwen
 *  @date   02/11/2015
 */
- (void)loadMorePreviousData:(void(^)(BOOL hasMoreData, NSError * error))completion {
    __weak DXFollowViewController * weakSelf = self;
    
    DXDataListPullType pullType = DXDataListPullOlderList;
    if (self.followList.count == 0) {
        pullType = DXDataListPullFirstTime;
    }
    
    DXUser * lastUser = [self.followList lastObject];
    NSString * lastID = lastUser.ID;
    
    [self refreshFollowCount:^{
        [[DXDongXiApi api] getFollowListOfUser:self.userProfile.uid pullType:pullType count:15 lastID:lastID result:^(DXUserWrapper *userWrapper, NSError *error) {
            
            weakSelf.firstTimeLoaded = YES;
            
            if (userWrapper) {
                [weakSelf.followList addObjectsFromArray:userWrapper.list];
                
                if (weakSelf.followList.count == 0) {
                    if ([weakSelf.userProfile.uid isEqualToString:[DXDongXiApi api].currentUserSession.uid]) {
                        weakSelf.errorDescription = @"你目前没有关注任何人";
                    } else {
                        weakSelf.errorDescription = @"Ta目前没有关注任何人";
                    }
                }
                
                if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer == nil && userWrapper.list.count == 15) {
                    weakSelf.tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
                }
            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍候再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.followList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.tableView reloadData];
            
            if (completion) {
                completion(userWrapper.more, error);
            }
        }];
    }];
}

/**
 *  加载更多数据（下拉）
 *
 *  @param completion 加载完Block回调
 *
 *  @author Xu Shiwen
 *  @date   02/11/2015
 */
- (void)loadMoreNewData:(void(^)(BOOL hasMoreData, NSError * error))completion {
    __weak DXFollowViewController * weakSelf = self;
    
    DXDataListPullType pullType = DXDataListPullNewerList;
    DXUser * lastUser = [self.followList firstObject];
    NSString * lastID = lastUser.ID;
    if (lastID == nil) {
        pullType = DXDataListPullFirstTime;
    }
    
    [self refreshFollowCount:^{
        [[DXDongXiApi api] getFollowListOfUser:self.userProfile.uid pullType:pullType count:15 lastID:lastID result:^(DXUserWrapper *userWrapper, NSError *error) {
            weakSelf.firstTimeLoaded = YES;
            
            if (userWrapper) {
                for (NSUInteger i = 0; i < userWrapper.list.count; i++) {
                    DXUser * user = [userWrapper.list objectAtIndex: i];
                    [weakSelf.followList insertObject:user atIndex:i];
                }
                
                if (weakSelf.followList.count == 0) {
                    if ([weakSelf.userProfile.uid isEqualToString:[DXDongXiApi api].currentUserSession.uid]) {
                        weakSelf.errorDescription = @"你目前没有关注任何人";
                    } else {
                        weakSelf.errorDescription = @"Ta目前没有关注任何人";
                    }
                }
                
                if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer == nil && userWrapper.list.count == 15) {
                    weakSelf.tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
                }

            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍候再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.followList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.tableView reloadData];
            
            if (completion) {
                completion(userWrapper.more, error);
            }
        }];
    }];
}

#pragma mark - Table view 数据源

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.firstTimeLoaded && self.followList.count == 0) {
        return 1;
    } else {
        return self.followList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.followList.count == 0) {
        DXNoneDataTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXNoneDataTableViewCell" forIndexPath:indexPath];
        cell.text = self.errorDescription;
        return cell;
    } else {
        DXFansFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXFansFollowCell" forIndexPath:indexPath];
        DXUser *user = self.followList[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.nameLabel.text = user.nick;
        cell.relation = user.relations;
        NSURL *avatarURL = [NSURL URLWithString:user.avatar];
        [cell.avatarView.avatarImageView sd_setImageWithURL:avatarURL placeholderImage:nil options:SDWebImageRetryFailed];
        cell.avatarView.verified = user.verified;
        cell.avatarView.certificationIconSize = DXCertificationIconSizeLarge;
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.followList.count == 0) {
        return DXRealValue(120);
    } else {
        return DXRealValue(62);
    }
}

#pragma mark - <DXFansFollowCellDelegate>

- (void)didTapAvatarInFansFollowCell:(DXFansFollowCell *)cell {
    NSIndexPath * tappedIndexPath = [self.tableView indexPathForCell:cell];
    DXUser * user = [self.followList objectAtIndex:tappedIndexPath.row];
    DXProfileViewController *profileVC = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
    profileVC.uid = user.uid;
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)didTapFollowButtonInFansFollowCell:(DXFansFollowCell *)cell {
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
    
    NSIndexPath * tappedIndexPath = [self.tableView indexPathForCell:cell];
    DXUser * user = [self.followList objectAtIndex:tappedIndexPath.row];
    if (cell.relation == DXUserRelationTypeFollowed || cell.relation == DXUserRelationTypeFriend) {
        DXCompatibleAlert * confirm = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleActionSheet];
        confirm.title = @"确定不再关注Ta？";
        [confirm addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDestructive handler:^(DXCompatibleAlertAction *action) {
            [[DXDongXiApi api] unfollowUser:user.uid result:^(BOOL success, DXUserRelationType relation, NSError *error) {
                if (success) {
                    user.relations = relation;
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[tappedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    NSString * loginUserUID = [DXDongXiApi api].currentUserSession.uid;
                    if ([weakSelf.userProfile.uid isEqualToString:loginUserUID]) {
                        weakSelf.userProfile.follows -= 1;
                    }
                } else {
                    NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                    NSString * message = [NSString stringWithFormat:@"取消关注失败，%@", reason];
                    [MBProgressHUD showHUDWithMessage:message];
                }
            }];
        }]];
        [confirm addAction:[DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [confirm showInController:self animated:YES completion:nil];
    } else {
        [[DXDongXiApi api] followUser:user.uid result:^(BOOL success, DXUserRelationType relation, NSError *error) {
            if (success) {
                user.relations = relation;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[tappedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                NSString * loginUserUID = [DXDongXiApi api].currentUserSession.uid;
                if ([weakSelf.userProfile.uid isEqualToString:loginUserUID]) {
                    weakSelf.userProfile.follows += 1;
                }
            } else {
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                NSString * message = [NSString stringWithFormat:@"关注失败，%@", reason];
                [MBProgressHUD showHUDWithMessage:message];
            }
        }];
    }
}

#pragma mark - Notifications

- (void)onUserDidLoginNotification:(NSNotification *)noti {
    typeof(self) __weak weakSelf = self;
    [[DXDongXiApi api] getFollowListOfUser:self.userProfile.uid pullType:DXDataListPullFirstTime count:self.followList.count lastID:nil result:^(DXUserWrapper *userWrapper, NSError *error) {
        if (userWrapper) {
            [weakSelf.followList removeAllObjects];
            [weakSelf.followList addObjectsFromArray:userWrapper.list];
            [weakSelf.tableView reloadData];
        }
    }];
}

@end
