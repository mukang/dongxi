//
//  DXProfileContentViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileContentViewController.h"
#import "UIImage+Extension.h"
#import "DXDongXiApi.h"
#import "DXFeedCell.h"
#import <MJRefresh.h>
#import "DXTimelineFeed+User.h"
#import "DXDetailViewController.h"
#import "DXNoneDataTableViewCell.h"
#import "DXLoginViewController.h"
#import "DXChatViewController.h"

@interface DXProfileContentViewController () <DXFeedCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, assign) BOOL shouldNoticeDelegate;

/** 当前正在操作的cell的indexPath */
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) NSMutableArray * feedsDeleteQueue;

@property (nonatomic, assign) BOOL firstTimeLoaded;
@property (nonatomic, assign) BOOL dataLoading;
@property (nonatomic, copy) NSString * errorDescription;

@end

@implementation DXProfileContentViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.backgroundColor = DXRGBColor(222, 222, 222);
        self.tableView.tableFooterView = [UIView new];
        [self.tableView registerClass:[DXNoneDataTableViewCell class] forCellReuseIdentifier:@"DXNoneDataTableViewCell"];
        self.tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
        self.tableView.mj_footer.hidden = YES;
        
        [self.view addSubview:self.tableView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldNoticeDelegate = YES;
    self.shouldScrollToTop = YES;
    
    if (self.type == DXProfileContentVCTypeJoin) {
        self.dt_pageName = DXDataTrackingPage_ProfileTimelineJoined;
    } else {
        self.dt_pageName = DXDataTrackingPage_ProfileTimelineSaved;
    }
    
    // 添加上拉加载更多
    
    
    [self getNetDataFirstTime];
    
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self deleteFeedsInQueue];
}


- (void)dealloc {
    [self removeNotifications];
}

- (void)getNetDataFirstTime {
    
    if (self.uid == nil) {
        return;
    }
    
    if (self.firstTimeLoaded) {
        return;
    }
    
    if (self.dataLoading) {
        return;
    }
    
    self.dataLoading = YES;
    
    NSString * role = [self.uid isEqualToString:[DXDongXiApi api].currentUserSession.uid] ? @"您" : @"Ta";
    
    __weak typeof(self) weakSelf = self;
    if (self.type == DXProfileContentVCTypeJoin) {
        [[DXDongXiApi api] getPrivateFeedListOfUser:self.uid pullType:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
            weakSelf.firstTimeLoaded = YES;
            weakSelf.dataLoading = NO;

            if (feedWrapper) {
                if (feedWrapper.feeds.count) {
                    [weakSelf.dataList removeAllObjects];
                    [weakSelf.dataList addObjectsFromArray:feedWrapper.feeds];
                }
                
                if (weakSelf.dataList.count == 0) {
                    weakSelf.errorDescription = [NSString stringWithFormat:@"%@还没有参与任何话题", role];
                }
                
                if (weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                    weakSelf.tableView.mj_footer.hidden = NO;
                }
            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍候再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
            }
            
            [weakSelf.tableView reloadData];
        }];
        
    } else {
        [[DXDongXiApi api] getSavedFeedListOfUser:self.uid pullType:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
            weakSelf.firstTimeLoaded = YES;
            weakSelf.dataLoading = NO;
            
            if (feedWrapper) {
                if (feedWrapper.feeds.count) {
                    [weakSelf.dataList removeAllObjects];
                    [weakSelf.dataList addObjectsFromArray:feedWrapper.feeds];
                }
                
                if (weakSelf.dataList.count == 0) {
                    weakSelf.errorDescription = [NSString stringWithFormat:@"%@还没有收藏任何内容", role];
                }
                
                if (weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                    weakSelf.tableView.mj_footer.hidden = NO;
                }
            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍候再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
            }
            [weakSelf.tableView reloadData];
        }];
    }
}

- (void)loadNewData {
    if (self.uid == nil) {
        return;
    }
    
    if (self.dataLoading) {
        return;
    }
    
    self.refreshCompletion = NO;
    __weak typeof(self) weakSelf = self;
    self.dataLoading = YES;
    NSString * role = [self.uid isEqualToString:[DXDongXiApi api].currentUserSession.uid] ? @"您" : @"Ta";
    if (self.type == DXProfileContentVCTypeJoin) {
        [[DXDongXiApi api] getPrivateFeedListOfUser:self.uid pullType:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
            weakSelf.firstTimeLoaded = YES;
            weakSelf.dataLoading = NO;
            
            if (feedWrapper) {
                if (feedWrapper.feeds.count) {
                    [weakSelf.dataList removeAllObjects];
//                    weakSelf.tableView.mj_footer.hidden = YES;
                    [weakSelf.dataList addObjectsFromArray:feedWrapper.feeds];
                }
                
                if (weakSelf.dataList.count == 0) {
                    weakSelf.errorDescription = [NSString stringWithFormat:@"%@还没有参与任何话题", role];
                }
                
                if (weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                    weakSelf.tableView.mj_footer.hidden = NO;
                }
            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍候再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.tableView reloadData];
            weakSelf.refreshCompletion = YES;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(contentControllerDidEndRefresh:)]) {
                [weakSelf.delegate contentControllerDidEndRefresh:weakSelf];
            }
        }];
    } else {
        [[DXDongXiApi api] getSavedFeedListOfUser:self.uid pullType:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
            
            weakSelf.firstTimeLoaded = YES;
            weakSelf.dataLoading = NO;
            
            if (feedWrapper) {
                if (feedWrapper.feeds.count) {
                    [weakSelf.dataList removeAllObjects];
//                    weakSelf.tableView.mj_footer.hidden = YES;
                    [weakSelf.dataList addObjectsFromArray:feedWrapper.feeds];
                }
                
                if (weakSelf.dataList.count == 0) {
                    weakSelf.errorDescription = [NSString stringWithFormat:@"%@还没有收藏任何内容", role];
                }
                
                if (weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                    weakSelf.tableView.mj_footer.hidden = NO;
                }
            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍候再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.tableView reloadData];
            weakSelf.refreshCompletion = YES;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(contentControllerDidEndRefresh:)]) {
                [weakSelf.delegate contentControllerDidEndRefresh:weakSelf];
            }
        }];
    }
    
    /*
    DXTimelineFeed *feed = [self.dataList firstObject];
    __weak typeof(self) weakSelf = self;
    
    DXDataListPullType pullType = DXDataListPullNewerList;
    if (!feed.ID) {
        pullType = DXDataListPullFirstTime;
    }
    
    self.dataLoading = YES;
    
    NSString * role = [self.uid isEqualToString:[DXDongXiApi api].currentUserSession.uid] ? @"您" : @"Ta";
    
    if (self.type == DXProfileContentVCTypeJoin) {
        [[DXDongXiApi api] getPrivateFeedListOfUser:self.uid pullType:pullType count:10 lastID:feed.ID result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
            weakSelf.firstTimeLoaded = YES;
            weakSelf.dataLoading = NO;
            
            if (feedWrapper) {
                if (feedWrapper.feeds.count) {
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, feedWrapper.feeds.count)];
                    [weakSelf.dataList insertObjects:feedWrapper.feeds atIndexes:indexSet];
                }
                
                if (weakSelf.dataList.count == 0) {
                    weakSelf.errorDescription = [NSString stringWithFormat:@"%@还没有参与任何话题", role];
                }
                
                if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                    weakSelf.tableView.mj_footer.hidden = NO;
                }
            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍候再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.tableView reloadData];
            weakSelf.refreshCompletion = YES;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(contentControllerDidEndRefresh:)]) {
                [weakSelf.delegate contentControllerDidEndRefresh:weakSelf];
            }
        }];
    } else {
        [[DXDongXiApi api] getSavedFeedListOfUser:self.uid pullType:pullType count:10 lastID:feed.ID result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
            
            weakSelf.firstTimeLoaded = YES;
            weakSelf.dataLoading = NO;
            
            if (feedWrapper) {
                if (feedWrapper.feeds.count) {
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, feedWrapper.feeds.count)];
                    [weakSelf.dataList insertObjects:feedWrapper.feeds atIndexes:indexSet];
                }
                
                if (weakSelf.dataList.count == 0) {
                    weakSelf.errorDescription = [NSString stringWithFormat:@"%@还没有收藏任何内容", role];
                }
                
                if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                    weakSelf.tableView.mj_footer.hidden = NO;
                }
            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍候再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.tableView reloadData];
            weakSelf.refreshCompletion = YES;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(contentControllerDidEndRefresh:)]) {
                [weakSelf.delegate contentControllerDidEndRefresh:weakSelf];
            }
        }];
    }
     */
}

- (void)loadOldData {
    if (self.uid == nil) {
        return;
    }
    
    if (self.dataLoading) {
        return;
    }
    
    DXTimelineFeed *feed = [self.dataList lastObject];
    __weak typeof(self) weakSelf = self;
    
    DXDataListPullType pullType = DXDataListPullOlderList;
    if (!feed.ID) {
        pullType = DXDataListPullFirstTime;
    }
    
    self.dataLoading = YES;
    
    NSString * role = [self.uid isEqualToString:[DXDongXiApi api].currentUserSession.uid] ? @"您" : @"Ta";
    
    if (self.type == DXProfileContentVCTypeJoin) {
        [[DXDongXiApi api] getPrivateFeedListOfUser:self.uid pullType:pullType count:10 lastID:feed.ID result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
            weakSelf.firstTimeLoaded = YES;
            weakSelf.dataLoading = NO;
            
            [weakSelf.tableView.mj_footer endRefreshing];
            if (feedWrapper) {
                if (feedWrapper.feeds.count) {
                    [weakSelf.dataList addObjectsFromArray:feedWrapper.feeds];
                }
                if (weakSelf.dataList.count == 0) {
                    weakSelf.errorDescription = [NSString stringWithFormat:@"%@还没有参与任何话题", role];
                }
            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍候再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.tableView reloadData];
            if (!feedWrapper.more && !error) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    } else {
        [[DXDongXiApi api] getSavedFeedListOfUser:self.uid pullType:pullType count:10 lastID:feed.ID result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
            weakSelf.firstTimeLoaded = YES;
            weakSelf.dataLoading = NO;
            
            [weakSelf.tableView.mj_footer endRefreshing];
            if (feedWrapper) {
                if (feedWrapper.feeds.count) {
                    [weakSelf.dataList addObjectsFromArray:feedWrapper.feeds];
                }
                if (weakSelf.dataList.count == 0) {
                    weakSelf.errorDescription = [NSString stringWithFormat:@"%@还没有收藏任何内容", role];
                }
            } else {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍候再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.tableView reloadData];
            
            DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.tableView.mj_footer;
            if (error) {
                [footer endRefreshingWithError];
            } else {
                if (feedWrapper.more) {
                    [footer endRefreshing];
                } else {
                    footer.hidden = YES;
                }
            }
        }];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    
    self.shouldNoticeDelegate = NO;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
}

- (NSMutableArray *)dataList {
    
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableArray *)feedsDeleteQueue {
    if (nil == _feedsDeleteQueue) {
        _feedsDeleteQueue = [NSMutableArray array];
    }
    return _feedsDeleteQueue;
}

- (void)setUid:(NSString *)uid {
    if (![_uid isEqualToString:uid]) {
        _uid = uid;
        _firstTimeLoaded = NO;
        [self.dataList removeAllObjects];
        [self loadNewData];
    } else {
        _uid = uid;
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataList.count == 0 && self.firstTimeLoaded) {
        return 1;
    } else {
        return self.dataList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataList.count > 0) {
        static NSString *ID = @"selectionCell";
        
        DXFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        if (cell == nil) {
            cell = [[DXFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        
        cell.feed = self.dataList[indexPath.row];
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        return cell;
    } else {
        DXNoneDataTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXNoneDataTableViewCell" forIndexPath:indexPath];
        cell.maxTextCenterY = DXRealValue(60);
        cell.text = self.errorDescription;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataList.count > 0) {
        DXTimelineFeed *feed = self.dataList[indexPath.row];
        return [DXFeedCell tableView:tableView heightForRowAtIndexPath:indexPath withFeed:feed];
    } else {
        CGFloat tabBarHeight = 0;
        if (self.tabBarController.tabBar && self.tabBarController.tabBar.hidden == NO) {
            tabBarHeight = CGRectGetHeight(self.tabBarController.tabBar.frame);
        }
        return DXScreenHeight - 64 - DXRealValue(44) - tabBarHeight;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.shouldNoticeDelegate) {
        self.shouldNoticeDelegate = YES;
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentController:didScroll:)]) {
        [self.delegate contentController:self didScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentController:DidEndDragging:)]) {
        [self.delegate contentController:self DidEndDragging:scrollView];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return self.shouldScrollToTop;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataList.count > 0) {
        DXTimelineFeed *feed = self.dataList[indexPath.row];
        self.currentIndexPath = indexPath;
        
        __weak typeof(self) weakSelf = self;
        
        DXDetailViewController *vc = [[DXDetailViewController alloc] init];
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
    /** 用户个人页点击头像不做任何反应 */
    if ([userID isEqualToString:self.uid] == NO) {
        DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
        [nav pushToProfileViewControllerWithUserID:userID info:nil];
    }
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
    typeof(self) __weak weakSelf = self;
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
    
    __weak typeof(self) weakSelf = self;
    
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
    typeof(self) __weak weakSelf = self;
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
    __weak typeof(self) weakSelf = self;
    
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
    
    DXTimelineFeed *changeFeed = [self.dataList objectAtIndex:self.currentIndexPath.row];
    changeFeed.data = feed.data;
    [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

/**
 *  点赞信息需要改变
 */
- (void)likeInfoShouldChangeWithFeed:(DXTimelineFeed *)feed cell:(DXFeedCell *)cell {
    
    if (!feed.data.is_like) { // 要点赞
        cell.toolBar.likeView.like = YES;
        
        [[DXDongXiApi api] likeFeedWithFeedID:feed.fid result:^(BOOL success, NSError *error) {
            if (!success) { // 点赞没有成功
                cell.toolBar.likeView.like = NO;
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
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
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
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

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldDeleteFeed:) name:DXDeleteFeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFeedUnsaveNotification:) name:DXUncollectionFeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFeedSaveNotification:) name:DXCollectionFeedNotification object:nil];
    // 当用户登成功后需要刷新数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataList) name:DXDongXiApiNotificationUserDidLogin object:nil];
    // 点赞信息改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeLikeInfoNotification:) name:DXLikeInfoDidChangeNotification object:nil];
}

- (void)removeNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)shouldDeleteFeed:(NSNotification *)notification {
    // “我参与的”和“我收藏的”都要处理删除feed通知
    NSString *deleteID = notification.object;
    // 处理删除通知时，不用管该个人页是否当前登陆用户的个人页
    if (deleteID) {
        [self.feedsDeleteQueue addObject:deleteID];
        [self deleteFeedsInQueue];
    }
}

- (void)handleFeedUnsaveNotification:(NSNotification *)noti {
    // 仅“我收藏的”要处理取消收藏feed通知
    if (self.type == DXProfileContentVCTypeCollect) {
        NSString * feedID = [noti.userInfo objectForKey:kFeedIDKey];
        // 处理取消收藏feed通知时，要看该个人页是否是当前登陆用户的个人页
        if (feedID && [self.uid isEqualToString:[[DXDongXiApi api] currentUserSession].uid]) {
            [self.feedsDeleteQueue addObject:feedID];
            [self deleteFeedsInQueue];
        }
    }
}

- (void)handleFeedSaveNotification:(NSNotification *)noti {

}

- (void)deleteFeedsInQueue {
    __weak typeof(self) weakSelf = self;
    [self.dataList enumerateObjectsUsingBlock:^(DXTimelineFeed *feed, NSUInteger idx, BOOL *stop) {
        NSInteger indexInQueue = [weakSelf.feedsDeleteQueue indexOfObject:feed.fid];
        if (indexInQueue != NSNotFound) {
            [weakSelf.dataList removeObjectAtIndex:idx];
            [weakSelf.feedsDeleteQueue removeObjectAtIndex:indexInQueue];
            
            if (weakSelf.dataList.count == 0) {
                NSString * role = @"你";
                if (![weakSelf.uid isEqualToString:[DXDongXiApi api].currentUserSession.uid]) {
                    role = @"Ta";
                }
                if (weakSelf.type == DXProfileContentVCTypeJoin) {
                    weakSelf.errorDescription = [NSString stringWithFormat:@"%@还没有参与任何话题", role];
                } else {
                    weakSelf.errorDescription = [NSString stringWithFormat:@"%@还没有收藏任何内容", role];;
                }
            }
            [weakSelf.tableView reloadData];
        }
    }];
}

/**
 *  刷新数据
 */
- (void)refreshDataList {
    
    [self.dataList removeAllObjects];
    self.firstTimeLoaded = NO;
    if (!self.tableView.mj_footer.isHidden) {
        self.tableView.mj_footer.hidden = YES;
    }
    [self getNetDataFirstTime];
}


- (void)handleChangeLikeInfoNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *feedID = [userInfo objectForKey:kFeedIDKey];
    BOOL isLike = [[userInfo objectForKey:kLikeStatusKey] boolValue];
    
    for (DXTimelineFeed *feed in self.dataList) {
        if ([feed.fid isEqualToString:feedID]) {
            
            NSString *myUid = [[DXDongXiApi api] currentUserSession].uid;
            NSMutableArray *temp = [NSMutableArray array];
            [temp addObjectsFromArray:feed.data.likes];
            
            if (isLike && !feed.data.is_like) {
                DXTimelineFeedLiker *liker = [[DXTimelineFeedLiker alloc] init];
                liker.uid = myUid;
                liker.avatar = [[DXDongXiApi api] currentUserSession].avatar;
                liker.verified = [[DXDongXiApi api] currentUserSession].verified;
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

@end
