//
//  DXDetailViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDetailViewController.h"
#import "DXComposeViewController.h"
#import "DXLoginViewController.h"
#import "DXNoneDataTableViewCell.h"
#import "DXChatViewController.h"
#import "DXTopicViewController.h"
#import "DXFeedPublishViewController.h"

#import "DXFeedToolBar.h"
#import "DXCompatibleAlert.h"
#import "DXCommentHeaderView.h"
#import "DXShareView.h"

#import "DXDetailPhotosCell.h"
#import "DXDetailTextCell.h"
#import "DXDetailLocationCell.h"
#import "DXDetailLikeCell.h"
#import "DXCommentCell.h"
#import "DXNoContentCell.h"

#import "AppDelegate.h"
#import "DXDetailFeed.h"
#import "DXUserInfoManager.h"

#import "UIBarButtonItem+Extension.h"
#import "DXTimelineFeed+User.h"

#import <MJRefresh.h>


typedef void(^DXContentCompletionBlock)(NSError *error);
typedef void(^DXCommentCompletionBlock)(BOOL more, NSError *error);

static const CGFloat TopPaddingH    = 64.0f;
static const CGFloat BottomPaddingH = 49.0f;

@interface DXDetailViewController () <UITableViewDelegate, UITableViewDataSource, DXFeedToolBarDelegate, DXDetailTextCellDelegate, DXCommentCellDelegate, DXFeedPublishDelegateController>

@property (nonatomic, strong) DXDongXiApi *api;

@property (nonatomic, weak) DXFeedToolBar *toolBar;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *feedList;
@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, copy) NSString *errorDesc;

@property (nonatomic, strong) DXCommentHeaderView *headerView;

@property (nonatomic, assign) CGFloat contentSizeMinH;

@property (nonatomic, assign, getter=isContentCompletion) BOOL contentCompletion;
@property (nonatomic, assign, getter=isCommentCompletion) BOOL commentCompletion;

@end

@implementation DXDetailViewController

- (instancetype)initWithControllerType:(DXDetailViewControllerType)controllerType {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _controllerType = controllerType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_PhotoDetail;
    
    // 设置导航栏
    [self setupNavBar];
    
    // 创建底部工具栏
    [self setupToolBar];
    
    // 创建内容
    [self setupContent];
    
    // 添加下拉刷新
    self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    CGRect rect = [self.tableView rectForSection:0];
    CGFloat visibleH = DXScreenHeight - 49.0f - 64.0f;
    self.contentSizeMinH = rect.size.height + visibleH;
    
    // 设置tableView的偏移量
    if (self.detailType == DXDetailTypeComment && self.controllerType == DXDetailViewControllerTypeFeed) {
        [self.tableView setContentOffset:CGPointMake(0, rect.size.height) animated:NO];
    }
    
    // 添加键值观察者
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserDidLoginNotification:) name:DXDongXiApiNotificationUserDidLogin object:nil];
    
    // 加载数据
    [self loadNewData];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    [self.feedList removeAllObjects];
    
    DXDetailFeed *textFeed = [[DXDetailFeed alloc] init];
    textFeed.feed = feed;
    textFeed.feedType = DXDetailFeedTypeText;
    
    DXDetailFeed *photoFeed = [[DXDetailFeed alloc] init];
    photoFeed.feed = feed;
    photoFeed.feedType = DXDetailFeedTypePhoto;
    
    DXDetailFeed *loctionFeed = [[DXDetailFeed alloc] init];
    loctionFeed.feed = feed;
    loctionFeed.feedType = DXDetailFeedTypeLocation;
    
    DXDetailFeed *likeFeed = [[DXDetailFeed alloc] init];
    likeFeed.feed = feed;
    likeFeed.feedType = DXDetailFeedTypeLike;
    
    [self.feedList addObjectsFromArray:@[textFeed, photoFeed]];
    
    if (feed.data.place.length && feed.data.total_like) {
        [self.feedList addObjectsFromArray:@[loctionFeed, likeFeed]];
    } else if (!feed.data.place.length && feed.data.total_like) {
        [self.feedList addObject:likeFeed];
    } else if (feed.data.place.length && !feed.data.total_like) {
        [self.feedList addObject:loctionFeed];
    }
}

#pragma mark - 初始化
/**
 *  设置导航栏
 */
- (void)setupNavBar {
    
    self.title = @"查看详情";
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(backBtnDidClick)];
    
    if (![[DXDongXiApi api] needLogin] && self.controllerType == DXDetailViewControllerTypeFeed) {
        UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(didClickMoreItem)];
        self.navigationItem.rightBarButtonItem = moreItem;
    }
}

/**
 *  创建底部工具栏
 */
- (void)setupToolBar {
    
    DXFeedToolBar *toolBar = [[DXFeedToolBar alloc] initWithToolBarType:DXFeedToolBarTypeDetail];
    toolBar.frame = CGRectMake(0, DXScreenHeight - BottomPaddingH, DXScreenWidth, BottomPaddingH);
    toolBar.feed = self.feed;
    toolBar.delegate = self;
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
    if (self.controllerType == DXDetailViewControllerTypeFeedID) {
        toolBar.hidden = YES;
    }
    
    UIView *shadowView = [[UIView alloc] init];
    shadowView.backgroundColor = DXRGBColor(222, 222, 222);
    shadowView.frame = CGRectMake(0, 0, DXScreenWidth, 0.5);
    [self.toolBar addSubview:shadowView];
}

/**
 *  设置内容
 */
- (void)setupContent {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.contentInset = UIEdgeInsetsMake(0, 0, BottomPaddingH, 0);
    tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, BottomPaddingH, 0);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = DXRGBColor(222, 222, 222);
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view insertSubview:tableView belowSubview:self.toolBar];
    self.tableView = tableView;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    CGFloat currentContentSizeH = self.tableView.contentSize.height;
    
    CGRect rect = [self.tableView rectForSection:0];
    CGFloat visibleH = DXScreenHeight - 49.0f - 64.0f;
    self.contentSizeMinH = rect.size.height + visibleH;
    
    if (currentContentSizeH < self.contentSizeMinH && self.tableView.mj_header.state == MJRefreshStateIdle) {
        self.tableView.contentInset = UIEdgeInsetsMake(TopPaddingH, 0, self.contentSizeMinH - currentContentSizeH + BottomPaddingH, 0);
    } else if (currentContentSizeH >= self.contentSizeMinH) {
        if (self.tableView.mj_header.state == MJRefreshStateIdle && (self.tableView.mj_footer.state == MJRefreshStateIdle || !self.tableView.mj_footer)) {
            self.tableView.contentInset = UIEdgeInsetsMake(TopPaddingH, 0, BottomPaddingH, 0);
        }
    }
}

#pragma mark - contentSizeMinH

- (CGFloat)contentSizeMinHWithFeed:(DXTimelineFeed *)feed {
    
    CGFloat textCellHeight = [DXDetailTextCell tableView:nil heightForRowAtIndexPath:nil withFeed:feed];
    CGFloat photosCellHeight = [DXDetailPhotosCell tableView:nil heightForRowAtIndexPath:nil withFeed:feed];
    CGFloat locationCellHeight = 0;
    CGFloat likeCellHeight = 0;
    
    if (feed.data.place.length) {
        locationCellHeight = [DXDetailLocationCell tableView:nil heightForRowAtIndexPath:nil withFeed:feed];
    }
    if (feed.data.total_like) {
        likeCellHeight = [DXDetailLikeCell tableView:nil heightForRowAtIndexPath:nil withFeed:feed];
    }
    return textCellHeight + photosCellHeight + locationCellHeight + likeCellHeight;
}

#pragma mark - Notifications

- (void)onUserDidLoginNotification:(NSNotification *)noti {
    
    [self.dataList removeAllObjects];
    [self loadNewData];
    
//    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(didClickMoreItem)];
//    self.navigationItem.rightBarButtonItem = moreItem;
}

#pragma mark - 加载数据

/**
 *  加载新数据
 */
- (void)loadNewData {
    typeof(self) __weak weakSelf = self;
    [self loadDetailContentDataWithCompletion:^(NSError *error) {
        if (weakSelf.isContentCompletion && weakSelf.isCommentCompletion) {
            [weakSelf.tableView.mj_header endRefreshing];
        }
    }];
    
    [self loadDetailCommentDataWithPullType:DXDataListPullNewerList completion:^(BOOL more, NSError *error) {
        if (weakSelf.isContentCompletion && weakSelf.isCommentCompletion) {
            [weakSelf.tableView.mj_header endRefreshing];
        }
    }];
}

/**
 *  加载老数据
 */
- (void)loadOldData {
    typeof(self) __weak weakSelf = self;
    [self loadDetailCommentDataWithPullType:DXDataListPullOlderList completion:^(BOOL more, NSError *error) {
        if (more) {
            [weakSelf.tableView.mj_footer endRefreshing];
        } else {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}

/**
 *  加载feed内容数据
 */
- (void)loadDetailContentDataWithCompletion:(DXContentCompletionBlock)completionBlock {
    
    NSString *feedID;
    if (self.controllerType == DXDetailViewControllerTypeFeed) {
        feedID = self.feed.fid;
    } else {
        feedID = self.feedID;
    }
    typeof(self) __weak weakSelf = self;
    self.contentCompletion = NO;
    [[DXDongXiApi api] getFeedWithID:feedID result:^(DXTimelineFeed *feed, NSError *error) {
        weakSelf.contentCompletion = YES;
        if (feed) {
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            [DXUserInfoManager getNewestAvatarWithCurrentAvatar:feed.avatar updateTime:time forUID:feed.uid];
            [DXUserInfoManager getNewestNicknameWithCurrentNickname:feed.nick updateTime:time forUID:feed.uid];
            if (![[DXDongXiApi api] needLogin] && weakSelf.controllerType == DXDetailViewControllerTypeFeedID) {
                UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:weakSelf action:@selector(didClickMoreItem)];
                weakSelf.navigationItem.rightBarButtonItem = moreItem;
            }
            weakSelf.feed = feed;
            if (weakSelf.controllerType == DXDetailViewControllerTypeFeedID) {
                weakSelf.toolBar.hidden = NO;
            }
            weakSelf.toolBar.feed = feed;
            if (weakSelf.infoChangeBlock) {
                weakSelf.infoChangeBlock(feed);
            }
        } else {
            NSString *reson = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reson];
            if (weakSelf.feed) [MBProgressHUD showHUDWithMessage:weakSelf.errorDesc];
            
            if (!weakSelf.feed && weakSelf.controllerType == DXDetailViewControllerTypeFeedID) {
                weakSelf.navigationItem.rightBarButtonItem = nil;
                weakSelf.toolBar.hidden = YES;
            }
        }
        [weakSelf.tableView reloadData];
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

/**
 *  加载feed评论数据
 */
- (void)loadDetailCommentDataWithPullType:(DXDataListPullType)pullType completion:(DXCommentCompletionBlock)completionBlock {
    typeof(self) __weak weakSelf = self;
    DXComment *comment = nil;
    if (pullType == DXDataListPullNewerList) {
        comment = [weakSelf.dataList firstObject];
    } else if (pullType == DXDataListPullOlderList) {
        comment = [weakSelf.dataList lastObject];
    }
    
    if (comment == nil) {
        pullType = DXDataListPullFirstTime;
    }
    
    NSString *feedID;
    if (self.feed) {
        feedID = self.feed.fid;
    } else {
        feedID = self.feedID;
    }
    
    self.commentCompletion = NO;
    [[DXDongXiApi api] getCommentListByFeedID:feedID count:30 pullType:pullType lastID:comment.ID result:^(DXCommentList *commentList, NSError *error) {
        weakSelf.commentCompletion = YES;
        if (commentList.list.count) {
            if (pullType == DXDataListPullNewerList) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, commentList.list.count)];
                [weakSelf.dataList insertObjects:commentList.list atIndexes:indexSet];
            } else {
                [weakSelf.dataList addObjectsFromArray:commentList.list];
                // 添加上拉加载
                if (commentList.more && !weakSelf.tableView.mj_footer) {
                    weakSelf.tableView.mj_footer = [DXRefreshFooter footerWithRefreshingTarget:weakSelf refreshingAction:@selector(loadOldData)];
                }
            }
        } else {
            if (error && pullType == DXDataListPullOlderList) {
                NSString *reson = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reson];
                [MBProgressHUD showHUDWithMessage:weakSelf.errorDesc];
            }
        }
        [weakSelf.tableView reloadData];
        if (completionBlock) {
            completionBlock(commentList.more, error);
        }
    }];
}

#pragma mark - 数据源和代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.feedList.count) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.feedList.count) {
        if (section == 0) {
            return self.feedList.count;
        } else {
            return self.dataList.count;
        }
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.feedList.count) {
        
        if (indexPath.section == 0) {
            DXDetailFeed *detailFeed = self.feedList[indexPath.row];
            if (detailFeed.feedType == DXDetailFeedTypePhoto) {
                DXDetailPhotosCell *cell = [DXDetailPhotosCell cellWithTableView:tableView];
                cell.feed = detailFeed.feed;
                return cell;
            } else if (detailFeed.feedType == DXDetailFeedTypeText) {
                DXDetailTextCell *cell = [DXDetailTextCell cellWithTableView:tableView];
                cell.feed = detailFeed.feed;
                cell.delegate = self;
                return cell;
            } else if (detailFeed.feedType == DXDetailFeedTypeLocation) {
                DXDetailLocationCell *cell = [DXDetailLocationCell cellWithTableView:tableView];
                cell.feed = detailFeed.feed;
                return cell;
            } else {
                DXDetailLikeCell *cell = [DXDetailLikeCell cellWithTableView:tableView];
                cell.feed = detailFeed.feed;
                return cell;
            }
        } else {
            DXCommentCell *cell = [DXCommentCell cellWithTableView:tableView];
            DXComment *comment = self.dataList[indexPath.row];
            cell.comment = comment;
            cell.delegate = self;
            return cell;
        }
        
    } else {
        
        DXNoneDataTableViewCell *cell = [DXNoneDataTableViewCell cellWithTableView:tableView];
        cell.text = self.errorDesc;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.feedList.count) {
        if (indexPath.section == 0) {
            DXDetailFeed *detailFeed = self.feedList[indexPath.row];
            if (detailFeed.feedType == DXDetailFeedTypePhoto) {
                return [DXDetailPhotosCell tableView:tableView heightForRowAtIndexPath:indexPath withFeed:self.feed];
            } else if (detailFeed.feedType == DXDetailFeedTypeText) {
                return [DXDetailTextCell tableView:tableView heightForRowAtIndexPath:indexPath withFeed:self.feed];
            } else if (detailFeed.feedType == DXDetailFeedTypeLocation) {
                return [DXDetailLocationCell tableView:tableView heightForRowAtIndexPath:indexPath withFeed:self.feed];
            } else {
                return [DXDetailLikeCell tableView:tableView heightForRowAtIndexPath:indexPath withFeed:self.feed];
            }
        } else {
            DXComment *comment = self.dataList[indexPath.row];
            return [DXCommentCell tableView:tableView heightForRowAtIndexPath:indexPath withComment:comment];
        }
    } else {
        return DXRealValue(120.0f);
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.feedList.count) {
        if (indexPath.section == 0) {
            DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
            DXDetailFeed *detailFeed = self.feedList[indexPath.row];
            if (detailFeed.feedType == DXDetailFeedTypeLocation) {
                [nav pushToMapViewControllerWithFeed:self.feed info:nil];
            } else if (detailFeed.feedType == DXDetailFeedTypeLike) {
                [nav pushToLikerListViewControllerWithFeedID:self.feed.fid info:nil];
            }
        } else if (indexPath.section == 1) {
            
            DXComment *comment = self.dataList[indexPath.row];
            NSString *currentUid = [[DXDongXiApi api] currentUserSession].uid;
            if (![comment.uid isEqualToString:currentUid]) {
                [self showReplyAlertWithComment:comment];
            } else {
                [self showDeleteCommentAlertWithIndexPath:indexPath];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        return 37.0f;
    } else {
        return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        DXCommentHeaderView *headerView = [[DXCommentHeaderView alloc] init];
        headerView.frame = CGRectMake(0, 0, DXScreenWidth, DXRealValue(37.0f));
        headerView.num = self.feed.data.total_comments;
        self.headerView = headerView;
        return headerView;
    } else {
        return nil;
    }
}

#pragma mark - DXDetailTextCellDelegate

- (void)didTapAvatarViewInDetailTextCellWithUserID:(NSString *)userID {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

- (void)didTapTopicViewInDetailTextCellWithTopicID:(NSString *)topicID {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToTopicViewControllerWithTopicID:topicID info:nil];
}

- (void)detailTextCell:(DXDetailTextCell *)cell didSelectReferUserWithUserID:(NSString *)userID {
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

- (void)detailTextCell:(DXDetailTextCell *)cell didSelectReferTopicWithTopicID:(NSString *)topicID {
    DXTopicViewController *vc = [[DXTopicViewController alloc] init];
    vc.topicID = topicID;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - DXFeedToolBarDelegate

- (void)didTapLikeViewInFeedToolBarWithFeed:(DXTimelineFeed *)feed {
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
    
    NSString *myUid = [self.api currentUserSession].uid;
    NSString *myAvatar = [self.api currentUserSession].avatar;
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObjectsFromArray:feed.data.likes];
    
    if (!feed.data.is_like) { // 点赞
        weakSelf.toolBar.likeView.like = YES;
        
        [[DXDongXiApi api] likeFeedWithFeedID:feed.fid result:^(BOOL success, NSError *error) {
            if (success) {
                DXTimelineFeedLiker *liker = [[DXTimelineFeedLiker alloc] init];
                liker.uid = myUid;
                liker.avatar = myAvatar;
                liker.verified = [self.api currentUserSession].verified;
                [temp insertObject:liker atIndex:0];
                
                feed.data.likes = temp;
                feed.data.is_like = YES;
                feed.data.total_like += 1;
                [weakSelf.tableView reloadData];
                
                NSDictionary *userInfo = @{
                                           kFeedIDKey     : feed.fid,
                                           kLikeStatusKey : @(1)
                                           };
                [[NSNotificationCenter defaultCenter] postNotificationName:DXLikeInfoDidChangeNotification object:nil userInfo:userInfo];
                
            } else {
                weakSelf.toolBar.likeView.like = NO;
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                NSString * message = [NSString stringWithFormat:@"点赞失败，%@", reason];
                [MBProgressHUD showHUDWithMessage:message];
            }
        }];
    } else { // 取消赞
        weakSelf.toolBar.likeView.like = NO;
        
        [[DXDongXiApi api] unlikeFeedWithFeedID:feed.fid result:^(BOOL success, NSError *error) {
            if (success) {
                for (DXTimelineFeedLiker *liker in temp) {
                    if ([liker.uid isEqualToString:myUid]) {
                        [temp removeObject:liker];
                        break;
                    }
                }
                feed.data.likes = temp;
                feed.data.is_like = NO;
                feed.data.total_like -= 1;
                [weakSelf.tableView reloadData];
                
                NSDictionary *userInfo = @{
                                           kFeedIDKey     : feed.fid,
                                           kLikeStatusKey : @(0)
                                           };
                [[NSNotificationCenter defaultCenter] postNotificationName:DXLikeInfoDidChangeNotification object:nil userInfo:userInfo];
                
            } else {
                weakSelf.toolBar.likeView.like = NO;
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                NSString * message = [NSString stringWithFormat:@"取消赞失败，%@", reason];
                [MBProgressHUD showHUDWithMessage:message];
            }
        }];
    }
}

- (void)didTapCommentViewInFeedToolBarWithFeed:(DXTimelineFeed *)feed {
    typeof(self) __weak weakSelf = self;
    
    if ([[DXDongXiApi api] needLogin]) {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才可发表评论，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
        return;
    }
    
    DXCommentTemp *temp = [[DXCommentTemp alloc] init];
    temp.feedID = feed.fid;
    
    DXComposeViewController *vc = [[DXComposeViewController alloc] init];
    vc.composeType = DXComposeTypeComment;
    vc.temp = temp;
    vc.commentBlock = ^(DXComment *comment) {
        [weakSelf.dataList insertObject:comment atIndex:0];
        weakSelf.feed.data.total_comments += 1;
        weakSelf.headerView.num = weakSelf.feed.data.total_comments;
        [weakSelf.tableView reloadData];
        if (weakSelf.infoChangeBlock) {
            weakSelf.infoChangeBlock(weakSelf.feed);
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didTapChatViewInFeedToolBarWithFeed:(DXTimelineFeed *)feed {
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
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didTapShareViewInFeedToolBarWithFeed:(DXTimelineFeed *)feed {
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav showCollectionAndShareViewWithFeed:feed info:nil];
}

#pragma mark - DXCommentCellDelegate

- (void)commentCell:(DXCommentCell *)cell didTapAvatarViewWithUserID:(NSString *)userID {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

- (void)commentCell:(DXCommentCell *)cell didSelectReferUserWithUserID:(NSString *)userID {
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

- (void)commentCell:(DXCommentCell *)cell didSelectReferTopicWithTopicID:(NSString *)topicID {
    DXTopicViewController *vc = [[DXTopicViewController alloc] init];
    vc.topicID = topicID;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - DXFeedPublishDelegateController

- (void)feedPublishController:(DXFeedPublishViewController *)feedPublishController didPublishFeed:(DXTimelineFeed *)feed {
    self.feed = feed;
    self.toolBar.feed = feed;
    if (self.infoChangeBlock) {
        self.infoChangeBlock(feed);
    }
    [self.tableView reloadData];
}

#pragma mark - 点击按钮执行的方法

/**
 *  点击返回按钮
 */
- (void)backBtnDidClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *  点击更多按钮
 */
- (void)didClickMoreItem {
    
    [self showMoreAlert];
}

#pragma mark - 删除评论相关

/**
 *  展示删除评论Alert
 */
- (void)showDeleteCommentAlertWithIndexPath:(NSIndexPath *)indexPath {
    typeof(self) __weak weakSelf = self;
    
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleActionSheet];
    alert.title = @"是否要删除此评论？";
    
    DXCompatibleAlertAction *deleteCommentAction = [DXCompatibleAlertAction actionWithTitle:@"删除" style:DXCompatibleAlertActionStyleDestructive handler:^(DXCompatibleAlertAction *action) {
        [weakSelf deleteCommentWithIndexPath:indexPath];
    }];
    [alert addAction:deleteCommentAction];
    
    DXCompatibleAlertAction *cancelAction = [DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:^(DXCompatibleAlertAction *action) {
        DXLog(@"取消删除此评论");
    }];
    [alert addAction:cancelAction];
    
    [alert showInController:self animated:YES completion:nil];
}

/**
 *  删除评论
 */
- (void)deleteCommentWithIndexPath:(NSIndexPath *)indexPath {
    typeof(self) __weak weakSelf = self;
    DXComment *comment = self.dataList[indexPath.row];
    [self.api deleteCommentByCommentID:comment.ID result:^(BOOL success, NSError *error) {
        if (success) {
            [weakSelf.dataList removeObjectAtIndex:indexPath.row];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableView endUpdates];
            weakSelf.feed.data.total_comments -= 1;
            weakSelf.headerView.num = weakSelf.feed.data.total_comments;
            if (weakSelf.infoChangeBlock) {
                weakSelf.infoChangeBlock(weakSelf.feed);
            }
        } else {
            DXScreenNotice *notice = [[DXScreenNotice alloc] initWithMessage:@"删除失败" fromController:weakSelf.tabBarController];
            [notice show];
        }
    }];
}

#pragma mark - 回复评论相关

/**
 *  展示回复选项Alert
 */
- (void)showReplyAlertWithComment:(DXComment *)comment {
    if ([[DXDongXiApi api] needLogin]) {
        return;
    }
    
    typeof(self) __weak weakSelf = self;
    
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleActionSheet];
    alert.title = @"是否要回复此评论？";
    
    DXCompatibleAlertAction *replyAction = [DXCompatibleAlertAction actionWithTitle:@"回复" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
        [weakSelf replyWithComment:comment];
    }];
    [alert addAction:replyAction];
    
    DXCompatibleAlertAction *cancelAction = [DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:^(DXCompatibleAlertAction *action) {
        DXLog(@"取消回复此评论");
    }];
    [alert addAction:cancelAction];
    
    [alert showInController:self animated:YES completion:nil];
}

/**
 *  回复
 */
- (void)replyWithComment:(DXComment *)comment {
    typeof(self) __weak weakSelf = self;
    
    DXCommentTemp *temp = [[DXCommentTemp alloc] init];
    temp.feedID = self.feed.fid;
    temp.ID = comment.ID;
    temp.userID = comment.uid;
    temp.nick = comment.nick;
    
    DXComposeViewController *vc = [[DXComposeViewController alloc] init];
    vc.composeType = DXComposeTypeReply;
    vc.temp = temp;
    vc.commentBlock = ^(DXComment *comment) {
        [weakSelf.dataList insertObject:comment atIndex:0];
        weakSelf.feed.data.total_comments += 1;
        weakSelf.headerView.num = weakSelf.feed.data.total_comments;
        [weakSelf.tableView reloadData];
        if (weakSelf.infoChangeBlock) {
            weakSelf.infoChangeBlock(weakSelf.feed);
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 删除和举报feed相关

/**
 *  展示更多Alert
 */
- (void)showMoreAlert {
    typeof(self) __weak weakSelf = self;
    
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleActionSheet];
    
    if ([self.feed.uid isEqualToString:[[DXDongXiApi api] currentUserSession].uid]) {
        DXCompatibleAlertAction *editAction = [DXCompatibleAlertAction actionWithTitle:@"编辑" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            [weakSelf handleEditAction];
        }];
        DXCompatibleAlertAction *deleteAction = [DXCompatibleAlertAction actionWithTitle:@"删除" style:DXCompatibleAlertActionStyleDestructive handler:^(DXCompatibleAlertAction *action) {
            [weakSelf showdeleteAlert];
        }];
        
        [alert addAction:editAction];
        [alert addAction:deleteAction];
    } else {
        DXCompatibleAlertAction *reportAction = [DXCompatibleAlertAction actionWithTitle:@"举报" style:DXCompatibleAlertActionStyleDestructive handler:^(DXCompatibleAlertAction *action) {
            [weakSelf showReportAlert];
        }];
        [alert addAction:reportAction];
    }
    
    DXCompatibleAlertAction *cancelAction = [DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:^(DXCompatibleAlertAction *action) {
        DXLog(@"取消");
    }];
    [alert addAction:cancelAction];
    
    [alert showInController:self animated:YES completion:nil];
}
/**
 *  展示删除Alert
 */
- (void)showdeleteAlert {
    typeof(self) __weak weakSelf = self;
    
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleActionSheet];
    alert.title = @"是否确定删除";
    DXCompatibleAlertAction *confirmAction = [DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDestructive handler:^(DXCompatibleAlertAction *action) {
        [weakSelf deleteFeed];
    }];
    DXCompatibleAlertAction *cancelAction = [DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:^(DXCompatibleAlertAction *action) {
        DXLog(@"取消");
    }];
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    [alert showInController:self animated:YES completion:nil];
}
/**
 *  编辑feed
 */
- (void)handleEditAction {
    DXFeedPublishViewController *vc = [[DXFeedPublishViewController alloc] init];
    vc.feed = self.feed;
    vc.delegateController = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
/**
 *  展示举报Alert
 */
- (void)showReportAlert {
    typeof(self) __weak weakSelf = self;
    
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleActionSheet];
    alert.title = @"举报选项";
    NSArray *titleArray = @[@"垃圾营销", @"抄袭内容", @"血腥暴力", @"淫秽色情", @"政治敏感", @"其他"];
    for (int i=0; i<titleArray.count; i++) {
        NSString *title = titleArray[i];
        DXCompatibleAlertAction *action = [DXCompatibleAlertAction actionWithTitle:title style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            [weakSelf reportAlertWithType:i + 1];
        }];
        [alert addAction:action];
    }
    DXCompatibleAlertAction *cancelAction = [DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:^(DXCompatibleAlertAction *action) {
        DXLog(@"取消");
    }];
    [alert addAction:cancelAction];
    [alert showInController:self animated:YES completion:nil];
}
/**
 *  删除feed
 */
- (void)deleteFeed {
    typeof(self) __weak weakSelf = self;
    
    [[DXDongXiApi api] deleteFeedWithFeedID:self.feed.fid result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD showHUDWithMessage:@"删除成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:DXDeleteFeedNotification object:weakSelf.feed.fid];
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            NSString *message = [NSString stringWithFormat:@"删除失败，%@", reason];
            [MBProgressHUD showHUDWithMessage:message];
        }
    }];
}
/**
 *  举报feed
 */
- (void)reportAlertWithType:(NSInteger)type {
    
    [[DXDongXiApi api] reportFeedWithFeedID:self.feed.fid type:type result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD showHUDWithMessage:@"举报成功"];
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            NSString *message = [NSString stringWithFormat:@"举报失败，%@", reason];
            [MBProgressHUD showHUDWithMessage:message];
        }
    }];
}

#pragma mark - 懒加载

- (DXDongXiApi *)api {
    
    if (_api == nil) {
        _api = [DXDongXiApi api];
    }
    return _api;
}

- (NSMutableArray *)dataList {
    
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableArray *)feedList {
    
    if (_feedList == nil) {
        _feedList = [NSMutableArray array];
    }
    return _feedList;
}

@end
