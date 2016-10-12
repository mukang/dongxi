//
//  DXHomeNewestViewController.m
//  dongxi
//
//  Created by 穆康 on 16/3/8.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXHomeNewestViewController.h"
#import "DXMainNavigationController.h"
#import "DXDetailViewController.h"
#import "DXLoginViewController.h"
#import "DXChatViewController.h"

#import "DXFeedCell.h"
#import "DXNoneDataTableViewCell.h"
#import "DXTimelineFeed+User.h"

#import <MJRefresh.h>

static NSString *const FeedCell              = @"FeedCell";
static NSString *const NoneDataTableViewCell = @"NoneDataTableViewCell";

@interface DXHomeNewestViewController ()
<
DXFeedCellDelegate,
UITableViewDataSource,
UITableViewDelegate
>

@property (nonatomic, strong) DXDongXiApi *api;
@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic, weak) UITableView *tableView;

/** 当前正在操作的cell的indexPath */
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
/** 错误信息描述 */
@property (nonatomic, copy) NSString *errorDesc;

@end

@implementation DXHomeNewestViewController {
    __weak DXHomeNewestViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    self.dt_pageName = DXDataTrackingPage_HomeTimelineNewest;
    
    // 设置子控件
    [self setupSubviews];
    
    // 添加上下拉刷新
    self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
    self.tableView.mj_footer.hidden = YES;
    
    // 首次加载
    [self fetchNewestFeedWrapperWithPullType:DXDataListPullFirstTime completion:nil];
    
    // 注册通知
    [self registerNotification];
}

- (void)dealloc {
    // 移除通知
    [self removeNotification];
}

#pragma mark - 设置子控件

- (void)setupSubviews {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.backgroundColor = DXRGBColor(222, 222, 222);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.contentInset = UIEdgeInsetsMake(DXRealValue(45), 0, 0, 0);
    tableView.scrollIndicatorInsets = UIEdgeInsetsMake(DXRealValue(45), 0, 0, 0);
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - 获取数据

- (void)loadNewData {
    
    [self.api getTimelineNewestList:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
        
        if (feedWrapper.feeds.count) {
            [weakSelf.feeds removeAllObjects];
            weakSelf.tableView.mj_footer.hidden = YES;
            
            [weakSelf.feeds addObjectsFromArray:feedWrapper.feeds];
            if (weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        }
        if (error) {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
            if (weakSelf.feeds.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDesc];
        }
        
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    
    /*
    [self fetchNewestFeedWrapperWithPullType:DXDataListPullNewerList completion:^(BOOL more, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
    }];
     */
}

- (void)loadOldData {
    
    [self fetchNewestFeedWrapperWithPullType:DXDataListPullOlderList completion:^(BOOL more, NSError *error) {
        if (error) {
            DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.tableView.mj_footer;
            [footer endRefreshingWithError];
        } else {
            if (!more) {
                weakSelf.tableView.mj_footer.hidden = YES;
            } else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
        }
    }];
}

- (void)fetchNewestFeedWrapperWithPullType:(DXDataListPullType)pullType completion:(void(^)(BOOL more, NSError *error))completionBlock {
    
    DXTimelineFeed *feed = nil;
    if (pullType == DXDataListPullNewerList) {
        feed = [self.feeds firstObject];
    } else if (pullType == DXDataListPullOlderList) {
        feed = [self.feeds lastObject];
    }
    if (feed == nil) pullType = DXDataListPullFirstTime;
    
    [self.api getTimelineNewestList:pullType count:10 lastID:feed.fid result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
        
        if (feedWrapper.feeds.count) {
            if (pullType == DXDataListPullNewerList) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, feedWrapper.feeds.count)];
                [weakSelf.feeds insertObjects:feedWrapper.feeds atIndexes:indexSet];
            } else {
                [weakSelf.feeds addObjectsFromArray:feedWrapper.feeds];
            }
            if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        }
        if (error) {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
            if (weakSelf.feeds.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDesc];
        }
        
        [weakSelf.tableView reloadData];
        
        if (completionBlock) {
            completionBlock(feedWrapper.more, error);
        }
    }];
}

#pragma mark - 数据源和代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.feeds.count) {
        return self.feeds.count;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.feeds.count) {
        DXFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedCell];
        if (cell == nil) {
            cell = [[DXFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeedCell];
        }
        cell.feed = self.feeds[indexPath.row];
        cell.indexPath = indexPath;
        cell.delegate = self;
        return cell;
    } else {
        DXNoneDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NoneDataTableViewCell];
        if (cell == nil) {
            cell = [[DXNoneDataTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoneDataTableViewCell];
        }
        cell.text = self.errorDesc;
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.feeds.count) {
        DXTimelineFeed *feed = self.feeds[indexPath.row];
        return [DXFeedCell tableView:tableView heightForRowAtIndexPath:indexPath withFeed:feed];
    } else {
        return DXRealValue(120);
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.feeds.count) {
        DXTimelineFeed *feed = self.feeds[indexPath.row];
        self.currentIndexPath = indexPath;
        
        DXDetailViewController *vc = [[DXDetailViewController alloc] initWithControllerType:DXDetailViewControllerTypeFeed];
        vc.detailType = DXDetailTypeContent;
        vc.feed = feed;
        vc.infoChangeBlock = ^(DXTimelineFeed *feed) {
            [weakSelf feedInfoShouldChangeWithFeed:feed];
        };
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - DXFeedCellDelegate

- (void)didTapAvatarViewInFeedCellWithUserID:(NSString *)userID {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

- (void)didTapTopicViewInFeedCellWithTopicID:(NSString *)topicID {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToTopicViewControllerWithTopicID:topicID info:nil];
}

- (void)didTapLikeAvatarViewInFeedCellWithFeedID:(NSString *)feedID {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToLikerListViewControllerWithFeedID:feedID info:nil];
}

- (void)feedCell:(DXFeedCell *)cell didTapLikeViewWithFeed:(DXTimelineFeed *)feed {
    if ([[DXDongXiApi api] needLogin]) {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才可对内容点赞，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
        return;
    }
    
    [self likeInfoShouldChangeWithFeed:feed cell:cell];
}

- (void)feedCell:(DXFeedCell *)cell didTapCommentViewWithFeed:(DXTimelineFeed *)feed {
    
    self.currentIndexPath = cell.indexPath;
    
    DXDetailViewController *vc = [[DXDetailViewController alloc] init];
    vc.detailType = DXDetailTypeComment;
    vc.feed = feed;
    vc.infoChangeBlock = ^(DXTimelineFeed *feed) {
        [weakSelf feedInfoShouldChangeWithFeed:feed];
    };
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapChatViewInFeedCellWithFeed:(DXTimelineFeed *)feed {
    
    if ([[DXDongXiApi api] needLogin]) {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才能和其他用户进行聊天，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
        return;
    }
    
    if ([feed isPublishedByCurrentLoginUser]) {
        [MBProgressHUD showHUDWithMessage:@"不能和自己聊天"];
    } else {
        DXChatViewController *vc = [[DXChatViewController alloc] init];
        DXUser *other_user = [[DXUser alloc] init];
        other_user.uid = feed.uid;
        other_user.nick = feed.nick;
        other_user.avatar = feed.avatar;
        other_user.verified = feed.verified;
        vc.other_user = other_user;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didTapShareViewInFeedCellWithFeed:(DXTimelineFeed *)feed {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav showCollectionAndShareViewWithFeed:feed info:nil];
}

- (void)feedCell:(DXFeedCell *)cell didTapMoreButtonWithFeed:(DXTimelineFeed *)feed {
    
    self.currentIndexPath = cell.indexPath;
    
    DXDetailViewController *vc = [[DXDetailViewController alloc] initWithControllerType:DXDetailViewControllerTypeFeed];
    vc.detailType = DXDetailTypeContent;
    vc.feed = feed;
    vc.infoChangeBlock = ^(DXTimelineFeed *feed) {
        [weakSelf feedInfoShouldChangeWithFeed:feed];
    };
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)feedCell:(DXFeedCell *)cell didSelectReferUserWithUserID:(NSString *)userID {
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

- (void)feedCell:(DXFeedCell *)cell didSelectReferTopicWithTopicID:(NSString *)topicID {
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToTopicViewControllerWithTopicID:topicID info:nil];
}

#pragma mark - 显示的feed内容需要改变

/**
 *  整个feed展示的数据需要改变
 */
- (void)feedInfoShouldChangeWithFeed:(DXTimelineFeed *)feed {
    
    DXTimelineFeed *changeFeed = [self.feeds objectAtIndex:self.currentIndexPath.row];
    changeFeed.data = feed.data;
    [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

/**
 *  点赞信息需要改变
 */
- (void)likeInfoShouldChangeWithFeed:(DXTimelineFeed *)feed cell:(DXFeedCell *)cell {
    
    if (!feed.data.is_like) { // 要点赞
        cell.toolBar.likeView.like = YES;
        
        [self.api likeFeedWithFeedID:feed.fid result:^(BOOL success, NSError *error) {
            if (!success) { // 点赞没有成功
                cell.toolBar.likeView.like = NO;
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后尝试";
                NSString * message = [NSString stringWithFormat:@"点赞失败，%@", reason];
                [MBProgressHUD showHUDWithMessage:message];
            } else { // 点赞成功
                
                NSDictionary *userInfo = @{
                                           kFeedIDKey     : feed.fid,
                                           kLikeStatusKey : @(1)
                                           };
                [[NSNotificationCenter defaultCenter] postNotificationName:DXLikeInfoDidChangeNotification object:nil userInfo:userInfo];
            }
        }];
        
    } else { // 取消赞
        cell.toolBar.likeView.like = NO;
        
        [[DXDongXiApi api] unlikeFeedWithFeedID:feed.fid result:^(BOOL success, NSError *error) {
            if (!success) {
                cell.toolBar.likeView.like = YES;
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后尝试";
                NSString * message = [NSString stringWithFormat:@"取消赞失败，%@", reason];
                [MBProgressHUD showHUDWithMessage:message];
            } else {
                
                NSDictionary *userInfo = @{
                                           kFeedIDKey     : feed.fid,
                                           kLikeStatusKey : @(0)
                                           };
                [[NSNotificationCenter defaultCenter] postNotificationName:DXLikeInfoDidChangeNotification object:nil userInfo:userInfo];
            }
        }];
    }
}

#pragma mark - 通知

- (void)registerNotification {
    
    // 删除feed通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldDeleteFeed:) name:DXDeleteFeedNotification object:nil];
    // 当用户登陆后时刷新整个feed列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeedList) name:DXDongXiApiNotificationUserDidLogin object:nil];
    // 当用户登出后时刷新整个feed列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeedList) name:DXDongXiApiNotificationUserDidLogout object:nil];
    // 点赞信息改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeLikeInfoNotification:) name:DXLikeInfoDidChangeNotification object:nil];
}

- (void)removeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDeleteFeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDongXiApiNotificationUserDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDongXiApiNotificationUserDidLogout object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXLikeInfoDidChangeNotification object:nil];
}

#pragma mark - 收到通知后执行的方法

- (void)shouldDeleteFeed:(NSNotification *)notification {
    
    NSString *deleteID = notification.object;
    
    [self.feeds enumerateObjectsUsingBlock:^(DXTimelineFeed *feed, NSUInteger idx, BOOL *stop) {
        if ([feed.fid isEqualToString:deleteID]) {
            [weakSelf.feeds removeObject:feed];
            [weakSelf.tableView reloadData];
            *stop = YES;
        }
    }];
}

- (void)refreshFeedList {
    
    [self.feeds removeAllObjects];
    if (self.tableView.mj_footer.hidden == NO) {
        self.tableView.mj_footer.hidden = YES;
    }
    // 首次加载
    [self fetchNewestFeedWrapperWithPullType:DXDataListPullFirstTime completion:nil];
}

- (void)handleChangeLikeInfoNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *feedID = [userInfo objectForKey:kFeedIDKey];
    BOOL isLike = [[userInfo objectForKey:kLikeStatusKey] boolValue];
    
    for (DXTimelineFeed *feed in self.feeds) {
        if ([feed.fid isEqualToString:feedID]) {
            
            NSString *myUid = [self.api currentUserSession].uid;
            NSMutableArray *temp = [NSMutableArray array];
            [temp addObjectsFromArray:feed.data.likes];
            
            if (isLike && !feed.data.is_like) {
                DXTimelineFeedLiker *liker = [[DXTimelineFeedLiker alloc] init];
                liker.uid = myUid;
                liker.avatar = [self.api currentUserSession].avatar;
                liker.verified = [self.api currentUserSession].verified;
                [temp insertObject:liker atIndex:0];
                feed.data.likes = temp;
                feed.data.total_like += 1;
                feed.data.is_like = isLike;
            }
            
            if (!isLike && feed.data.is_like) {
                for (DXTimelineFeedLiker *liker in temp) {
                    if ([liker.uid isEqualToString:myUid]) {
                        [temp removeObject:liker];
                        break;
                    }
                }
                feed.data.likes = temp;
                feed.data.total_like -= 1;
                feed.data.is_like = isLike;
            }
            [self.tableView reloadData];
            break;
        }
    }
}

#pragma mark - 懒加载

- (NSMutableArray *)feeds {
    
    if (_feeds == nil) {
        _feeds = [NSMutableArray array];
    }
    return _feeds;
}

- (DXDongXiApi *)api {
    
    if (_api == nil) {
        _api = [DXDongXiApi api];
    }
    return _api;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
