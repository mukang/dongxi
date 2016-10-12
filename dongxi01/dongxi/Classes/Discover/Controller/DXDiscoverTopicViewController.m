//
//  DXDiscoverTopicViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDiscoverTopicViewController.h"
#import "DXTopicViewController.h"

#import "DXTabBarView.h"

#import "DXTopTopicsView.h"

#import "DXTopicHeaderCell.h"
#import "DXHotTopicTableViewCell.h"
#import "DXNoneDataTableViewCell.h"
#import "DXCollectedTopicsCell.h"

#import "DXDongXiApi.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Extension.h"
#import <MJRefresh.h>

typedef void(^DXFetchTopicsCompletionBlock)();
//typedef void(^DXFetchCollectedTopicsCompletionBlock)();
//typedef void(^DXFetchTopAndHotTopicsCompletionBlock)(BOOL more, NSError *error);

@interface DXDiscoverTopicViewController ()<UITableViewDataSource, UITableViewDelegate, DXTopTopicsViewDelegate, DXCollectedTopicsCellDelegate>

@property (nonatomic, strong) NSMutableArray *topTopics;
@property (nonatomic, strong) NSMutableArray *hotTopics;
@property (nonatomic, strong) NSMutableArray *collectedTopics;

@property (nonatomic, strong) DXTopTopicsView * topTopicsView;

@property (nonatomic, strong) DXDongXiApi * api;

@property (nonatomic, assign, getter=isFetchCollectedTopicsFinished) BOOL fetchCollectedTopicsFinished;
@property (nonatomic, assign, getter=isFetchTopAndHotTopicsFinished) BOOL fetchTopAndHotTopicsFinished;

@property (nonatomic, assign) BOOL firstTimeLoaded;
@property (nonatomic, copy) NSString * errorDescription;

@end

@implementation DXDiscoverTopicViewController {
    __weak DXDiscoverTopicViewController *weakSelf;
}

#pragma mark - ViewController生命周期


- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    
    self.title = @"发现";
    self.dt_pageName = DXDataTrackingPage_DiscoverTopics;
    
    [self loadSubViews];
    
    self.api = [DXDongXiApi api];
    
    // 添加下拉刷新
    self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    // 添加上拉刷新
//    self.tableView.footer = [DXRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
    
    [self loadNewData];
    
    [self registerNotification];
}

- (void)dealloc {
    [self removeNotification];
}

// 加载新数据
- (void)loadNewData {
    
    [self fetchCollectedTopicsWithCompletion:^{
        if (weakSelf.isFetchCollectedTopicsFinished && weakSelf.isFetchTopAndHotTopicsFinished) {
            [weakSelf updateTopTopicsView];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
        }
    }];
    
    [self fetchTopAndHotTopicsWithCompletion:^{
        if (weakSelf.isFetchCollectedTopicsFinished && weakSelf.isFetchTopAndHotTopicsFinished) {
            [weakSelf updateTopTopicsView];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
        }
    }];
}

- (void)fetchCollectedTopicsWithCompletion:(DXFetchTopicsCompletionBlock)completionBlock {
    
    NSString *lastID = nil;
    NSUInteger pullType = DXDataListPullFirstTime;
    NSUInteger count = 100;
    
    self.fetchCollectedTopicsFinished = NO;
    [self.api getCollectedTopicListWithLastID:lastID pullType:pullType count:count result:^(DXCollectedTopicList *collectedTopicList, NSError *error) {
        if (!error) {
            [weakSelf.collectedTopics removeAllObjects];
            if (collectedTopicList.list.count) {
                [weakSelf.collectedTopics addObjectsFromArray:collectedTopicList.list];
            }
        }
        weakSelf.fetchCollectedTopicsFinished = YES;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)fetchTopAndHotTopicsWithCompletion:(DXFetchTopicsCompletionBlock)completionBlock {
    
    self.fetchTopAndHotTopicsFinished = NO;
    [self.api getTopAndHotTopicList:^(DXTopAndHotTopicList *topAndHotTopicList, NSError *error) {
        if (topAndHotTopicList.top.count) {
            [weakSelf.topTopics removeAllObjects];
            [weakSelf.topTopics addObjectsFromArray:topAndHotTopicList.top];
        }
        if (topAndHotTopicList.list.count) {
            [weakSelf.hotTopics removeAllObjects];
            [weakSelf.hotTopics addObjectsFromArray:topAndHotTopicList.list];
        } else {
            weakSelf.errorDescription = @"暂无话题";
            if (error) {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.hotTopics.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
        }
        self.fetchTopAndHotTopicsFinished = YES;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

/*

// 加载新数据
- (void)loadNewData {
    
    [self fetchCollectedTopicsWithCompletion:^{
        if (weakSelf.isFetchCollectedTopicsFinished && weakSelf.isFetchTopAndHotTopicsFinished) {
            [weakSelf updateTopTopicsView];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.header endRefreshing];
        }
    }];
    
    [self fetchTopAndHotTopicsWithPullType:DXDataListPullNewerList completion:^(BOOL more, NSError *error) {
        if (weakSelf.isFetchCollectedTopicsFinished && weakSelf.isFetchTopAndHotTopicsFinished) {
            [weakSelf updateTopTopicsView];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.header endRefreshing];
        }
    }];
}

// 加载老数据
- (void)loadOldData {

    [self fetchTopAndHotTopicsWithPullType:DXDataListPullOlderList completion:^(BOOL more, NSError *error) {
        if (!error) {
            [weakSelf.tableView reloadData];
            if (more) {
                [weakSelf.tableView.footer endRefreshing];
            } else {
                [weakSelf.tableView.footer endRefreshingWithNoMoreData];
            }
        } else {
            [weakSelf.tableView.footer endRefreshing];
        }
    }];
}

- (void)fetchCollectedTopicsWithCompletion:(DXFetchCollectedTopicsCompletionBlock)completionBlock {
    
    NSString *lastID = nil;
    NSUInteger pullType = DXDataListPullFirstTime;
    NSUInteger count = 100;
    
    self.fetchCollectedTopicsFinished = NO;
    [self.api getCollectedTopicListWithLastID:lastID pullType:pullType count:count result:^(DXCollectedTopicList *collectedTopicList, NSError *error) {
        if (collectedTopicList.list.count) {
            [weakSelf.collectedTopics removeAllObjects];
            [weakSelf.collectedTopics addObjectsFromArray:collectedTopicList.list];
        }
        weakSelf.fetchCollectedTopicsFinished = YES;
        if (completionBlock) {
            completionBlock();
        }
    }];
}


- (void)fetchTopAndHotTopicsWithPullType:(DXDataListPullType)pullType completion:(DXFetchTopAndHotTopicsCompletionBlock)completionBlock {
    
    DXTopic *hotTopic = nil;
    NSUInteger needFetchCount = 20;    // 需要从服务器获取的热门话题条数
    if (pullType == DXDataListPullNewerList) {
        hotTopic = [self.hotTopics firstObject];
    } else if (pullType == DXDataListPullOlderList) {
        hotTopic = [self.hotTopics lastObject];
    }
    
    if (hotTopic == nil) {
        pullType = DXDataListPullFirstTime;
    }
    
    self.fetchTopAndHotTopicsFinished = NO;
    [self.api getTopAndHotTopicListWithLastID:hotTopic.topic_id pullType:pullType count:needFetchCount result:^(DXTopAndHotTopicList *topAndHotTopicList, NSError *error) {
        if (topAndHotTopicList.top.count && pullType != DXDataListPullOlderList) {
            [weakSelf.topTopics removeAllObjects];
            [weakSelf.topTopics addObjectsFromArray:topAndHotTopicList.top];
        }
        if (topAndHotTopicList.list.count) {
            if (pullType == DXDataListPullNewerList) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, topAndHotTopicList.list.count)];
                [weakSelf.hotTopics insertObjects:topAndHotTopicList.list atIndexes:indexSet];
            } else {
                [weakSelf.hotTopics addObjectsFromArray:topAndHotTopicList.list];
            }
        }
        if (error && weakSelf.hotTopics.count) {
            weakSelf.errorDescription = error.localizedDescription ? error.localizedDescription : @"请稍后重试";
            DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
            [alert setMessage:weakSelf.errorDescription];
            [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:nil]];
            [alert showInController:weakSelf animated:YES completion:nil];
        }
        self.fetchTopAndHotTopicsFinished = YES;
        if (completionBlock) {
            completionBlock(topAndHotTopicList.more, error);
        }
    }];
}

*/

/**
 *  更新推荐话题视图
 */
- (void)updateTopTopicsView {
    
    CGFloat placeHolderImageLength = DXScreenWidth/2;
    UIImage * placeHolderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(placeHolderImageLength, placeHolderImageLength)];
    if (self.topTopics.count > 0) {
        DXTopic * firstTopTopic = [self.topTopics objectAtIndex:0];
        self.topTopicsView.firstTopTopicView.topTypeLabel.text = firstTopTopic.has_prize ? @"有奖话题" : @"推荐话题";
        self.topTopicsView.firstTopTopicView.topicLabel.text = [NSString stringWithFormat:@"#%@#", firstTopTopic.topic];
        self.topTopicsView.firstTopTopicView.subTitleLabel.text = firstTopTopic.title;
        [self.topTopicsView.firstTopTopicView.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:firstTopTopic.thumb] placeholderImage:placeHolderImage options:SDWebImageRetryFailed];
    } else {
        [self.topTopicsView.firstTopTopicView.backgroundImageView setImage:placeHolderImage];
    }
    
    if (self.topTopics.count > 1) {
        DXTopic * secondTopTopic = [weakSelf.topTopics objectAtIndex:1];
        self.topTopicsView.secondTopTopicView.topTypeLabel.text = secondTopTopic.has_prize ? @"有奖话题" : @"推荐话题";
        self.topTopicsView.secondTopTopicView.topicLabel.text = [NSString stringWithFormat:@"#%@#", secondTopTopic.topic];
        self.topTopicsView.secondTopTopicView.subTitleLabel.text = secondTopTopic.title;
        [self.topTopicsView.secondTopTopicView.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:secondTopTopic.thumb] placeholderImage:placeHolderImage options:SDWebImageRetryFailed];
    } else {
        [self.topTopicsView.secondTopTopicView.backgroundImageView setImage:placeHolderImage];
    }
    
    if (self.topTopics.count == 0) {
        self.tableView.tableHeaderView = nil;
    } else {
        self.tableView.tableHeaderView = weakSelf.topTopicsView;
    }
}


/*
- (void)loadNetData {
 
    __weak typeof(self) weakSelf = self;
    [self.api getTopics:^(NSArray *topics, NSError *error) {
        weakSelf.firstTimeLoaded = YES;
        [weakSelf.tableView.header endRefreshing];
        
        if (topics) {
            [weakSelf.topTopics removeAllObjects];
            [weakSelf.hotTopics removeAllObjects];
            
            for (DXTopic * topic in topics) {
                if (topic.is_top && self.topTopics.count < 2) {
                    [weakSelf.topTopics addObject:topic];
                } else {
                    [weakSelf.hotTopics addObject:topic];
                }
            }
            
            CGFloat placeHolderImageLength = DXScreenWidth/2;
            UIImage * placeHolderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(placeHolderImageLength, placeHolderImageLength)];
            if (weakSelf.topTopics.count > 0) {
                DXTopic * firstTopTopic = [weakSelf.topTopics objectAtIndex:0];
                weakSelf.topTopicsView.firstTopTopicView.topicLabel.text = [NSString stringWithFormat:@"#%@#", firstTopTopic.topic];
                [weakSelf.topTopicsView.firstTopTopicView.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:firstTopTopic.thumb] placeholderImage:placeHolderImage options:SDWebImageRetryFailed];
            } else {
                [weakSelf.topTopicsView.firstTopTopicView.backgroundImageView setImage:placeHolderImage];
            }
            
            if (weakSelf.topTopics.count > 1) {
                DXTopic * secondTopTopic = [weakSelf.topTopics objectAtIndex:1];
                weakSelf.topTopicsView.secondTopTopicView.topicLabel.text = [NSString stringWithFormat:@"#%@#", secondTopTopic.topic];
                [weakSelf.topTopicsView.secondTopTopicView.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:secondTopTopic.thumb] placeholderImage:placeHolderImage options:SDWebImageRetryFailed];
            } else {
                [weakSelf.topTopicsView.secondTopTopicView.backgroundImageView setImage:placeHolderImage];
            }
            
            if (weakSelf.hotTopics.count == 0) {
                weakSelf.errorDescription = @"暂无话题";
            }
        } else {
            if (error.localizedDescription) {
                weakSelf.errorDescription = error.localizedDescription;
            } else {
                weakSelf.errorDescription = @"请稍后重试";
            }
            
            if (weakSelf.hotTopics.count > 0) {
                DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                [alert setMessage:weakSelf.errorDescription];
                [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:nil]];
                [alert showInController:weakSelf animated:YES completion:nil];
            }
        }
        
        if (weakSelf.topTopics.count == 0) {
            weakSelf.tableView.tableHeaderView = nil;
        } else {
            weakSelf.tableView.tableHeaderView = weakSelf.topTopicsView;
        }
        
        [weakSelf.tableView reloadData];
    }];
}
 */

#pragma mark - Property Methods

- (NSMutableArray *)topTopics {
    if (nil == _topTopics) {
        _topTopics = [NSMutableArray array];
    }
    return _topTopics;
}

- (NSMutableArray *)hotTopics {
    if (nil == _hotTopics) {
        _hotTopics = [NSMutableArray array];
    }
    return _hotTopics;
}

- (NSMutableArray *)collectedTopics {
    if (_collectedTopics == nil) {
        _collectedTopics = [[NSMutableArray alloc] init];
    }
    return _collectedTopics;
}

#pragma mark - Private Methods

- (void)loadSubViews {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = DXRGBColor(0xde, 0xde, 0xde);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.tableView];
    
    self.topTopicsView = [[DXTopTopicsView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, 0)];
    self.topTopicsView.delegate = self;
    
    [self.tableView registerClass:[DXNoneDataTableViewCell class] forCellReuseIdentifier:@"DXNoneDataTableViewCell"];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (self.hotTopics.count && self.collectedTopics.count) {
            return 2;
        }
        return 0;
    } else {
        if (self.hotTopics.count) {
            return self.hotTopics.count + 1;
        }
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
//            NSString * reuseIdentifier = [NSString stringWithFormat:@"Collected Topic Cell Header"];
//            UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
//                cell.backgroundColor = [UIColor clearColor];
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                DXDashTitleView *dashTitleView = [[DXDashTitleView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXRealValue(43.3f))];
//                dashTitleView.backgroundColor = [UIColor whiteColor];
//                dashTitleView.textLabel.text = @"收藏话题";
//                [cell addSubview:dashTitleView];
//            }
//            return cell;
            NSString * reuseIdentifier = @"Topic Header Cell";
            DXTopicHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil) {
                cell = [[DXTopicHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            }
            cell.title = @"收藏话题";
            cell.separateView.hidden = YES;
            return cell;
        } else {
            NSString * reuseIdentifier = [NSString stringWithFormat:@"Collected Topic Cell"];
            DXCollectedTopicsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil) {
                cell = [[DXCollectedTopicsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            }
            cell.collectedTopics = [self.collectedTopics copy];
            cell.delegate = self;
            return cell;
        }
    } else {
        if (indexPath.item == 0) {
            if (self.hotTopics.count == 0) {
                DXNoneDataTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"DXNoneDataTableViewCell" forIndexPath:indexPath];
                cell.text = self.errorDescription;
                return cell;
            } else {
//                NSString * reuseIdentifier = [NSString stringWithFormat:@"Topic Cell Header"];
//                UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//                if (cell == nil) {
//                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
//                    cell.backgroundColor = [UIColor clearColor];
//                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                    DXDashTitleView *dashTitleView = [[DXDashTitleView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXRealValue(43.3f))];
//                    dashTitleView.backgroundColor = DXRGBColor(0xde, 0xde, 0xde);
//                    dashTitleView.textLabel.text = @"热门话题";
//                    [cell addSubview:dashTitleView];
//                }
//                return cell;
                NSString * reuseIdentifier = @"Topic Header Cell";
                DXTopicHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
                if (cell == nil) {
                    cell = [[DXTopicHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                }
                cell.title = @"热门话题";
                cell.separateView.hidden = NO;
                return cell;
            }
        } else {
            NSString * reuseIdentifier = [NSString stringWithFormat:@"Topic Cell"];
            DXHotTopicTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil) {
                cell = [[DXHotTopicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            }
            DXTopic * topic = [self.hotTopics objectAtIndex:indexPath.row-1];
            cell.topicLabel.text = topic.topic;
            [cell.topicLabel sizeToFit];
            cell.activeness = topic.activeness;
            cell.subTitleLabel.text = topic.title;
            [cell.subTitleLabel sizeToFit];
            cell.isCollected = topic.is_like;
            cell.hasPrize = topic.has_prize;
            UIImage * placeHolderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(64.0f), DXRealValue(64.0f))];
            [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:topic.thumb] placeholderImage:placeHolderImage options:SDWebImageRetryFailed];
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            return DXRealValue(43.3f);
        }
        return roundf(DXRealValue(25/3.0)) + roundf(DXRealValue(84)) + DXRealValue(20/3.0);
    } else {
        if (indexPath.item == 0) {
            if (self.hotTopics.count == 0) {
                return DXRealValue(120);
            }
            return DXRealValue(43.3f);
        }
        return DXRealValue(78.0f);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row != 0) {
        DXTopic * topic = [self.hotTopics objectAtIndex:indexPath.row-1];
        DXTopicViewController * topicVC = [[DXTopicViewController alloc] init];
        topicVC.topicID = topic.topic_id;
        [topicVC setUpdateTopicBlock:^(DXTopicDetail *topicDetail) {
            [weakSelf updateTopicWithtopicDetail:topicDetail];
        }];
        topicVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:topicVC animated:YES];
    }
}

#pragma mark - DXCollectedTopicsCellDelegate

- (void)collectedTopicsCell:(DXCollectedTopicsCell *)cell didTapTopicPhotoWithTopic:(DXTopic *)topic {
    
    DXTopicViewController * topicVC = [[DXTopicViewController alloc] init];
    topicVC.topicID = topic.topic_id;
    [topicVC setUpdateTopicBlock:^(DXTopicDetail *topicDetail) {
        [weakSelf updateTopicWithtopicDetail:topicDetail];
    }];
    topicVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:topicVC animated:YES];
}


#pragma mark - DXTopTopicsViewDelegate

- (void)topTopicsView:(DXTopTopicsView *)topicsView didSelectAtIndex:(NSUInteger)index {
    if (self.topTopics.count > index) {
        DXTopic * topic = [self.topTopics objectAtIndex:index];
        DXTopicViewController * topicVC = [[DXTopicViewController alloc] init];
        topicVC.topicID = topic.topic_id;
        topicVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:topicVC animated:YES];
    }
}

#pragma mark - 更新topic
/**
 *  更新topic
 */
- (void)updateTopicWithtopicDetail:(DXTopicDetail *)topicDetail {
    
    if (!topicDetail) return;
    
    NSString *topicID = topicDetail.topic_id;
//    for (int i=0; i<self.hotTopics.count; i++) {
//        DXTopic *hotTopic = self.hotTopics[i];
//        if ([hotTopic.topic_id isEqualToString:topicID]) {
//            hotTopic.activeness = topicDetail.activeness;
//            hotTopic.is_like = topicDetail.is_like;
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1 inSection:1];
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        }
//    }
    BOOL isChange = NO;
    for (DXTopic *hotTopic in self.hotTopics) {
        if ([hotTopic.topic_id isEqualToString:topicID]) {
            if (hotTopic.is_like != topicDetail.is_like) {
                isChange = YES;
            }
            break;
        }
    }
    if (isChange) {
        [self loadNewData];
    }
}

#pragma mark - 刷新整个页面
/**
 *  刷新整个页面
 */
- (void)refreshTopics {
//    [self.topTopics removeAllObjects];
//    [self.hotTopics removeAllObjects];
//    [self.collectedTopics removeAllObjects];
    [self loadNewData];
}

#pragma mark - 注册和移除通知
/**
 *  注册通知
 */
- (void)registerNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTopics) name:DXDongXiApiNotificationUserDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTopics) name:DXDongXiApiNotificationUserDidLogout object:nil];
}
/**
 *  移除通知
 */
- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDongXiApiNotificationUserDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDongXiApiNotificationUserDidLogout object:nil];
}

@end
