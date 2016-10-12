//
//  DXHomeSelectionViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/6.
//  Copyright (c) 2015年 穆康. All rights reserved.
//

#import "DXHomeSelectionViewController.h"
#import "DXImagePlayerViewController.h"
#import "DXDetailViewController.h"
#import "DXLoginViewController.h"
#import "DXTopicViewController.h"
#import "DXChatViewController.h"

#import "DXFeedCell.h"
#import "DXFeedRecommendUserCell.h"
#import "DXFeedRecommendTopicCell.h"
#import "DXNoneDataTableViewCell.h"

#import "DXTimelineFeed+User.h"

#import <MJRefresh.h>

@interface DXHomeSelectionViewController () <DXFeedCellDelegate, DXFeedRecommendUserCellDelegate, DXFeedRecommendTopicCellDelegate>

@property (nonatomic, strong) DXDongXiApi *api;

@property (nonatomic, strong) NSMutableArray *feeds;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataList;
/** 存放推荐数据的数组 */
@property (nonatomic, strong) NSMutableArray *recommendations;
/** 推荐的数据 */
@property (nonatomic, strong) DXTimelineRecommendation *recommendation;
/** 推荐的人和话题的序号 */
@property (nonatomic, assign) NSUInteger recommendUserIndex;
@property (nonatomic, assign) NSUInteger recommendTopicIndex;
/** 每次推荐的人和话题的数量 */
@property (nonatomic, assign) NSUInteger recommendUserCount;
@property (nonatomic, assign) NSUInteger recommendTopicCount;
/** 需要获取的feed数量 */
@property (nonatomic, assign) NSUInteger fetchCount;
/** 间隔多少feed后插入推荐信息 */
@property (nonatomic, assign) NSUInteger intervalCount;
/** 起始多少条feed后插入推荐信息 */
@property (nonatomic, assign) NSUInteger beginCount;

@property (nonatomic, weak) DXImagePlayerViewController *imagePlayerVC;

/** 当前正在操作的cell的indexPath */
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
/** 错误信息描述 */
@property (nonatomic, copy) NSString *errorDesc;

@end

@implementation DXHomeSelectionViewController {
    __weak DXHomeSelectionViewController *weakSelf;
}

#pragma mark - 生命周期

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化数据
        self.recommendation = nil;
        self.recommendUserIndex = 0;
        self.recommendTopicIndex = 0;
        self.recommendUserCount = 4;
        self.recommendTopicCount = 2;
        self.fetchCount = 10;
        self.intervalCount = 33;
        self.beginCount = 5;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    self.dt_pageName = DXDataTrackingPage_HomeTimelineHot;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(DXRealValue(45), 0, 0, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    self.tableView.backgroundColor = DXRGBColor(222, 222, 222);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 添加上下拉刷新
    self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
    self.tableView.mj_footer.hidden = YES;
    
    // 设置轮播器
    [self setupHeader];
    
    // 首次获取数据
    [self loadDataFirst];
    
    // 注册通知
    [self registerNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // 设置轮播器的frame
//    [self setupHeaderFrame];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    
    // 移除通知
    [self removeNotification];
}

- (void)setupHeader {
    
    DXImagePlayerViewController *imagePlayerVC = [[DXImagePlayerViewController alloc] init];
    [self addChildViewController:imagePlayerVC];
    self.imagePlayerVC = imagePlayerVC;
}

- (void)setupHeaderFrame {
    
    self.imagePlayerVC.view.frame = CGRectMake(0, 0, DXScreenWidth, DXRealValue(140));
    self.tableView.tableHeaderView = self.imagePlayerVC.view;
}

#pragma mark - 获取数据

- (void)loadDataFirst {
    
    [self.api getTimelineHotList:DXDataListPullFirstTime count:self.fetchCount lastID:nil userTimestamp:0 topicTimestamp:0 result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
        if (feedWrapper) {
            [weakSelf.dataList addObjectsFromArray:feedWrapper.feeds];
            [weakSelf.feeds addObjectsFromArray:feedWrapper.feeds];
            
            if (weakSelf.recommendation.timestamp_for_user != feedWrapper.recommendation.timestamp_for_user) {
                weakSelf.recommendation.recommend_user = feedWrapper.recommendation.recommend_user;
                weakSelf.recommendation.timestamp_for_user = feedWrapper.recommendation.timestamp_for_user;
                weakSelf.recommendUserIndex = 0;
            }
            if (weakSelf.recommendation.timestamp_for_topic != feedWrapper.recommendation.timestamp_for_topic) {
                weakSelf.recommendation.recommend_topic = feedWrapper.recommendation.recommend_topic;
                weakSelf.recommendation.timestamp_for_topic = feedWrapper.recommendation.timestamp_for_topic;
                weakSelf.recommendTopicIndex = 0;
            }
            
            DXTimelineRecommendation *previousRecommendation = [weakSelf.recommendations lastObject];
            if (previousRecommendation) {
                NSUInteger index = [weakSelf.dataList indexOfObject:previousRecommendation];
                if (weakSelf.dataList.count - (index + 1) >= weakSelf.intervalCount) {
                    NSArray *recommendationArray = [weakSelf fetchCurrentTopicRecommendationAndUserRecommendation];
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1+weakSelf.intervalCount, recommendationArray.count)];
                    [weakSelf.dataList insertObjects:recommendationArray atIndexes:indexSet];
                    [weakSelf.recommendations addObjectsFromArray:recommendationArray];
                }
            } else {
                NSArray *recommendationArray = [weakSelf fetchCurrentTopicRecommendationAndUserRecommendation];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(weakSelf.beginCount, recommendationArray.count)];
                [weakSelf.dataList insertObjects:recommendationArray atIndexes:indexSet];
                [weakSelf.recommendations addObjectsFromArray:recommendationArray];
            }
            if (weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == weakSelf.fetchCount) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    [[DXDongXiApi api] getPictureShowList:^(DXPictureShowWrapper *pictureShowWrapper, NSError *error) {
        if (pictureShowWrapper.list.count) {
            [weakSelf setupHeaderFrame];
            weakSelf.imagePlayerVC.pictureShowWrapper = pictureShowWrapper;
        }
    }];
}

- (void)loadNewData {
    
    [self.api getTimelineHotList:DXDataListPullFirstTime count:self.fetchCount lastID:nil userTimestamp:0 topicTimestamp:0 result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
        if (feedWrapper) {
            
            [self.dataList removeAllObjects];
            [self.feeds removeAllObjects];
            [self.recommendations removeAllObjects];
            self.recommendation = nil;
            self.recommendUserIndex = 0;
            self.recommendTopicIndex = 0;
            if (self.tableView.mj_footer.hidden == NO) {
                self.tableView.mj_footer.hidden = YES;
            }
            
            [weakSelf.dataList addObjectsFromArray:feedWrapper.feeds];
            [weakSelf.feeds addObjectsFromArray:feedWrapper.feeds];
            
            if (weakSelf.recommendation.timestamp_for_user != feedWrapper.recommendation.timestamp_for_user) {
                weakSelf.recommendation.recommend_user = feedWrapper.recommendation.recommend_user;
                weakSelf.recommendation.timestamp_for_user = feedWrapper.recommendation.timestamp_for_user;
                weakSelf.recommendUserIndex = 0;
            }
            if (weakSelf.recommendation.timestamp_for_topic != feedWrapper.recommendation.timestamp_for_topic) {
                weakSelf.recommendation.recommend_topic = feedWrapper.recommendation.recommend_topic;
                weakSelf.recommendation.timestamp_for_topic = feedWrapper.recommendation.timestamp_for_topic;
                weakSelf.recommendTopicIndex = 0;
            }
            
            DXTimelineRecommendation *previousRecommendation = [weakSelf.recommendations lastObject];
            if (previousRecommendation) {
                NSUInteger index = [weakSelf.dataList indexOfObject:previousRecommendation];
                if (weakSelf.dataList.count - (index + 1) >= weakSelf.intervalCount) {
                    NSArray *recommendationArray = [weakSelf fetchCurrentTopicRecommendationAndUserRecommendation];
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1+weakSelf.intervalCount, recommendationArray.count)];
                    [weakSelf.dataList insertObjects:recommendationArray atIndexes:indexSet];
                    [weakSelf.recommendations addObjectsFromArray:recommendationArray];
                }
            } else {
                NSArray *recommendationArray = [weakSelf fetchCurrentTopicRecommendationAndUserRecommendation];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(weakSelf.beginCount, recommendationArray.count)];
                [weakSelf.dataList insertObjects:recommendationArray atIndexes:indexSet];
                [weakSelf.recommendations addObjectsFromArray:recommendationArray];
            }
            if (weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == weakSelf.fetchCount) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    [[DXDongXiApi api] getPictureShowList:^(DXPictureShowWrapper *pictureShowWrapper, NSError *error) {
        if (pictureShowWrapper.list.count) {
            [weakSelf setupHeaderFrame];
            weakSelf.imagePlayerVC.pictureShowWrapper = pictureShowWrapper;
        }
    }];
    
    /*
    DXTimelineFeed *feed = [self.feeds firstObject];
    DXDataListPullType pullType;
    if (feed.ID) {
        pullType = DXDataListPullNewerList;
    } else {
        pullType = DXDataListPullFirstTime;
    }
    
    [self.api getTimelineHotList:pullType count:self.fetchCount lastID:feed.ID userTimestamp:weakSelf.recommendation.timestamp_for_user topicTimestamp:weakSelf.recommendation.timestamp_for_topic result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
        if (feedWrapper) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, feedWrapper.feeds.count)];
            [weakSelf.dataList insertObjects:feedWrapper.feeds atIndexes:indexSet];
            [weakSelf.feeds insertObjects:feedWrapper.feeds atIndexes:indexSet];
            
            if (weakSelf.recommendation.timestamp_for_user != feedWrapper.recommendation.timestamp_for_user) {
                weakSelf.recommendation.recommend_user = feedWrapper.recommendation.recommend_user;
                weakSelf.recommendation.timestamp_for_user = feedWrapper.recommendation.timestamp_for_user;
                weakSelf.recommendUserIndex = 0;
            }
            if (weakSelf.recommendation.timestamp_for_topic != feedWrapper.recommendation.timestamp_for_topic) {
                weakSelf.recommendation.recommend_topic = feedWrapper.recommendation.recommend_topic;
                weakSelf.recommendation.timestamp_for_topic = feedWrapper.recommendation.timestamp_for_topic;
                weakSelf.recommendTopicIndex = 0;
            }
            
            DXTimelineRecommendation *previousRecommendation = [weakSelf.recommendations firstObject];
            if (previousRecommendation) {
                NSUInteger index = [weakSelf.dataList indexOfObject:previousRecommendation];
                if (index >= weakSelf.intervalCount) {
                    NSArray *recommendationArray = [weakSelf fetchCurrentTopicRecommendationAndUserRecommendation];
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index-weakSelf.intervalCount, recommendationArray.count)];
                    [weakSelf.dataList insertObjects:recommendationArray atIndexes:indexSet];
                    [weakSelf.recommendations insertObjects:recommendationArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, recommendationArray.count)]];
                }
            } else {
                NSArray *recommendationArray = [weakSelf fetchCurrentTopicRecommendationAndUserRecommendation];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(weakSelf.beginCount, recommendationArray.count)];
                [weakSelf.dataList insertObjects:recommendationArray atIndexes:indexSet];
                [weakSelf.recommendations addObjectsFromArray:recommendationArray];
            }
            if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer.isHidden && feedWrapper.feeds.count == weakSelf.fetchCount) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
            if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDesc];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    [[DXDongXiApi api] getPictureShowList:^(DXPictureShowWrapper *pictureShowWrapper, NSError *error) {
        if (pictureShowWrapper.list.count) {
            if (weakSelf.tableView.tableHeaderView == nil) {
                [weakSelf setupHeaderFrame];
            }
            weakSelf.imagePlayerVC.pictureShowWrapper = pictureShowWrapper;
        }
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
    
    [self.api getTimelineHotList:pullType count:self.fetchCount lastID:feed.ID userTimestamp:weakSelf.recommendation.timestamp_for_user topicTimestamp:weakSelf.recommendation.timestamp_for_topic result:^(DXTimelineFeedWrapper *feedWrapper, NSError *error) {
        if (feedWrapper) {
            [weakSelf.feeds addObjectsFromArray:feedWrapper.feeds];
            [weakSelf.dataList addObjectsFromArray:feedWrapper.feeds];
            
            if (weakSelf.recommendation.timestamp_for_user != feedWrapper.recommendation.timestamp_for_user) {
                weakSelf.recommendation.recommend_user = feedWrapper.recommendation.recommend_user;
                weakSelf.recommendation.timestamp_for_user = feedWrapper.recommendation.timestamp_for_user;
                weakSelf.recommendUserIndex = 0;
            }
            if (weakSelf.recommendation.timestamp_for_topic != feedWrapper.recommendation.timestamp_for_topic) {
                weakSelf.recommendation.recommend_topic = feedWrapper.recommendation.recommend_topic;
                weakSelf.recommendation.timestamp_for_topic = feedWrapper.recommendation.timestamp_for_topic;
                weakSelf.recommendTopicIndex = 0;
            }
            
            DXTimelineRecommendation *previousRecommendation = [weakSelf.recommendations lastObject];
            if (previousRecommendation) {
                NSUInteger index = [weakSelf.dataList indexOfObject:previousRecommendation];
                if (weakSelf.dataList.count - (index + 1) >= weakSelf.intervalCount) {
                    NSArray *recommendationArray = [weakSelf fetchCurrentTopicRecommendationAndUserRecommendation];
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1+weakSelf.intervalCount, recommendationArray.count)];
                    [weakSelf.dataList insertObjects:recommendationArray atIndexes:indexSet];
                    [weakSelf.recommendations addObjectsFromArray:recommendationArray];
                }
            } else {
                NSArray *recommendationArray = [weakSelf fetchCurrentTopicRecommendationAndUserRecommendation];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(weakSelf.beginCount, recommendationArray.count)];
                [weakSelf.dataList insertObjects:recommendationArray atIndexes:indexSet];
                [weakSelf.recommendations addObjectsFromArray:recommendationArray];
            }
            if (!feedWrapper.more) {
                weakSelf.tableView.mj_footer.hidden = YES;
            } else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
            if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDesc];
            DXRefreshAutoFooter *mjFooter = (DXRefreshAutoFooter *)weakSelf.tableView.mj_footer;
            [mjFooter endRefreshingWithError];
        }
        [weakSelf.tableView reloadData];
    }];
}

- (NSArray *)fetchCurrentTopicRecommendationAndUserRecommendation {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    if (weakSelf.recommendation.recommend_topic.count >= self.recommendTopicCount) {
        DXTimelineRecommendation *tempTopicRecommendation = [[DXTimelineRecommendation alloc] init];
        NSArray *topics = self.recommendation.recommend_topic;
        NSMutableArray *tempTopics = [NSMutableArray arrayWithCapacity:self.recommendTopicCount];
        for (NSUInteger i=0; i<self.recommendTopicCount; i++) {
            NSUInteger index = self.recommendTopicIndex % topics.count;
            self.recommendTopicIndex ++;
            [tempTopics addObject:topics[index]];
        }
        tempTopicRecommendation.recommend_topic = [tempTopics copy];
        tempTopicRecommendation.type = DXRecommendationTypeTopic;
        [tempArray addObject:tempTopicRecommendation];
    }
    if (weakSelf.recommendation.recommend_user.count >= self.recommendUserCount) {
        DXTimelineRecommendation *tempUserRecommendation = [[DXTimelineRecommendation alloc] init];
        NSArray *users = self.recommendation.recommend_user;
        NSMutableArray *tempUsers = [NSMutableArray arrayWithCapacity:self.recommendUserCount];
        for (NSUInteger i=0; i<self.recommendUserCount; i++) {
            NSUInteger index = self.recommendUserIndex % users.count;
            self.recommendUserIndex ++;
            [tempUsers addObject:users[index]];
        }
        tempUserRecommendation.recommend_user = [tempUsers copy];
        tempUserRecommendation.type = DXRecommendationTypeUser;
        [tempArray addObject:tempUserRecommendation];
    }
    
    return [tempArray copy];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.dataList.count) {
        return self.dataList.count;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        id obj = self.dataList[indexPath.row];
        if ([obj isKindOfClass:[DXTimelineFeed class]]) {
            static NSString *ID = @"selectionCell";
            DXFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[DXFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            }
            cell.feed = (DXTimelineFeed *)obj;
            cell.indexPath = indexPath;
            cell.delegate = self;
            return cell;
        } else {
            DXTimelineRecommendation *recommendation = (DXTimelineRecommendation *)obj;
            if (recommendation.type == DXRecommendationTypeUser) {
                static NSString *ID = @"FeedRecommendUserCell";
                DXFeedRecommendUserCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
                if (cell == nil) {
                    cell = [[DXFeedRecommendUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                }
                cell.recommendation = recommendation;
                cell.delegate = self;
                return cell;
            } else {
                static NSString *ID = @"FeedRecommendTopicCell";
                DXFeedRecommendTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
                if (cell == nil) {
                    cell = [[DXFeedRecommendTopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
                }
                cell.recommendation = recommendation;
                cell.delegate = self;
                return cell;
            }
        }
    } else {
        DXNoneDataTableViewCell *cell = [DXNoneDataTableViewCell cellWithTableView:tableView];
        cell.text = self.errorDesc;
        return cell;
    }
}

#pragma mark - Table view data delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        id obj = self.dataList[indexPath.row];
        if ([obj isKindOfClass:[DXTimelineFeed class]]) {
            DXTimelineFeed *feed = (DXTimelineFeed *)obj;
            return [DXFeedCell tableView:tableView heightForRowAtIndexPath:indexPath withFeed:feed];
        } else {
            DXTimelineRecommendation *recommendation = (DXTimelineRecommendation *)obj;
            if (recommendation.type == DXRecommendationTypeUser) {
                return DXRealValue(132);
            } else {
                return DXRealValue(123);
            }
        }
    } else {
        return DXRealValue(120);
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        id obj = self.dataList[indexPath.row];
        if ([obj isKindOfClass:[DXTimelineFeed class]]) {
            DXTimelineFeed *feed = (DXTimelineFeed *)obj;
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
    
    id obj = [self.dataList objectAtIndex:self.currentIndexPath.row];
    if ([obj isKindOfClass:[DXTimelineFeed class]]) {
        DXTimelineFeed *changeFeed = (DXTimelineFeed *)obj;
        changeFeed.data = feed.data;
        [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
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


#pragma mark - DXFeedRecommendUserCellDelegate

- (void)feedRecommendUserCell:(DXFeedRecommendUserCell *)cell didTapAvatarViewWithUser:(DXUser *)user {
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:user.uid info:nil];
}

#pragma mark - DXFeedRecommendTopicCellDelegate

- (void)feedRecommendTopicCell:(DXFeedRecommendTopicCell *)cell didTapTopicViewWithTopic:(DXTopic *)topic {
    DXTopicViewController * topicVC = [[DXTopicViewController alloc] init];
    topicVC.topicID = topic.topic_id;
    topicVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:topicVC animated:YES];
}

#pragma mark - 通知

- (void)registerNotification {
    
    // 删除feed通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldDeleteFeed:) name:DXDeleteFeedNotification object:nil];
    // 当用户登陆后时刷新整个feed列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataList) name:DXDongXiApiNotificationUserDidLogin object:nil];
    // 当用户登出后时刷新整个feed列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataList) name:DXDongXiApiNotificationUserDidLogout object:nil];
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
    
    for (DXTimelineFeed *feed in self.feeds) {
        if ([feed.fid isEqualToString:deleteID]) {
            [self.feeds removeObject:feed];
            break;
        }
    }
    for (id obj in self.dataList) {
        if ([obj isKindOfClass:[DXTimelineFeed class]]) {
            DXTimelineFeed *feed = (DXTimelineFeed *)obj;
            if ([feed.fid isEqualToString:deleteID]) {
                [self.dataList removeObject:feed];
                [weakSelf.tableView reloadData];
                break;
            }
        }
    }
}

/**
 *  重新刷新列表
 */
- (void)refreshDataList {
    
    [self.dataList removeAllObjects];
    [self.feeds removeAllObjects];
    [self.recommendations removeAllObjects];
    self.recommendation = nil;
    self.recommendUserIndex = 0;
    self.recommendTopicIndex = 0;
    if (self.tableView.mj_footer.hidden == NO) {
        self.tableView.mj_footer.hidden = YES;
    }
    
    [self loadDataFirst];
}

- (void)handleChangeLikeInfoNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *feedID = [userInfo objectForKey:kFeedIDKey];
    BOOL isLike = [[userInfo objectForKey:kLikeStatusKey] boolValue];
    
    for (id obj in self.dataList) {
        if ([obj isKindOfClass:[DXTimelineFeed class]]) {
            DXTimelineFeed *feed = (DXTimelineFeed *)obj;
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

- (NSMutableArray *)dataList {
    if (_dataList == nil) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (NSMutableArray *)recommendations {
    if (_recommendations == nil) {
        _recommendations = [[NSMutableArray alloc] init];
    }
    return _recommendations;
}

- (DXTimelineRecommendation *)recommendation {
    if (_recommendation == nil) {
        _recommendation = [[DXTimelineRecommendation alloc] init];
    }
    return _recommendation;
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
//    DXLog(@"selectionVC --- %f", scrollView.contentOffset.y);

//    CGFloat changeY = scrollView.contentOffset.y + scrollView.contentInset.top;
    
//    DXLog(@"--- %f", changeY);
//    
//    if (changeY > 0  && self.navBarIsHidden == NO) {
//        
////        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
////        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0);
//        [[NSNotificationCenter defaultCenter] postNotificationName:DXHomeNavBarShouldHiddenNotification object:nil];
//    } else if (changeY <= 0 && self.navBarIsHidden == YES) {
//        
////        self.tableView.contentInset = UIEdgeInsetsMake(108, 0, 49, 0);
////        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(108, 0, 49, 0);
//        [[NSNotificationCenter defaultCenter] postNotificationName:DXHomeNavBarShouldShowNotification object:nil];
//    }
    
//    if (scrollView.contentOffset.y > -86 && self.navBarIsHidden == NO) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:DXHomeNavBarShouldHiddenNotification object:nil];
//        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
//        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0);
//    } else if (scrollView.contentOffset.y < -86) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:DXHomeNavBarShouldHiddenNotification object:nil];
//        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
//        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0);
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
