//
//  DXSearchMoreViewController.m
//  dongxi
//
//  Created by 穆康 on 16/1/25.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchMoreViewController.h"
#import "DXDetailViewController.h"
#import "DXLoginViewController.h"
#import "DXTopicViewController.h"
#import "DXProfileViewController.h"
#import "DXEventViewController.h"
#import "DXChatViewController.h"

#import "UIBarButtonItem+Extension.h"
#import "DXTimelineFeed+User.h"
#import "UIImage+Extension.h"

#import <UIImageView+WebCache.h>
#import <MJRefresh.h>

#import "DXFeedCell.h"
#import "DXSearchResultsTopicCell.h"
#import "DXSearchResultsUserCell.h"
#import "DXActivityListCell.h"
#import "DXNoneDataTableViewCell.h"
#import "DXNoneDataCollectionViewCell.h"

static NSString *const IDFeedCell                       = @"FeedCell";
static NSString *const IDSearchResultsTopicCell         = @"SearchResultsTopicCell";
static NSString *const IDSearchResultsUserCell          = @"SearchResultsUserCell";
static NSString *const IDActivityListCell               = @"ActivityListCell";
static NSString *const IDNoneDataTableViewCell          = @"NoneDataTableViewCell";
static NSString *const IDNoneDataCollectionViewCell     = @"NoneDataCollectionViewCell";

@interface DXSearchMoreViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
DXFeedCellDelegate
>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UICollectionView *collectionView;
/** 当前正在操作的cell的indexPath */
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) DXDongXiApi *api;
/** 错误描述 */
@property (nonatomic, copy) NSString * errorDescription;

@end

@implementation DXSearchMoreViewController {
    __weak DXSearchMoreViewController *weakSelf;
}

- (instancetype)initWithSearchMoreType:(DXSearchMoreType)searchMoreType {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _searchMoreType = searchMoreType;
        weakSelf = self;
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"请使用-initWithSearchMoreType:来初始化");
    return nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSAssert(NO, @"请使用-initWithSearchMoreType:来初始化");
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.searchMoreType) {
        case DXSearchMoreTypeTopic:
            self.dt_pageName = DXDataTrackingPage_SearchMoreTopic;
            break;
        case DXSearchMoreTypeUser:
            self.dt_pageName = DXDataTrackingPage_SearchMoreUser;
            break;
        case DXSearchMoreTypeActivity:
            self.dt_pageName = DXDataTrackingPage_SearchMoreActivity;
            break;
            
        default:
            self.dt_pageName = DXDataTrackingPage_SearchMoreFeed;
            break;
    }
    
    [self setupNav];
    [self setupSubViews];
    
    if (self.searchMoreType == DXSearchMoreTypeFeed) {
        [self registerNotification];
    }
    
    [self loadNewData];
}

- (void)dealloc {
    
    if (self.searchMoreType == DXSearchMoreTypeFeed) {
        [self removeNotification];
    }
}

- (void)setupNav {
    
    NSString *title = nil;
    switch (self.searchMoreType) {
        case DXSearchMoreTypeTopic:
            title = @"相关话题";
            break;
        case DXSearchMoreTypeUser:
            title = @"相关用户";
            break;
        case DXSearchMoreTypeActivity:
            title = @"相关活动";
            break;
        case DXSearchMoreTypeFeed:
            title = @"相关照片";
            break;
            
        default:
            break;
    }
    
    self.navigationItem.title = title;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(backBtnDidClick)];
}

- (void)setupSubViews {
    
    if (self.searchMoreType == DXSearchMoreTypeFeed) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        tableView.backgroundColor = DXRGBColor(222, 222, 222);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
        tableView.mj_footer.hidden = YES;
        [self.view addSubview:tableView];
        self.tableView = tableView;
        [tableView registerClass:[DXNoneDataTableViewCell class] forCellReuseIdentifier:IDNoneDataTableViewCell];
    } else {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        collectionView.backgroundColor = DXRGBColor(222, 222, 222);
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        collectionView.alwaysBounceVertical = YES;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        collectionView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
        collectionView.mj_footer.hidden = YES;
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
        [collectionView registerClass:[DXSearchResultsTopicCell class] forCellWithReuseIdentifier:IDSearchResultsTopicCell];
        [collectionView registerClass:[DXSearchResultsUserCell class] forCellWithReuseIdentifier:IDSearchResultsUserCell];
        [collectionView registerClass:[DXActivityListCell class] forCellWithReuseIdentifier:IDActivityListCell];
        [collectionView registerClass:[DXNoneDataCollectionViewCell class] forCellWithReuseIdentifier:IDNoneDataCollectionViewCell];
    }
}

#pragma mark - 加载数据

- (void)loadNewData {
    
    [self fetchDataListWithPullType:DXDataListPullNewerList completion:^(BOOL more, NSError *error) {
        if (weakSelf.searchMoreType == DXSearchMoreTypeFeed) {
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
        } else {
            [weakSelf.collectionView reloadData];
            [weakSelf.collectionView.mj_header endRefreshing];
        }
        if (error) {
            [weakSelf fetchErrorDescriptionWithError:error];
        }
    }];
}

- (void)loadOldData {
    
    [self fetchDataListWithPullType:DXDataListPullOlderList completion:^(BOOL more, NSError *error) {
        if (!error) {
            if (weakSelf.searchMoreType == DXSearchMoreTypeFeed) {
                [weakSelf.tableView reloadData];
                if (more) {
                    [weakSelf.tableView.mj_footer endRefreshing];
                } else {
                    weakSelf.tableView.mj_footer.hidden = YES;
                }
            } else {
                [weakSelf.collectionView reloadData];
                if (more) {
                    [weakSelf.collectionView.mj_footer endRefreshing];
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        weakSelf.collectionView.mj_footer.hidden = YES;
                    });
                }
            }
        } else {
            if (weakSelf.searchMoreType == DXSearchMoreTypeFeed) {
                DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.tableView.mj_footer;
                [footer endRefreshingWithError];
            } else {
                DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.collectionView.mj_footer;
                [footer endRefreshingWithError];
            }
            [weakSelf fetchErrorDescriptionWithError:error];
        }
    }];
}

- (void)fetchErrorDescriptionWithError:(NSError *)error {
    NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
    weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
    if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
}

- (void)fetchDataListWithPullType:(DXDataListPullType)pullType completion:(void(^)(BOOL more, NSError *error))completionBlock {
    switch (self.searchMoreType) {
        case DXSearchMoreTypeTopic:
        {
            [self fetchTopicListWithPullType:pullType completion:^(BOOL more, NSError *error) {
                if (completionBlock) {
                    completionBlock(more, error);
                }
            }];
        }
            break;
        case DXSearchMoreTypeUser:
        {
            [self fetchUserListWithPullType:pullType completion:^(BOOL more, NSError *error) {
                if (completionBlock) {
                    completionBlock(more, error);
                }
            }];
        }
            break;
        case DXSearchMoreTypeActivity:
        {
            [self fetchActivityListWithPullType:pullType completion:^(BOOL more, NSError *error) {
                if (completionBlock) {
                    completionBlock(more, error);
                }
            }];
        }
            break;
        case DXSearchMoreTypeFeed:
        {
            [self fetchFeedListWithPullType:pullType completion:^(BOOL more, NSError *error) {
                if (completionBlock) {
                    completionBlock(more, error);
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)fetchTopicListWithPullType:(DXDataListPullType)pullType completion:(void(^)(BOOL more, NSError *error))completionBlock {
    
    DXTopic *topic = nil;
    if (pullType == DXDataListPullNewerList) {
        topic = [self.dataList firstObject];
    } else if (pullType == DXDataListPullOlderList) {
        topic = [self.dataList lastObject];
    }
    if (topic == nil) {
        pullType = DXDataListPullFirstTime;
    }
    
    [self.api getSearchTopicWrapperByKeywords:self.keywords pullType:pullType count:20 lastID:topic.topic_id result:^(DXSearchTopicWrapper *searchTopicWrapper, NSError *error) {
        if (searchTopicWrapper.list.count) {
            if (pullType == DXDataListPullNewerList) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, searchTopicWrapper.list.count)];
                [weakSelf.dataList insertObjects:searchTopicWrapper.list atIndexes:indexSet];
            } else {
                [weakSelf.dataList addObjectsFromArray:searchTopicWrapper.list];
            }
            if (pullType == DXDataListPullFirstTime && weakSelf.collectionView.mj_footer.isHidden && searchTopicWrapper.list.count == 20) {
                weakSelf.collectionView.mj_footer.hidden = NO;
            }
        }
        if (completionBlock) {
            completionBlock(searchTopicWrapper.more, error);
        }
    }];
}

- (void)fetchUserListWithPullType:(DXDataListPullType)pullType completion:(void(^)(BOOL more, NSError *error))completionBlock {
    
    DXUser *user = nil;
    if (pullType == DXDataListPullNewerList) {
        user = [self.dataList firstObject];
    } else if (pullType == DXDataListPullOlderList) {
        user = [self.dataList lastObject];
    }
    if (user == nil) {
        pullType = DXDataListPullFirstTime;
    }
    
    [self.api getSearchUserWrapperByKeywords:self.keywords pullType:pullType count:20 lastID:user.uid result:^(DXSearchUserWrapper *searchUserWrapper, NSError *error) {
        if (searchUserWrapper.list.count) {
            if (pullType == DXDataListPullNewerList) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, searchUserWrapper.list.count)];
                [weakSelf.dataList insertObjects:searchUserWrapper.list atIndexes:indexSet];
            } else {
                [weakSelf.dataList addObjectsFromArray:searchUserWrapper.list];
            }
            if (pullType == DXDataListPullFirstTime && weakSelf.collectionView.mj_footer.isHidden && searchUserWrapper.list.count == 20) {
                weakSelf.collectionView.mj_footer.hidden = NO;
            }
        }
        if (completionBlock) {
            completionBlock(searchUserWrapper.more, error);
        }
    }];
}

- (void)fetchActivityListWithPullType:(DXDataListPullType)pullType completion:(void(^)(BOOL more, NSError *error))completionBlock {
    
    DXActivity *activity = nil;
    if (pullType == DXDataListPullNewerList) {
        activity = [self.dataList firstObject];
    } else if (pullType == DXDataListPullOlderList) {
        activity = [self.dataList lastObject];
    }
    if (activity == nil) {
        pullType = DXDataListPullFirstTime;
    }
    
    [self.api getSearchActivityWrapperByKeywords:self.keywords pullType:pullType count:20 lastID:activity.activity_id result:^(DXSearchActivityWrapper *searchActivityWrapper, NSError *error) {
        if (searchActivityWrapper.list.count) {
            if (pullType == DXDataListPullNewerList) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, searchActivityWrapper.list.count)];
                [weakSelf.dataList insertObjects:searchActivityWrapper.list atIndexes:indexSet];
            } else {
                [weakSelf.dataList addObjectsFromArray:searchActivityWrapper.list];
            }
            if (pullType == DXDataListPullFirstTime && weakSelf.collectionView.mj_footer.isHidden && searchActivityWrapper.list.count == 20) {
                weakSelf.collectionView.mj_footer.hidden = NO;
            }
        }
        if (completionBlock) {
            completionBlock(searchActivityWrapper.more, error);
        }
    }];
}

- (void)fetchFeedListWithPullType:(DXDataListPullType)pullType completion:(void(^)(BOOL more, NSError *error))completionBlock {
    
    DXTimelineFeed *feed = nil;
    if (pullType == DXDataListPullNewerList) {
        feed = [self.dataList firstObject];
    } else if (pullType == DXDataListPullOlderList) {
        feed = [self.dataList lastObject];
    }
    if (feed == nil) {
        pullType = DXDataListPullFirstTime;
    }
    
    [self.api getSearchFeedWrapperByKeywords:self.keywords pullType:pullType count:20 lastID:feed.fid result:^(DXSearchFeedWrapper *searchFeedWrapper, NSError *error) {
        if (searchFeedWrapper.list.count) {
            if (pullType == DXDataListPullNewerList) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, searchFeedWrapper.list.count)];
                [weakSelf.dataList insertObjects:searchFeedWrapper.list atIndexes:indexSet];
            } else {
                [weakSelf.dataList addObjectsFromArray:searchFeedWrapper.list];
            }
            if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer.isHidden && searchFeedWrapper.list.count == 20) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        }
        if (completionBlock) {
            completionBlock(searchFeedWrapper.more, error);
        }
    }];
}

#pragma mark - table view dataSource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.dataList.count == 0) {
        return 1;
    }
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count == 0) {
        DXNoneDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDNoneDataTableViewCell forIndexPath:indexPath];
        cell.text = self.errorDescription;
        return cell;
    } else {
        DXFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:IDFeedCell];
        if (cell == nil) {
            cell = [[DXFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDFeedCell];
        }
        DXTimelineFeed *feed = self.dataList[indexPath.row];
        
        cell.feed = feed;
        cell.indexPath = indexPath;
        cell.delegate = self;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        DXTimelineFeed *feed = self.dataList[indexPath.row];
        return [DXFeedCell tableView:tableView heightForRowAtIndexPath:indexPath withFeed:feed];
    } else {
        return DXRealValue(120);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        DXTimelineFeed *feed = self.dataList[indexPath.row];
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

#pragma mark - collection view dataSource and delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.dataList.count == 0) {
        return 1;
    }
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count == 0) {
        DXNoneDataCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDNoneDataCollectionViewCell forIndexPath:indexPath];
        cell.text = self.errorDescription;
        return cell;
    } else {
        switch (self.searchMoreType) {
            case DXSearchMoreTypeTopic:
            {
                DXSearchResultsTopicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDSearchResultsTopicCell forIndexPath:indexPath];
                DXTopic *topic = self.dataList[indexPath.item];
                cell.topic = topic;
                return cell;
            }
                break;
            case DXSearchMoreTypeUser:
            {
                DXSearchResultsUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDSearchResultsUserCell forIndexPath:indexPath];
                DXUser *user = self.dataList[indexPath.item];
                cell.user = user;
                return cell;
            }
                break;
            case DXSearchMoreTypeActivity:
            {
                DXActivityListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDActivityListCell forIndexPath:indexPath];
                DXActivity *activity = self.dataList[indexPath.item];
                cell.separateView.hidden = NO;
                cell.nameLabel.text = activity.activity;
                cell.typeAndPlace = [NSString stringWithFormat:@"%@・%@", activity.typeText, activity.city];
                cell.time = activity.days;
                cell.descriptionLabel.text = activity.abstract;
                UIImage * placeHolderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(100), DXRealValue(100))];
                [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:activity.avatar] placeholderImage:placeHolderImage options:SDWebImageRetryFailed];
                return cell;
            }
                break;
                
            default:
                return nil;
                break;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataList.count == 0) {
        return CGSizeMake(DXScreenWidth, roundf(DXRealValue(120)));
    } else {
        switch (self.searchMoreType) {
            case DXSearchMoreTypeTopic:
                return CGSizeMake(DXScreenWidth, roundf(DXRealValue(76)));
                break;
            case DXSearchMoreTypeUser:
                return CGSizeMake(DXScreenWidth, roundf(DXRealValue(60)));
                break;
            case DXSearchMoreTypeActivity:
                return CGSizeMake(DXScreenWidth, roundf(DXRealValue(100)));
                break;
                
            default:
                return CGSizeZero;
                break;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        switch (self.searchMoreType) {
            case DXSearchMoreTypeTopic:
            {
                DXTopic *topic = self.dataList[indexPath.item ];
                DXTopicViewController * topicVC = [[DXTopicViewController alloc] init];
                topicVC.topicID = topic.topic_id;
                topicVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:topicVC animated:YES];
            }
                break;
            case DXSearchMoreTypeUser:
            {
                DXUser *user = self.dataList[indexPath.item];
                DXProfileViewController *vc = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
                vc.uid = user.uid;
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case DXSearchMoreTypeActivity:
            {
                DXActivity *activity = self.dataList[indexPath.item];
                DXEventViewController * eventVC = [[DXEventViewController alloc] init];
                eventVC.activityID = activity.activity_id;
                eventVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:eventVC animated:YES];
            }
                break;
                
            default:
                break;
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

- (void)likeInfoShouldChangeWithFeed:(DXTimelineFeed *)feed completion:(void(^)(BOOL))completion {
    
    NSString *myUid = [self.api currentUserSession].uid;
    NSString *myAvatar = [self.api currentUserSession].avatar;
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObjectsFromArray:feed.data.likes];
    
    if (!feed.data.is_like) { // 点赞
        [[DXDongXiApi api] likeFeedWithFeedID:feed.fid result:^(BOOL success, NSError *error) {
            if (!success) {
                feed.data.is_like = NO;
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后尝试";
                NSString * message = [NSString stringWithFormat:@"点赞失败，%@", reason];
                DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                [alert setMessage:message];
                [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:nil]];
                [alert showInController:weakSelf animated:YES completion:nil];
            } else {
                DXTimelineFeedLiker *liker = [[DXTimelineFeedLiker alloc] init];
                liker.uid = myUid;
                liker.avatar = myAvatar;
                liker.verified = [self.api currentUserSession].verified;
                [temp insertObject:liker atIndex:0];
                feed.data.likes = temp;
                feed.data.is_like = YES;
                feed.data.total_like += 1;
                [weakSelf.tableView reloadData];
            }
            
            if (completion) {
                completion(success);
            }
        }];
        
        feed.data.is_like = YES;
    } else { // 取消赞
        
        [[DXDongXiApi api] unlikeFeedWithFeedID:feed.fid result:^(BOOL success, NSError *error) {
            if (!success) {
                feed.data.is_like = YES;
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后尝试";
                NSString * message = [NSString stringWithFormat:@"取消赞失败，%@", reason];
                DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                [alert setMessage:message];
                [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:nil]];
                [alert showInController:weakSelf animated:YES completion:nil];
            } else {
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
            }
            
            if (completion) {
                completion(success);
            }
        }];
        
        feed.data.is_like = NO;
    }
}

#pragma mark - 点击相关按钮

- (void)backBtnDidClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 通知

- (void)registerNotification {
    
    // 点赞信息改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeLikeInfoNotification:) name:DXLikeInfoDidChangeNotification object:nil];
}

- (void)removeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXLikeInfoDidChangeNotification object:nil];
}

#pragma mark - 收到通知后执行的方法

- (void)handleChangeLikeInfoNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *feedID = [userInfo objectForKey:kFeedIDKey];
    BOOL isLike = [[userInfo objectForKey:kLikeStatusKey] boolValue];
    
    for (DXTimelineFeed *feed in self.dataList) {
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

- (NSMutableArray *)dataList {
    if (_dataList == nil) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
