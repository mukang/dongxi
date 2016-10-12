//
//  DXTopicInviteViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/26.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicInviteViewController.h"
#import "DXProfileViewController.h"
#import "DXDongXiApi.h"
#import "DXTabBarView.h"
#import "DXTopicUserInviteCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DXUser+TopicInvite.h"
#import <MJRefresh.h>

#ifndef DX_SWITCH_BAR_HEIGHT
#define DX_SWITCH_BAR_HEIGHT 45.0f
#endif

@interface DXTopicInviteViewController () <DXTabBarViewDelegate,UITableViewDataSource,UITableViewDelegate,DXTopicUserInviteCellDelegate>

@property (nonatomic, strong) DXTabBarView * userSwitchBar;

@property (nonatomic, strong) DXDongXiApi * api;
@property (nonatomic, strong) NSMutableArray * followList;
@property (nonatomic, strong) NSMutableArray * fanList;
@property (nonatomic, strong) NSMutableArray * invitedFollowList;
@property (nonatomic, strong) NSMutableArray * invitedFanList;

@property (nonatomic, assign) BOOL followListFirstTimeLoaded;
@property (nonatomic, assign) BOOL fanListFirstTimeLoaded;

@property (nonatomic,strong) UITableView *followTableView;
@property (nonatomic,strong) UITableView *fansTableView;

- (void)loadMoreNewData:(void(^)(BOOL more, NSError * error))completionBlock;
- (void)loadMoreOldData:(void(^)(BOOL more, NSError * error))completionBlock;

@end

@implementation DXTopicInviteViewController

#pragma mark - View Controller Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _followList = [NSMutableArray array];
        _fanList = [NSMutableArray array];
        _invitedFollowList = [NSMutableArray array];
        _invitedFanList = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_TopicInvite;
    
    self.title = @"邀请好友参加";
    self.view.backgroundColor = DXRGBColor(0xde, 0xde, 0xde);
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    self.api = [DXDongXiApi api];
    
    [self setupSubviews];

    [self tabBarView:self.userSwitchBar didTapButtonAtIndex:0];
    
    // 添加上下拉刷新
    self.followTableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.followTableView.mj_footer = [DXRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
    
    self.fansTableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.fansTableView.mj_footer = [DXRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews {
    
    self.followTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXScreenHeight - 64)];
    self.followTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.followTableView.backgroundColor = [UIColor clearColor];
    self.followTableView.contentInset = UIEdgeInsetsMake(DX_SWITCH_BAR_HEIGHT - 0.5, 0, 0, 0);
    self.followTableView.scrollIndicatorInsets = UIEdgeInsetsMake(DX_SWITCH_BAR_HEIGHT - 0.5, 0, 0, 0);
    self.followTableView.delegate = self;
    self.followTableView.dataSource = self;
    [self.followTableView registerClass:[DXTopicUserInviteCell class] forCellReuseIdentifier:@"DXTopicUserInviteCell"];
    [self.view addSubview:self.followTableView];
    
    self.fansTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXScreenHeight - 64)];
    self.fansTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.fansTableView.backgroundColor = [UIColor clearColor];
    self.fansTableView.contentInset = UIEdgeInsetsMake(DX_SWITCH_BAR_HEIGHT - 0.5, 0, 0, 0);
    self.fansTableView.scrollIndicatorInsets = UIEdgeInsetsMake(DX_SWITCH_BAR_HEIGHT - 0.5, 0, 0, 0);
    self.fansTableView.delegate = self;
    self.fansTableView.dataSource = self;
    [self.fansTableView registerClass:[DXTopicUserInviteCell class] forCellReuseIdentifier:@"DXTopicUserInviteCell"];
    [self.view addSubview:self.fansTableView];
    
    self.userSwitchBar = [[DXTabBarView alloc] initWithFrame:CGRectMake(0, DXNavBarHeight - DX_SWITCH_BAR_HEIGHT, DXScreenWidth, DX_SWITCH_BAR_HEIGHT) tabCount:2 names:@[@"我关注的",@"我的粉丝"]];
    self.userSwitchBar.delegate = self;
    self.userSwitchBar.backgroundColor = DXRGBColor(0xf7, 0xfa, 0xfb);
    self.userSwitchBar.contentInsets = UIEdgeInsetsMake(0, DXRealValue(40), 0, DXRealValue(40));
    [self.view addSubview:self.userSwitchBar];
}

#pragma mark - 上下拉执行的方法

- (void)loadNewData {
    
    __weak typeof(self) weakSelf = self;
    [self loadMoreNewData:^(BOOL more, NSError *error) {
        if (!weakSelf.followTableView.hidden) {
            [weakSelf.followTableView.mj_header endRefreshing];
        }
        if (!weakSelf.fansTableView.hidden) {
            [weakSelf.fansTableView.mj_header endRefreshing];
        }
    }];
}

- (void)loadOldData {
    
    __weak typeof(self) weakSelf = self;
    [self loadMoreOldData:^(BOOL more, NSError *error) {
        if (!weakSelf.followTableView.hidden) {
            if (!more && !error) {
                [weakSelf.followTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.followTableView.mj_footer endRefreshing];
            }
        }
        if (!weakSelf.fansTableView.hidden) {
            if (!more && !error) {
                [weakSelf.fansTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.fansTableView.mj_footer endRefreshing];
            }
        }
    }];
}

#pragma mark - Business Logic

/**
 *  加载更多新数据（下拉）
 *
 */
- (void)loadMoreNewData:(void(^)(BOOL, NSError *))completionBlock {
    [self loadDataWithPullType:DXDataListPullNewerList completion:^(BOOL more, NSError *error) {
        if (completionBlock) {
            completionBlock(more, error);
        }
    }];
}

/**
 *  加载更多旧数据（上拉）
 *
 */
- (void)loadMoreOldData:(void(^)(BOOL, NSError *))completionBlock {
    [self loadDataWithPullType:DXDataListPullOlderList completion:^(BOOL more, NSError *error) {
        if (completionBlock) {
            completionBlock(more, error);
        }
    }];
}

- (void)loadDataWithPullType:(DXDataListPullType)pullType completion:(void(^)(BOOL more, NSError * error))completionBlock {
    __weak DXTopicInviteViewController * weakSelf = self;
    NSString * lastID = nil;
    
    if (!self.followTableView.hidden) {
        if (pullType == DXDataListPullOlderList) {
            DXUser * lastUser = [self.followList lastObject];
            lastID = lastUser.ID;
        } else if (pullType == DXDataListPullNewerList) {
            DXUser * firstUser = [self.followList firstObject];
            lastID = firstUser.ID;
        }
        
        if (!lastID) {
            pullType = DXDataListPullFirstTime;
        }
        
        [self.api getTopicInviteFollowList:self.topicID ofUser:[self api].currentUserSession.uid pullType:pullType count:15 lastID:lastID result:^(DXTopicInviteFollowList *followList, NSError *error) {
            if (followList.top) {
                [weakSelf appendUsers:followList.top toList:weakSelf.invitedFollowList invited:YES];
            }
            
            if (followList.list) {
                if (pullType == DXDataListPullOlderList) {
                    [weakSelf appendUsers:followList.list toList:weakSelf.followList invited:NO];
                } else {
                    [weakSelf insertUsers:followList.list toList:weakSelf.followList];
                }
            }
            
            [weakSelf.followTableView reloadData];
            
            if (completionBlock) {
                completionBlock(followList.more, error);
            }
        }];
    }
    
    if (!self.fansTableView.hidden) {
        if (pullType == DXDataListPullOlderList) {
            DXUser * lastUser = [self.fanList lastObject];
            lastID = lastUser.ID;
        } else if (pullType == DXDataListPullNewerList) {
            DXUser * firstUser = [self.fanList firstObject];
            lastID = firstUser.ID;
        }
        
        if (!lastID) {
            pullType = DXDataListPullFirstTime;
        }
        
        [self.api getTopicInviteFansList:self.topicID ofUser:self.api.currentUserSession.uid pullType:pullType count:15 lastID:lastID result:^(DXTopicInviteFansList *fansList, NSError *error) {
            if (fansList.top) {
                [weakSelf appendUsers:fansList.top toList:weakSelf.invitedFanList invited:YES];
            }
            
            if (fansList.list) {
                if (pullType == DXDataListPullOlderList) {
                    [weakSelf appendUsers:fansList.list toList:weakSelf.fanList invited:NO];
                } else {
                    [weakSelf insertUsers:fansList.list toList:weakSelf.fanList];
                }
            }
            
            [weakSelf.fansTableView reloadData];
            
            if (completionBlock) {
                completionBlock(fansList.more, error);
            }
        }];
    }
}

- (void)insertUsers:(NSArray *)users toList:(NSMutableArray *)list {
    for (NSUInteger i = 0; i < users.count; i++) {
        DXUser * user = users[i];
        [list insertObject:user atIndex:i];
    }
}

- (void)appendUsers:(NSArray *)users toList:(NSMutableArray *)list invited:(BOOL)invited {
    if (invited) {
        [list removeAllObjects];
    }
    for (DXUser * user in users) {
        user.invited = invited;
        [list addObject:user];
    }
}

- (void)inviteUser:(NSString *)userID completionBlock:(void(^)(BOOL success))block {
    [self.api inviteUser:userID joinTopic:self.topicID result:^(BOOL success, NSError *error) {
        if (success) {
            if (block) {
                block(success);
            }
        } else {
            NSLog(@"邀请失败: %@", error);
        }
    }];
}

- (void)syncInvitedUserData:(DXUser *)user inTableView:(UITableView *)tableView {
    if (user.invited) {
        NSMutableArray * list = nil;
        NSMutableArray * invitedList = nil;
        if (tableView == self.followTableView) {
            list = self.followList;
            invitedList = self.invitedFollowList;
        } else {
            list = self.fanList;
            invitedList = self.invitedFanList;
        }
        
        for (NSUInteger i = 0; i < list.count; i++) {
            DXUser * targetUser = [list objectAtIndex:i];
            if ([user.uid isEqualToString:targetUser.uid]) {
                targetUser.invited = YES;
                [invitedList addObject:targetUser];
                [list removeObjectAtIndex:i];
                
                [tableView reloadData];
                break;
            }
        }
    }
}


#pragma mark - DXTabBarViewDelegate

- (void)tabBarView:(DXTabBarView *)view didTapButtonAtIndex:(NSUInteger)index {
    __weak DXTopicInviteViewController * weakSelf = self;

    if (index == 0) {
        self.followTableView.hidden = NO;
        self.fansTableView.hidden = YES;
        
        if (self.followListFirstTimeLoaded == NO) {
            [self loadDataWithPullType:DXDataListPullFirstTime completion:^(BOOL more, NSError *error) {
                if (!error) {
                    weakSelf.followListFirstTimeLoaded = YES;
                } else {
                    //处理错误
                }
            }];
        }
    } else {
        self.followTableView.hidden = YES;
        self.fansTableView.hidden = NO;
        
        if (self.fanListFirstTimeLoaded == NO) {
            [self loadDataWithPullType:DXDataListPullFirstTime completion:^(BOOL more, NSError *error) {
                if (!error) {
                    weakSelf.fanListFirstTimeLoaded = YES;
                } else {
                    //处理错误
                }
            }];
        }
    }
}

#pragma mark - UITableView DataSouce

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DXTopicUserInviteCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXTopicUserInviteCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    DXUser * user = nil;
    __weak NSMutableArray * weakInvitedList = nil;
    __weak NSMutableArray * weakList = nil;
    if (tableView == self.followTableView) {
        weakInvitedList = self.invitedFollowList;
        weakList = self.followList;
        if (indexPath.section == 0) {
            user = [self.invitedFollowList objectAtIndex:indexPath.row];
        } else {
            user = [self.followList objectAtIndex:indexPath.row];
        }
    } else {
        weakInvitedList = self.invitedFanList;
        weakList = self.fanList;
        if (indexPath.section == 0) {
            user = [self.invitedFanList objectAtIndex:indexPath.row];
        } else {
            user = [self.fanList objectAtIndex:indexPath.row];
        }
    }
    [cell.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:nil options:SDWebImageRetryFailed];
    cell.avatarView.verified = user.verified;
    cell.avatarView.certificationIconSize = DXCertificationIconSizeLarge;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nick = user.nick;
    cell.location = user.location;
    cell.invited = user.invited;
    
    __weak DXTopicInviteViewController * weakSelf = self;
    __weak UITableView * weakTableView = tableView;
    cell.tapBlock = ^(DXTopicUserInviteCell * sender) {
        NSIndexPath * oldIndexPath = [weakTableView indexPathForCell:sender];
        [weakSelf inviteUser:user.uid completionBlock:^(BOOL success) {
            if (success) {
                user.invited = YES;
                [weakTableView reloadRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                [weakList removeObjectAtIndex:oldIndexPath.row];
                [weakInvitedList addObject:user];
                
                NSIndexPath * currentIndexPath = [NSIndexPath indexPathForRow:weakInvitedList.count - 1 inSection:0];
                [weakTableView moveRowAtIndexPath:oldIndexPath toIndexPath:currentIndexPath];
                
                if (weakTableView == weakSelf.followTableView) {
                    [weakSelf syncInvitedUserData:user inTableView:weakSelf.fansTableView];
                } else {
                    [weakSelf syncInvitedUserData:user inTableView:weakSelf.followTableView];
                }
            }
        }];
    };
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.followTableView) {
        if (section == 0) {
            return self.invitedFollowList.count;
        } else {
            return self.followList.count;
        }
    } else {
        if (section == 0) {
            return self.invitedFanList.count;
        } else {
            return self.fanList.count;
        }
    }
}



#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ceilf(DXRealValue(232.0f/3));
}

#pragma mark - <DXTopicUserInviteCellDelegate>

- (void)userInviteCell:(DXTopicUserInviteCell *)cell didTapAvatarView:(UIImageView *)avatarView {
    DXUser * user = nil;
    if (self.followTableView.hidden == NO) {
        NSIndexPath * indexPath = [self.followTableView indexPathForCell:cell];
        if (indexPath.row < self.invitedFollowList.count) {
            user = [self.invitedFollowList objectAtIndex:indexPath.row];
        } else {
            user = [self.followList objectAtIndex:indexPath.row-self.invitedFollowList.count];
        }
    } else {
        NSIndexPath * indexPath = [self.fansTableView indexPathForCell:cell];
        if (indexPath.row < self.invitedFanList.count) {
            user = [self.invitedFanList objectAtIndex:indexPath.row];
        } else {
            user = [self.fanList objectAtIndex:indexPath.row-self.invitedFanList.count];
        }
    }

    if (user) {
        DXProfileViewController * profileVC = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
        profileVC.uid = user.uid;
        [self.navigationController pushViewController:profileVC animated:YES];
    }
}



@end
