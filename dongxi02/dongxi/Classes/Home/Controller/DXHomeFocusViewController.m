//
//  DXHomeFocusViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/6.
//  Copyright (c) 2015年 穆康. All rights reserved.
//

#import "DXHomeFocusViewController.h"
#import "DXMainNavigationController.h"
#import "DXChatViewController.h"
#import "DXFeedCell.h"
#import <MJRefresh.h>
#import "DXTimelineFeed+User.h"
#import "DXDetailViewController.h"
#import "DXLoginViewController.h"
#import "DXAnonymousFocusViewController.h"
#import "DXNoneDataTableViewCell.h"

@interface DXHomeFocusViewController () <DXFeedCellDelegate>

@property (nonatomic, strong) DXDongXiApi *api;

@property (nonatomic, strong) NSMutableArray *feeds;

/** 当前正在操作的cell的indexPath */
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) DXAnonymousFocusViewController *anonymousFocusVC;

/** 错误信息描述 */
@property (nonatomic, copy) NSString *errorDesc;

@end

@implementation DXHomeFocusViewController {
    __weak DXHomeFocusViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    self.dt_pageName = DXDataTrackingPage_HomeTimelineFollow;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(DXRealValue(45), 0, 0, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    self.tableView.backgroundColor = DXRGBColor(222, 222, 222);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([[DXDongXiApi api] needLogin]) {
        [self addChildViewController:self.anonymousFocusVC];
        [self.anonymousFocusVC didMoveToParentViewController:self];
        [self.view addSubview:self.anonymousFocusVC.view];
    } else {
        // 添加上下拉刷新
        self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        self.tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
        self.tableView.mj_footer.hidden = YES;
        // 首次获取数据
        [self loadDataFirst];
    }
    
    // 注册通知
    [self registerNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)dealloc {
    
    // 移除通知
    [self removeNotification];
}

#pragma mark - 获取数据

- (void)loadDataFirst {
    
    [[DXDongXiApi api] getTimelinePublicList:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
        if (feedWrapper.feeds.count) {
            [weakSelf.feeds addObjectsFromArray:feedWrapper.feeds];
            if (weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        } else {
            weakSelf.errorDesc = @"目前没有关注内容";
            if (error) {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
            }
        }
        [weakSelf.tableView reloadData];
    }];
}

- (void)loadNewData {
    
    [[DXDongXiApi api] getTimelinePublicList:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
        if (feedWrapper.feeds.count) {
            weakSelf.tableView.mj_footer.hidden = YES;
            [weakSelf.feeds removeAllObjects];
            [weakSelf.feeds addObjectsFromArray:feedWrapper.feeds];
            if (weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        } else {
            weakSelf.errorDesc = @"目前没有关注内容";
            if (error) {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
            }
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    
    /*
    DXTimelineFeed *feed = [self.feeds firstObject];
    DXDataListPullType pullType;
    if (feed.ID) {
        pullType = DXDataListPullNewerList;
    } else {
        pullType = DXDataListPullFirstTime;
    }
    
    [[DXDongXiApi api] getTimelinePublicList:pullType count:10 lastID:feed.ID result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
        
        if (feedWrapper.feeds.count) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, feedWrapper.feeds.count)];
            [weakSelf.feeds insertObjects:feedWrapper.feeds atIndexes:indexSet];
            
            if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == 10) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        } else {
            weakSelf.errorDesc = @"目前没有关注内容";
            if (error) {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.feeds.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDesc];
            }
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
     */
}

- (void)loadOldData {
    
    DXTimelineFeed *feed = [self.feeds lastObject];
    DXDataListPullType pullType;
    if (feed.ID) {
        pullType = DXDataListPullOlderList;
    } else {
        pullType = DXDataListPullFirstTime;
    }
    
    [[DXDongXiApi api] getTimelinePublicList:pullType count:10 lastID:feed.ID result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
        
        if (feedWrapper.feeds.count) {
            [weakSelf.feeds addObjectsFromArray:feedWrapper.feeds];
            if (!feedWrapper.more) {
                weakSelf.tableView.mj_footer.hidden = YES;
            } else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
            if (weakSelf.feeds.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDesc];
            DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.tableView.mj_footer;
            [footer endRefreshingWithError];
        }
        
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.feeds.count) {
        return self.feeds.count;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.feeds.count) {
        static NSString *ID = @"focusCell";
        
        DXFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        if (cell == nil) {
            cell = [[DXFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        
        cell.feed = self.feeds[indexPath.row];
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        return cell;
    } else {
        
        DXNoneDataTableViewCell *cell = [DXNoneDataTableViewCell cellWithTableView:tableView];
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
    
    if (self.feeds.count)  {
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
    // 当用户登陆后时刷新整个feed列表并移除需要登录页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeedList) name:DXDongXiApiNotificationUserDidLogin object:nil];
    // 当用户登出后时移除整个feed列表并添加需要登录页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanFeedList) name:DXDongXiApiNotificationUserDidLogout object:nil];
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
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView reloadData];
            *stop = YES;
        }
    }];
}

- (void)refreshFeedList {
    
    [self.anonymousFocusVC willMoveToParentViewController:nil];
    [self.anonymousFocusVC removeFromParentViewController];
    [self.anonymousFocusVC.view removeFromSuperview];
    
    // 添加上下拉刷新
    self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [DXRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
    self.tableView.mj_footer.hidden = YES;
    
    [self.feeds removeAllObjects];
    [self loadDataFirst];
}

- (void)cleanFeedList {
    
    [self addChildViewController:self.anonymousFocusVC];
    [self.anonymousFocusVC didMoveToParentViewController:self];
    [self.view addSubview:self.anonymousFocusVC.view];
    [self.view bringSubviewToFront:self.anonymousFocusVC.view];
    
    // 添加上下拉刷新
    self.tableView.mj_header = nil;
    self.tableView.mj_footer = nil;
    
    [self.feeds removeAllObjects];
    [self.tableView reloadData];
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

- (DXDongXiApi *)api {
    
    if (_api == nil) {
        _api = [DXDongXiApi api];
    }
    return _api;
}

- (NSMutableArray *)feeds {
    
    if (_feeds == nil) {
        _feeds = [NSMutableArray array];
    }
    return _feeds;
}

- (DXAnonymousFocusViewController *)anonymousFocusVC {
    
    if (_anonymousFocusVC == nil) {
        _anonymousFocusVC = [[DXAnonymousFocusViewController alloc] init];
    }
    return _anonymousFocusVC;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    DXLog(@"focusVC --- %f", scrollView.contentOffset.y);
//    
//    if (scrollView.contentOffset.y > 0) {
//        
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//        
//        
//    }
//}


//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    
//    if (velocity.y > 0 && self.navBarIsHidden == NO) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:DXHomeNavBarShouldHiddenNotification object:nil];
//        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
//        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0);
//    } else if (velocity.y < 0 && self.navBarIsHidden == YES && scrollView.contentOffset.y < 128) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:DXHomeNavBarShouldShowNotification object:nil];
//        self.tableView.contentInset = UIEdgeInsetsMake(108, 0, 49, 0);
//        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(108, 0, 49, 0);
//    }
//}



@end
