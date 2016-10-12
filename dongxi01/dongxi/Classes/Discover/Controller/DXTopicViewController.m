//
//  DXTopicViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicViewController.h"
#import "DXDetailViewController.h"
#import "DXTopicInviteViewController.h"
#import "DXTopicRankViewController.h"
#import "DXFeedPublishViewController.h"
#import "DXPhotoTakerController.h"
#import "DXProfileViewController.h"
#import "DXDetailViewController.h"
#import "DXLoginViewController.h"
#import "DXChatViewController.h"
#import "DXWebViewController.h"

#import "DXDongXiApi.h"
#import "DXMobileConfig.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MJRefresh.h>

#import "DXTopicHeaderView.h"
#import "DXFeedCell.h"
#import "DXNoneDataTableViewCell.h"

#import "DXTimelineFeed+User.h"
#import "UIBarButtonItem+Extension.h"


@interface DXTopicViewController () <UITableViewDataSource, UITableViewDelegate, DXTabBarViewDelegate, DXTopicHeaderViewDelegate, DXPhotoTakerControllerDelegate, UINavigationControllerDelegate, DXFeedCellDelegate, DXFeedPublishDelegateController>

@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, strong) DXTopicHeaderView * headerView;

@property (nonatomic, assign) CGFloat tableSwitchBarHeight;
@property (nonatomic, strong) DXTabBarView * tableSwitchBar;

@property (nonatomic, strong) UIButton * joinButton;

@property (nonatomic, strong) DXDongXiApi * api;

@property (nonatomic, strong) DXTopicDetail * topicDetail;
/** 排行榜 */
@property (nonatomic, strong) NSArray *rank;

@property (nonatomic, strong) NSMutableArray * manualFeedList;
@property (nonatomic, strong) NSMutableArray * feedList;
@property (nonatomic, strong) NSMutableArray * hotFeedList;

@property (nonatomic, assign) BOOL tableViewDataFirstTimeLoaded;
@property (nonatomic, assign) BOOL tableViewFirstTimeLoading;
@property (nonatomic, assign) BOOL hotTableViewDataFirstTimeLoaded;

@property (nonatomic, assign) CGPoint lastTableViewOffset;
@property (nonatomic, assign) CGPoint lastHotTableViewOffset;

/** 当前正在操作的cell的indexPath */
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

- (void)loadMorePreviousData:(void(^)(BOOL more, NSError *error))completionBlock;
- (void)loadMoreNewData:(void(^)(BOOL more, NSError *error))completionBlock;

@property (nonatomic, assign) BOOL firstTimeLoaded;
@property (nonatomic, copy) NSString * errorDescription;

@end

@implementation DXTopicViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_TopicTimeline;
    
    self.title = @"话题";
    self.view.backgroundColor = DXRGBColor(0xde, 0xde, 0xde);
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(back)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"邀请" style:UIBarButtonItemStylePlain target:self action:@selector(inviteButtonTapped:)];
    
    [self loadSubViews];
    [self tabBarView:self.tableSwitchBar didTapButtonAtIndex:0];
    // 注册通知
    [self registerNotifications];
    
    // 添加下拉刷新
    self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.hotTableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    
    [self.tableView registerClass:[DXNoneDataTableViewCell class] forCellReuseIdentifier:@"DXNoneDataTableViewCell"];
    [self.hotTableView registerClass:[DXNoneDataTableViewCell class] forCellReuseIdentifier:@"DXNoneDataTableViewCell"];
}

- (void)dealloc {
    
    // 移除通知
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

- (void)selectTableAtIndex:(NSInteger)index {
    [self.tableSwitchBar selectIndex:0];
    [self tabBarView:self.tableSwitchBar didTapButtonAtIndex:index];
}

- (void)insertFeed:(DXTimelineFeed *)feed atRow:(NSUInteger)row inTable:(NSUInteger)tableIndex {
    if (!feed) {
        return;
    }
    
    if (tableIndex == 0) {
        
        if (row <= self.manualFeedList.count) {
            [self.manualFeedList insertObject:feed atIndex:row];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:1];
            if (self.feedList.count || self.manualFeedList.count > 1) {
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView endUpdates];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            } else {
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark - Private Methods

- (void)loadSubViews {
    self.headerView = [[DXTopicHeaderView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, 0)];
    self.headerView.delegate = self;
    
    self.tableView = [[DXTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.hidden = YES;
    
    self.hotTableView = [[DXTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.hotTableView.backgroundColor = [UIColor clearColor];
    self.hotTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.hotTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.hotTableView.dataSource = self;
    self.hotTableView.delegate = self;
    self.hotTableView.hidden = YES;
    
    self.tableSwitchBarHeight = DXRealValue(44.0f);
    self.tableSwitchBar = [[DXTabBarView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, self.tableSwitchBarHeight) tabCount:2 names:@[@"最新", @"精选"]];
    self.tableSwitchBar.contentInsets = UIEdgeInsetsMake(0, DXRealValue(35), 0, DXRealValue(35));
    self.tableSwitchBar.backgroundColor = DXRGBColor(0xf7, 0xfa, 0xfb);
    self.tableSwitchBar.delegate = self;
    
    self.joinButton = [[UIButton alloc] initWithFrame:CGRectZero];
    UIImage * joinButtonNormalImage = [UIImage imageNamed:@"button_bottom_join_normal"];
    UIImage * joinButtonHighlightImage = [UIImage imageNamed:@"button_bottom_join_click"];
    [self.joinButton setImage:joinButtonNormalImage forState:UIControlStateNormal];
    [self.joinButton setImage:joinButtonHighlightImage forState:UIControlStateHighlighted];
    CGFloat joinButtonScale = DXScreenWidth/joinButtonNormalImage.size.width;
    CGSize joinButtonSize = CGSizeMake(roundf(joinButtonScale * joinButtonNormalImage.size.width),
                                       roundf(joinButtonScale * joinButtonNormalImage.size.height));
    CGPoint joinButtonOrigin = CGPointMake(0, self.view.bounds.size.height - joinButtonSize.height);
    self.joinButton.frame = CGRectMake(joinButtonOrigin.x, joinButtonOrigin.y, joinButtonSize.width, joinButtonSize.height);
    [self.joinButton addTarget:self action:@selector(joinButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.joinButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.joinButton];
    self.joinButton.hidden = YES;
    
    // 按钮
    UIButton *discussButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [discussButton setImage:[UIImage imageNamed:@"discover_topic_discuss_button"] forState:UIControlStateNormal];
    [discussButton addTarget:self action:@selector(discussButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat discussButtonWidth = DXRealValue(67.5);
    CGFloat discussButtonHeight = discussButtonWidth;
    CGFloat discussButtonCenterX = self.view.width - DXRealValue(40);
    CGFloat discussButtonCenterY = self.view.height - DXRealValue(318/3.0);
    discussButton.size = CGSizeMake(discussButtonWidth, discussButtonHeight);
    discussButton.center = CGPointMake(discussButtonCenterX, discussButtonCenterY);
    discussButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:discussButton];
    
    // 按钮
    UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinButton setImage:[UIImage imageNamed:@"discover_topic_join_button"] forState:UIControlStateNormal];
    [joinButton addTarget:self action:@selector(joinButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat joinButtonWidth = discussButtonWidth;
    CGFloat joinButtonHeight = discussButtonHeight;
    CGFloat joinButtonCenterX = discussButtonCenterX;
    CGFloat joinButtonCenterY = self.view.height - DXRealValue(121/3.0);
    joinButton.size = CGSizeMake(joinButtonWidth, joinButtonHeight);
    joinButton.center = CGPointMake(joinButtonCenterX, joinButtonCenterY);
    joinButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:joinButton];
    
    [self updateContentInsets];
}

- (void)resetHeaderViewFrame {
    [self.headerView setNeedsLayout];
    [self.headerView layoutIfNeeded];
    CGFloat headerViewHeight = [self.headerView systemLayoutSizeFittingSize:CGSizeMake(DXScreenWidth, 0)].height;
    self.headerViewHeight = headerViewHeight;
}

- (void)updateContentInsets {
    UIEdgeInsets tableViewInset = self.tableView.contentInset;
    UIEdgeInsets hotTableViewInset = self.hotTableView.contentInset;
    
    if (self.joinButton.hidden) {
        tableViewInset.bottom = 0;
        hotTableViewInset.bottom = 0;
    } else {
        tableViewInset.bottom = CGRectGetHeight(self.joinButton.frame);
        hotTableViewInset.bottom = CGRectGetHeight(self.joinButton.frame);
    }
    
    self.tableView.contentInset = tableViewInset;
    self.tableView.scrollIndicatorInsets = tableViewInset;
    self.hotTableView.contentInset = hotTableViewInset;
    self.hotTableView.scrollIndicatorInsets = hotTableViewInset;
}

- (void)toggleTableView:(NSUInteger)index {
    __weak DXTopicViewController * weakSelf = self;
    if (index == 0) {
        [self stopTableViewFromScrolling:self.hotTableView];
        self.hotTableView.hidden = YES;
        [self.hotTableView removeFromSuperview];
        
        self.tableView.hidden = NO;
        self.tableView.frame = self.view.bounds;
        [self.view insertSubview:self.tableView belowSubview:self.joinButton];
        if (self.tableViewDataFirstTimeLoaded == NO && !self.tableViewFirstTimeLoading) {
            self.tableViewFirstTimeLoading = YES;
            [self loadMorePreviousData:^(BOOL more, NSError *error) {
                weakSelf.tableViewFirstTimeLoading = NO;
                [weakSelf fixTableViewOffset:weakSelf.tableView];
            }];
        } else {
            [self makeHeaderViewAndSwitchBarBelongToTableView:self.tableView];
            [self fixTableViewOffset:self.tableView];
        }
    } else {
        [self stopTableViewFromScrolling:self.tableView];
        self.tableView.hidden = YES;
        [self.tableView removeFromSuperview];

        self.hotTableView.hidden = NO;
        self.hotTableView.frame = self.view.bounds;
        [self.view insertSubview:self.hotTableView belowSubview:self.joinButton];
        
        if (self.hotTableViewDataFirstTimeLoaded == NO) {
            [self loadMorePreviousData:^(BOOL more, NSError *error) {
                [weakSelf fixTableViewOffset:weakSelf.hotTableView];
            }];
        } else {
            [self makeHeaderViewAndSwitchBarBelongToTableView:self.hotTableView];
            [self fixTableViewOffset:self.hotTableView];
        }
    }
}

- (void)stopTableViewFromScrolling:(UITableView *)tableView {
    [tableView setContentOffset:tableView.contentOffset animated:NO];
}

- (void)makeHeaderViewAndSwitchBarBelongToTableView:(UITableView *)tableView {
    [tableView reloadData];
}

- (void)reloadHeaderView {
    if (self.topicDetail) {
        [self.headerView.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.topicDetail.cover] placeholderImage:nil options:SDWebImageRetryFailed];
        self.headerView.hasPrize = self.topicDetail.has_prize;
        self.headerView.topicLabel.text = [NSString stringWithFormat:@"#%@#", self.topicDetail.topic];
        self.headerView.subTitleLabel.text = self.topicDetail.title;
        self.headerView.rank = self.rank;
        self.headerView.collectedBtn.selected = self.topicDetail.is_like;
        self.headerView.topicText = self.topicDetail.txt;
        self.headerView.nickLabel.text = self.topicDetail.nick;
        self.headerView.timeLabel.text = [NSString stringWithFormat:@"%@ 发起", self.topicDetail.time];
        [self.headerView.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.topicDetail.avatar] placeholderImage:nil options:SDWebImageRetryFailed];
        self.headerView.avatarView.verified = self.topicDetail.verified;
        self.headerView.avatarView.certificationIconSize = DXCertificationIconSizeLarge;
    }
}

- (void)cacheTableViewOffset {
    if (self.tableView.hidden == NO) {
        self.lastTableViewOffset = self.tableView.contentOffset;
    } else {
        self.lastHotTableViewOffset = self.hotTableView.contentOffset;
    }
}

- (void)fixTableViewOffset:(UITableView *)tableView {
    CGPoint lastContentOffset;
    if (tableView == self.tableView) {
        lastContentOffset = self.lastHotTableViewOffset;
    } else {
        lastContentOffset = self.lastTableViewOffset;
    }
    
    if (lastContentOffset.y < self.headerViewHeight) {
        [tableView setContentOffset:lastContentOffset animated:NO];
    } else {
        if (tableView.contentOffset.y < self.headerViewHeight) {
            CGPoint contentOffset = CGPointMake(0, self.headerViewHeight);
            [tableView setContentOffset:contentOffset animated:NO];
        } else {
            [tableView setContentOffset:tableView.contentOffset animated:NO];
        }
    }
}

#pragma mark - 数据操作

/**
 *  下拉刷新
 */
- (void)loadNewData {
    
    __weak typeof(self) weakSelf = self;
    
    NSInteger feedListCount = 10;
    NSInteger hotFeedListCount = 10;
    
    if (!self.tableView.hidden) {
        [self.api getTopicFeedList:self.topicID pullType:DXDataListPullFirstTime count:feedListCount lastID:nil result:^(DXTopicFeedList *topicFeedList, NSError *error) {
            if (topicFeedList) {
                weakSelf.tableViewDataFirstTimeLoaded = YES;
                [weakSelf.feedList removeAllObjects];
                weakSelf.tableView.mj_footer = nil;
                
                [weakSelf.feedList addObjectsFromArray:topicFeedList.feeds];
                
                /**
                 *  如果是下拉刷新，则移除掉手工添加的数据
                 */
                [weakSelf.manualFeedList removeAllObjects];
                
                if (weakSelf.feedList.count == 0) {
                    weakSelf.errorDescription = @"没有最新的参与内容";
                }
                
                if (weakSelf.tableView.mj_footer == nil && topicFeedList.feeds.count == feedListCount) {
                    weakSelf.tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
                }
                
                DXTopicDetail * topicDetail = topicFeedList.topic;
                weakSelf.topicDetail = topicDetail;
                weakSelf.rank = topicFeedList.rank;
                [weakSelf reloadHeaderView];
                
//                if (weakSelf.joinButton.hidden) {
//                    weakSelf.joinButton.hidden = NO;
//                    [weakSelf updateContentInsets];
//                }
            } else {
//                if (!weakSelf.topicDetail && !weakSelf.joinButton.hidden) {
//                    weakSelf.joinButton.hidden = YES;
//                    [weakSelf updateContentInsets];
//                }
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.feedList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
        }];
    }
    
    if (!self.hotTableView.hidden) {
        [self.api getHotTopicFeedList:self.topicID pullType:DXDataListPullFirstTime count:hotFeedListCount lastID:nil result:^(DXTopicFeedList *topicFeedList, NSError *error) {
            if (topicFeedList) {
                weakSelf.hotTableViewDataFirstTimeLoaded = YES;
                [weakSelf.hotFeedList removeAllObjects];
                weakSelf.hotTableView.mj_footer = nil;
                
                [weakSelf.hotFeedList addObjectsFromArray:topicFeedList.feeds];
                
                if (weakSelf.hotFeedList.count == 0) {
                    weakSelf.errorDescription = @"没有精选的参与内容";
                }
                
                if (weakSelf.hotTableView.mj_footer == nil && topicFeedList.feeds.count == hotFeedListCount) {
                    weakSelf.hotTableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
                }
                
                DXTopicDetail * topicDetail = topicFeedList.topic;
                weakSelf.topicDetail = topicDetail;
                [weakSelf reloadHeaderView];
                
//                if (weakSelf.joinButton.hidden) {
//                    weakSelf.joinButton.hidden = NO;
//                    [weakSelf updateContentInsets];
//                }
            } else {
//                if (!weakSelf.topicDetail && !weakSelf.joinButton.hidden) {
//                    weakSelf.joinButton.hidden = YES;
//                    [weakSelf updateContentInsets];
//                }
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.feedList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.hotTableView reloadData];
            [weakSelf.hotTableView.mj_header endRefreshing];
        }];
    }
    
    /*
    [self loadMoreNewData:^(BOOL more, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.hotTableView.mj_header endRefreshing];
    }];
     */
}

/**
 *  上拉加载更多
 */
- (void)loadOldData {
    
    __weak typeof(self) weakSelf = self;
    [self loadMorePreviousData:^(BOOL more, NSError *error) {
        
        if (!self.tableView.hidden) {
            DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.tableView.mj_footer;
            if (error) {
                [footer endRefreshingWithError];
            } else {
                if (more) {
                    [footer endRefreshing];
                } else {
                    footer.hidden = YES;
                }
            }
        }
        if (!self.hotTableView.hidden) {
            DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.hotTableView.mj_footer;
            if (error) {
                [footer endRefreshingWithError];
            } else {
                if (more) {
                    [footer endRefreshing];
                } else {
                    footer.hidden = YES;
                }
            }
        }
    }];
}

/**
 *  加载更多旧数据（上拉）
 *
 */
- (void)loadMorePreviousData:(void(^)(BOOL, NSError *))completionBlock {
    [self loadDataWithPullType:DXDataListPullOlderList completion:^(BOOL more, NSError *error) {
        if (completionBlock) {
            completionBlock(more, error);
        }
    }];
}

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


- (void)loadDataWithPullType:(DXDataListPullType)pullType completion:(void(^)(BOOL more, NSError * error))completionBlock {
    
    [self loadDataWithPullType:pullType forceRefresh:NO completion:^(BOOL more, NSError *error) {
        if (completionBlock) {
            completionBlock(more, error);
        }
    }];
}

- (void)loadDataWithPullType:(DXDataListPullType)pullType forceRefresh:(BOOL)forceRefresh completion:(void(^)(BOOL more, NSError * error))completionBlock {
    
    __weak DXTopicViewController * weakSelf = self;
    NSString * lastID = nil;
    NSInteger feedListCount = 10;
    NSInteger hotFeedListCount = 10;
    
    if (forceRefresh) {
        feedListCount = self.feedList.count;
        hotFeedListCount = self.hotFeedList.count;
        [self.feedList removeAllObjects];
        [self.hotFeedList removeAllObjects];
    }
    
    if (!self.tableView.hidden || forceRefresh) {
        if (pullType == DXDataListPullOlderList) {
            DXTimelineFeed * lastFeed = [self.feedList lastObject];
            lastID = lastFeed.ID;
        } else if (pullType == DXDataListPullNewerList) {
            DXTimelineFeed * firstFeed = [self.feedList firstObject];
            lastID = firstFeed.ID;
        }
        
        if (!lastID) {
            pullType = DXDataListPullFirstTime;
        }
        
        [self.api getTopicFeedList:self.topicID pullType:pullType count:feedListCount lastID:lastID result:^(DXTopicFeedList *topicFeedList, NSError *error) {
            if (topicFeedList) {
                weakSelf.tableViewDataFirstTimeLoaded = YES;
                
                NSArray * feeds = topicFeedList.feeds;
                if (pullType == DXDataListPullOlderList) {
                    [weakSelf.feedList addObjectsFromArray:feeds];
                } else {
                    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, feeds.count)];
                    [weakSelf.feedList insertObjects:feeds atIndexes:indexSet];
                }
                
                /**
                 *  如果是下拉刷新，则移除掉手工添加的数据
                 */
                if (pullType == DXDataListPullNewerList || pullType == DXDataListPullFirstTime) {
                    [weakSelf.manualFeedList removeAllObjects];
                }
                
                if (weakSelf.feedList.count == 0) {
                    weakSelf.errorDescription = @"没有最新的参与内容";
                }
                
                if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer == nil && topicFeedList.feeds.count == feedListCount) {
                    weakSelf.tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
                }
                
                DXTopicDetail * topicDetail = topicFeedList.topic;
                weakSelf.topicDetail = topicDetail;
                weakSelf.rank = topicFeedList.rank;
                [weakSelf reloadHeaderView];
                
//                if (weakSelf.joinButton.hidden) {
//                    weakSelf.joinButton.hidden = NO;
//                    [weakSelf updateContentInsets];
//                }
            } else {
//                if (!weakSelf.topicDetail && !weakSelf.joinButton.hidden) {
//                    weakSelf.joinButton.hidden = YES;
//                    [weakSelf updateContentInsets];
//                }
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.feedList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.tableView reloadData];
            
            if (completionBlock) {
                completionBlock(topicFeedList.more, error);
            }
        }];
    }
    
    if (!self.hotTableView.hidden || forceRefresh) {
        if (pullType == DXDataListPullOlderList) {
            DXTimelineFeed * lastFeed = [self.hotFeedList lastObject];
            lastID = lastFeed.ID;
        } else if (pullType == DXDataListPullNewerList) {
            DXTimelineFeed * firstFeed = [self.hotFeedList firstObject];
            lastID = firstFeed.ID;
        }
        
        if (!lastID) {
            pullType = DXDataListPullFirstTime;
        }
        
        [self.api getHotTopicFeedList:self.topicID pullType:pullType count:hotFeedListCount lastID:lastID result:^(DXTopicFeedList *topicFeedList, NSError *error) {
            if (topicFeedList) {
                weakSelf.hotTableViewDataFirstTimeLoaded = YES;
                
                NSArray * feeds = topicFeedList.feeds;
                if (pullType == DXDataListPullOlderList) {
                    [weakSelf.hotFeedList addObjectsFromArray:feeds];
                } else {
                    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, feeds.count)];
                    [weakSelf.hotFeedList insertObjects:feeds atIndexes:indexSet];
                }
                
                if (weakSelf.hotFeedList.count == 0) {
                    weakSelf.errorDescription = @"没有精选的参与内容";
                }
                
                if (pullType == DXDataListPullFirstTime && weakSelf.hotTableView.mj_footer == nil && topicFeedList.feeds.count == hotFeedListCount) {
                    weakSelf.hotTableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
                }
                
                DXTopicDetail * topicDetail = topicFeedList.topic;
                weakSelf.topicDetail = topicDetail;
                [weakSelf reloadHeaderView];
                
//                if (weakSelf.joinButton.hidden) {
//                    weakSelf.joinButton.hidden = NO;
//                    [weakSelf updateContentInsets];
//                }
            } else {
//                if (!weakSelf.topicDetail && !weakSelf.joinButton.hidden) {
//                    weakSelf.joinButton.hidden = YES;
//                    [weakSelf updateContentInsets];
//                }
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.feedList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
            }
            
            [weakSelf.hotTableView reloadData];
            
            if (completionBlock) {
                completionBlock(topicFeedList.more, error);
            }
        }];
    }
}

#pragma mark - Property Methods

- (DXDongXiApi *)api {
    if (nil == _api) {
        _api = [DXDongXiApi api];
    }
    return _api;
}

- (NSMutableArray *)manualFeedList {
    if (nil == _manualFeedList) {
        _manualFeedList = [NSMutableArray array];
    }
    return _manualFeedList;
}

- (NSMutableArray *)feedList {
    if (nil == _feedList) {
        _feedList = [NSMutableArray array];
    }
    return _feedList;
}

- (NSMutableArray *)hotFeedList {
    if (nil == _hotFeedList) {
        _hotFeedList = [NSMutableArray array];
    }
    return _hotFeedList;
}

- (void)setHeaderViewHeight:(CGFloat)headerViewHeight {
    _headerViewHeight = headerViewHeight;
    
    if (!self.tableView.hidden) {
        [self.tableView reloadData];
    }
    
    if (!self.hotTableView.hidden) {
        [self.hotTableView reloadData];
    }
}


#pragma mark - Button Action

- (IBAction)inviteButtonTapped:(UIBarButtonItem *)sender {
    if (![self.api needLogin]) {
        DXTopicInviteViewController * inviteViewController = [[DXTopicInviteViewController alloc] init];
        inviteViewController.topicID = self.topicDetail.topic_id;
        [self.navigationController pushViewController:inviteViewController animated:YES];
    } else {
        DXMainNavigationController * navigationController = (DXMainNavigationController * )self.navigationController;
        [navigationController presentLoginViewIfNeeded];
    }
}

- (IBAction)joinButtonTapped:(UIButton *)sender {
    DXPhotoTakerController * photoTaker = [[DXPhotoTakerController alloc] init];
    photoTaker.delegate = self;
    [self presentViewController:photoTaker animated:YES completion:nil];
}

- (void)discussButtonTapped:(UIButton *)sender {
    DXWebViewController *vc = [[DXWebViewController alloc] init];
    vc.showControls = NO;
    NSString *urlStr = [NSString stringWithFormat:@"" DXWebHost "/discuss/question/list?topic=%@", self.topicDetail.topic_id];
    vc.url = [NSURL URLWithString:urlStr];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)back {
    
    if (self.updateTopicBlock) {
        self.updateTopicBlock(self.topicDetail);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - <DXPhotoTakerControllerDelegate>

- (void)photoTaker:(DXPhotoTakerController *)photoTaker didFinishPhoto:(UIImage *)photo {
    __weak DXTopicViewController * weakSelf = self;
    
    [self dismissViewControllerAnimated:NO completion:^{
        DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"正在处理照片" fromController:self];
        [notice disableAutoDismissed];
        [notice show];
        
        DXFeedPublishViewController * feedPublishVC = [[DXFeedPublishViewController alloc] init];
        feedPublishVC.topicID = weakSelf.topicDetail.topic_id;
        feedPublishVC.topicTitle = weakSelf.topicDetail.topic;
        feedPublishVC.topicHasPrize = weakSelf.topicDetail.has_prize;
        feedPublishVC.delegateController = weakSelf;
        [feedPublishVC appendPhoto:photo];
        
        UINavigationController * feedPublishNav = [[UINavigationController alloc] initWithRootViewController:feedPublishVC];
        [weakSelf presentViewController:feedPublishNav animated:YES completion:^{
            [notice dismiss:NO];
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.topicDetail) {
        return 2;
    } else {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.topicDetail == nil) {
        return DXRealValue(120);
    }
    
    if (tableView == self.tableView) {
        NSUInteger count = self.manualFeedList.count + self.feedList.count;
        if (count == 0) {
            CGFloat joinButtonHeight = CGRectGetHeight(self.joinButton.bounds);
            return DXScreenHeight - DXStatusBarHeight - DXNavBarHeight - self.tableSwitchBarHeight - joinButtonHeight;
        } else {
            DXTimelineFeed * feed = nil;
            if (indexPath.row < self.manualFeedList.count) {
                feed = [self.manualFeedList objectAtIndex:indexPath.row];
            } else {
                feed = [self.feedList objectAtIndex:indexPath.row - self.manualFeedList.count];
            }
            return [DXFeedCell tableView:tableView heightForRowAtIndexPath:indexPath withFeed:feed];
        }
    }else{
        if (self.hotFeedList.count == 0) {
            CGFloat joinButtonHeight = CGRectGetHeight(self.joinButton.bounds);
            return DXScreenHeight - DXStatusBarHeight - DXNavBarHeight - self.tableSwitchBarHeight - joinButtonHeight;
        } else {
            DXTimelineFeed * feed = [self.hotFeedList objectAtIndex:indexPath.row];
            return [DXFeedCell tableView:tableView heightForRowAtIndexPath:indexPath withFeed:feed];
        }
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.topicDetail == nil) {
        return 1;
    }
    
    if (section == 0) {
        return 0;
    } else {
        if (tableView == self.tableView) {
            NSUInteger count = self.manualFeedList.count + self.feedList.count;
            if (count == 0) {
                return 1;
            } else {
                return count;
            }
        } else {
            if (self.hotFeedList.count == 0) {
                return 1;
            } else {
                return self.hotFeedList.count;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.topicDetail == nil) {
        DXNoneDataTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXNoneDataTableViewCell" forIndexPath:indexPath];
        cell.text = self.errorDescription;
        return cell;
    }
    
    if (tableView == self.tableView) {
        NSUInteger totalCount = self.manualFeedList.count + self.feedList.count;
        if (totalCount == 0) {
            DXNoneDataTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXNoneDataTableViewCell" forIndexPath:indexPath];
            cell.text = self.errorDescription;
            cell.maxTextCenterY = DXRealValue(60);
            return cell;
        } else {
            static NSString * ID = @"Topic Feed Cell";
            
            DXFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[DXFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            }
            
            DXTimelineFeed * feed = nil;
            if (indexPath.row < self.manualFeedList.count) {
                feed = [self.manualFeedList objectAtIndex:indexPath.row];
            } else {
                feed = [self.feedList objectAtIndex:indexPath.row - self.manualFeedList.count];
            }
            
            cell.feed = feed;
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            return cell;
        }
    } else {
        if (self.hotFeedList.count == 0) {
            DXNoneDataTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXNoneDataTableViewCell" forIndexPath:indexPath];
            cell.text = self.errorDescription;
            cell.maxTextCenterY = DXRealValue(60);
            return cell;
        } else {
            static NSString * ID = @"Hot Feed Cell";
            
            DXFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (cell == nil) {
                cell = [[DXFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            }
            
            DXTimelineFeed * feed = [self.hotFeedList objectAtIndex:indexPath.row];
            
            cell.feed = feed;
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (tableView.hidden) {
//        return 0;
//    }

    if (section == 0) {
        return self.headerViewHeight;
    } else {
        return self.tableSwitchBarHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.headerView;
    } else {
        return self.tableSwitchBar;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.topicDetail == nil) {
        return;
    }
    
    self.currentIndexPath = indexPath;
    
    DXTimelineFeed * feed = nil;
    if (tableView == self.tableView) {
        if (self.manualFeedList.count + self.feedList.count == 0) {
            return;
        }
        
        if (indexPath.row < self.manualFeedList.count) {
            feed = [self.manualFeedList objectAtIndex:indexPath.row];
        } else {
            feed = [self.feedList objectAtIndex:indexPath.row - self.manualFeedList.count];
        }
    }else{
        if (self.hotFeedList.count == 0) {
            return;
        }
        feed = [self.hotFeedList objectAtIndex:indexPath.row];
    }
    
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




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self cacheTableViewOffset];
}

#pragma mark - DXTabBarViewDelegate

- (void)tabBarView:(DXTabBarView *)view didTapButtonAtIndex:(NSUInteger)index {
    [self toggleTableView:index];
}

#pragma mark - DXTopicHeaderViewDelegate

- (void)textDidChangeInTopicHeaderView:(DXTopicHeaderView *)topicHeaderView {
    [self resetHeaderViewFrame];
}

- (void)rankViewDidTapInTopicHeaderView:(DXTopicHeaderView *)topicHeaderView {
    
    DXTopicRankViewController *vc = [[DXTopicRankViewController alloc] init];
    vc.topicDetail = self.topicDetail;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)avatarDidTapInTopicHeaderView:(DXTopicHeaderView *)topicHeaderView {
    DXProfileViewController * profileViewController = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
    profileViewController.uid = self.topicDetail.uid;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)collectedBtnDidTapInTopicHeaderView:(DXTopicHeaderView *)topicHeaderView {
    
    __weak typeof(self) weakSelf = self;
    if ([[DXDongXiApi api] needLogin]) {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才可收藏话题，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
        return;
    }
    
    NSString *topicID = self.topicDetail.topic_id;
    if (topicHeaderView.collectedBtn.isSelected == NO) { // 需要收藏
        self.headerView.collectedBtn.selected = YES;
        self.topicDetail.is_like = YES;
        [self.api collectTopicWithTopicID:topicID result:^(BOOL success, NSError *error) {
            if (!success) {
                weakSelf.headerView.collectedBtn.selected = NO;
                weakSelf.topicDetail.is_like = NO;
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                NSString *noticeMsg = [NSString stringWithFormat:@"收藏失败，%@", reason];
                [MBProgressHUD showHUDWithMessage:noticeMsg];
            } else {
                [MBProgressHUD showHUDWithMessage:@"收藏成功"];
            }
        }];
    } else { // 需要取消收藏
        self.headerView.collectedBtn.selected = NO;
        self.topicDetail.is_like = NO;
        [self.api cancelCollectTopicWithTopicID:topicID result:^(BOOL success, NSError *error) {
            if (!success) {
                weakSelf.headerView.collectedBtn.selected = YES;
                weakSelf.topicDetail.is_like = YES;
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                NSString *noticeMsg = [NSString stringWithFormat:@"取消收藏失败，%@", reason];
                [MBProgressHUD showHUDWithMessage:noticeMsg];
            } else {
                [MBProgressHUD showHUDWithMessage:@"取消收藏成功"];
            }
        }];
    }
}

#pragma mark - DXFeedCellDelegate

- (void)didTapAvatarViewInFeedCellWithUserID:(NSString *)userID {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

- (void)didTapTopicViewInFeedCellWithTopicID:(NSString *)topicID {
    
    DXLog(@"此处不用做跳转");
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

#pragma mark - <DXFeedPublishDelegateController>

- (void)feedPublishController:(DXFeedPublishViewController *)feedPublishController didPublishFeed:(DXTimelineFeed *)feed {
    [self selectTableAtIndex:0];
    [self insertFeed:feed atRow:0 inTable:0];
}

#pragma mark - 显示的feed内容需要改变

/**
 *  整个feed展示的数据需要改变
 */
- (void)feedInfoShouldChangeWithFeed:(DXTimelineFeed *)feed {
    
    if (self.tableView.isHidden == NO) {
        for (DXTimelineFeed *changeFeed in self.feedList) {
            if ([changeFeed.fid isEqualToString:feed.fid]) {
                changeFeed.data = feed.data;
                break;
            }
        }
        for (DXTimelineFeed *changeFeed in self.manualFeedList) {
            if ([changeFeed.fid isEqualToString:feed.fid]) {
                changeFeed.data = feed.data;
                break;
            }
        }
        [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        DXTimelineFeed *changeFeed = [self.hotFeedList objectAtIndex:self.currentIndexPath.row];
        changeFeed.data = feed.data;
        [self.hotTableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

/**
 *  点赞信息需要改变
 */
- (void)likeInfoShouldChangeWithFeed:(DXTimelineFeed *)feed cell:(DXFeedCell *)cell {
    __weak typeof(self) weakSelf = self;
    
    if (!feed.data.is_like) { // 要点赞
        cell.toolBar.likeView.like = YES;
        
        [self.api likeFeedWithFeedID:feed.fid result:^(BOOL success, NSError *error) {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataList) name:DXDongXiApiNotificationUserDidLogin object:nil];
    // 点赞信息改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeLikeInfoNotification:) name:DXLikeInfoDidChangeNotification object:nil];
}

- (void)removeNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDeleteFeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDongXiApiNotificationUserDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXLikeInfoDidChangeNotification object:nil];
}

- (void)shouldDeleteFeed:(NSNotification *)notification {
    
    NSString *deleteID = notification.object;
    
    for (DXTimelineFeed *deleteFeed in self.manualFeedList) {
        if ([deleteFeed.fid isEqualToString:deleteID]) {
            [self.manualFeedList removeObject:deleteFeed];
            [self.tableView reloadData];
            break;
        }
    }
    for (DXTimelineFeed *deleteFeed in self.feedList) {
        if ([deleteFeed.fid isEqualToString:deleteID]) {
            [self.feedList removeObject:deleteFeed];
            [self.tableView reloadData];
            break;
        }
    }
    for (DXTimelineFeed *deleteFeed in self.hotFeedList) {
        if ([deleteFeed.fid isEqualToString:deleteID]) {
            [self.hotFeedList removeObject:deleteFeed];
            [self.hotTableView reloadData];
            break;
        }
    }
    
    
    /*
    __weak DXTopicViewController * weakSelf = self;
    [self.manualFeedList enumerateObjectsUsingBlock:^(DXTimelineFeed *feed, NSUInteger idx, BOOL *stop) {
        if ([feed.fid isEqualToString:deleteID]) {
            [weakSelf.manualFeedList removeObject:feed];
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:1];
//            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView reloadData];
            *stop = YES;
        }
    }];

    [self.feedList enumerateObjectsUsingBlock:^(DXTimelineFeed *feed, NSUInteger idx, BOOL *stop) {
        if ([feed.fid isEqualToString:deleteID]) {
            [weakSelf.feedList removeObject:feed];
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx+self.manualFeedList.count inSection:1];
//            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView reloadData];
            *stop = YES;
        }
    }];
    
    [self.hotFeedList enumerateObjectsUsingBlock:^(DXTimelineFeed *feed, NSUInteger idx, BOOL *stop) {
        if ([feed.fid isEqualToString:deleteID]) {
            [weakSelf.hotFeedList removeObject:feed];
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:1];
//            [weakSelf.hotTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.hotTableView reloadData];
            *stop = YES;
        }
    }];
     
     */
}

/**
 *  刷新数据
 */
- (void)refreshDataList {
    
    [self loadDataWithPullType:DXDataListPullFirstTime forceRefresh:YES completion:nil];
}

- (void)handleChangeLikeInfoNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *feedID = [userInfo objectForKey:kFeedIDKey];
    BOOL isLike = [[userInfo objectForKey:kLikeStatusKey] boolValue];
    
    if (self.tableView.isHidden == NO) {
        for (DXTimelineFeed *feed in self.feedList) {
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
        for (DXTimelineFeed *feed in self.manualFeedList) {
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
    } else {
        for (DXTimelineFeed *feed in self.hotFeedList) {
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
                [self.hotTableView reloadData];
                break;
            }
        }
    }
}


@end
