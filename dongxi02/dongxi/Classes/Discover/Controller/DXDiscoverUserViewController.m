//
//  DXDiscoverUserViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDiscoverUserViewController.h"
#import "DXProfileViewController.h"
#import "DXLoginViewController.h"
#import "DXDiscoverUserViewCell.h"
#import "DXNoneDataCollectionViewCell.h"
#import "DXDongXiApi.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MJRefresh.h>
#import "UIViewController+DXDataTracking.h"

typedef void(^DXCompletionBlock)(BOOL more, NSError *error);

@interface DXDiscoverUserViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DXDiscoverUserViewCellDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout * flowLayout;
@property (nonatomic, strong) NSMutableDictionary * cellSizeCache;

@property (nonatomic, strong) DXDongXiApi * api;
@property (nonatomic, strong) NSMutableArray * recommendUsers;

@property (nonatomic, assign) BOOL firstTimeLoaded;
@property (nonatomic, copy) NSString * errorDescription;

@end

@implementation DXDiscoverUserViewController

- (NSMutableArray *)recommendUsers {
    
    if (_recommendUsers == nil) {
        _recommendUsers = [NSMutableArray array];
    }
    return _recommendUsers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    self.dt_pageName = DXDataTrackingPage_DiscoverActivities;
    
    [self setupSubviews];
    
    self.api = [DXDongXiApi api];
    self.cellSizeCache = [NSMutableDictionary dictionary];
    
    // 添加上下拉刷新
    self.collectionView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.collectionView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
    self.collectionView.mj_footer.hidden = YES;
    
    __weak DXDiscoverUserViewController * weakSelf = self;
    [self.api getDiscoverUserList:15 pullType:DXDataListPullFirstTime lastID:nil result:^(DXDiscoverUserWrapper *userWrapper, NSError *error) {
        weakSelf.firstTimeLoaded = YES;
        
        if (userWrapper) {
            [weakSelf.recommendUsers addObjectsFromArray:userWrapper.list];
            if (weakSelf.recommendUsers.count == 0) {
                weakSelf.errorDescription = @"暂时没有推荐的用户";
            }
            if (weakSelf.collectionView.mj_footer.isHidden && userWrapper.list.count == 15) {
                weakSelf.collectionView.mj_footer.hidden = NO;
            }
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
        }
        [weakSelf.collectionView reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenUserDidLogout:) name:DXDongXiApiNotificationUserDidLogout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenUserDidLogin:) name:DXDongXiApiNotificationUserDidLogin object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableDictionary *)cellSizeCache {
    if (nil == _cellSizeCache) {
        _cellSizeCache = [NSMutableDictionary dictionary];
    }
    return _cellSizeCache;
}

#pragma mark - Views

- (void)setupSubviews {
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_collectionView registerClass:[DXDiscoverUserViewCell class] forCellWithReuseIdentifier:@"DXDiscoverUserViewCell"];
    [_collectionView registerClass:[DXNoneDataCollectionViewCell class] forCellWithReuseIdentifier:@"DXDiscoverNoneUserViewCell"];
    [self.view addSubview:_collectionView];
}

#pragma mark - LoadData

- (void)loadNewData {
    
    __weak typeof(self) weakSelf = self;
    [self loadDataWithPullType:DXDataListPullNewerList Completion:^(BOOL more, NSError *error) {
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
}

- (void)loadOldData {
    
    __weak typeof(self) weakSelf = self;
    [self loadDataWithPullType:DXDataListPullOlderList Completion:^(BOOL more, NSError *error) {
        if (error) {
            DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.collectionView.mj_footer;
            [footer endRefreshingWithError];
        } else {
            if (!more) {
                weakSelf.collectionView.mj_footer.hidden = YES;
            } else {
                [weakSelf.collectionView.mj_footer endRefreshing];
            }
        }
    }];
}

- (void)loadDataWithPullType:(DXDataListPullType)pullType Completion:(DXCompletionBlock)completionBlock {
    
    NSString *ID = nil;
    if (pullType == DXDataListPullNewerList) {
        DXDiscoverUser * user = [self.recommendUsers firstObject];
        ID = user.ID;
    } else if (pullType == DXDataListPullOlderList) {
        DXDiscoverUser * user = [self.recommendUsers lastObject];
        ID = user.ID;
    }
    
    if (ID == nil) {
        pullType = DXDataListPullFirstTime;
    }
    
    __weak typeof(self) weakSelf = self;
    [[DXDongXiApi api] getDiscoverUserList:15 pullType:pullType lastID:ID result:^(DXDiscoverUserWrapper *userWrapper, NSError *error) {
        if (userWrapper) {
            if (pullType == DXDataListPullNewerList) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, userWrapper.list.count)];
                [weakSelf.recommendUsers insertObjects:userWrapper.list atIndexes:indexSet];
            } else {
                [weakSelf.recommendUsers addObjectsFromArray:userWrapper.list];
            }
            if (weakSelf.recommendUsers.count == 0) {
                weakSelf.errorDescription = @"暂时没有推荐的用户";
            }
            if (pullType == DXDataListPullFirstTime && weakSelf.collectionView.mj_footer.isHidden && userWrapper.list.count == 15) {
                weakSelf.collectionView.mj_footer.hidden = NO;
            }
        } else {
            NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            weakSelf.errorDescription = [NSString stringWithFormat:@"加载失败，%@", reason];
            if (weakSelf.recommendUsers.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDescription];
        }
        [weakSelf.collectionView reloadData];
        if (completionBlock) {
            completionBlock(userWrapper.more, error);
        }
    }];
}

#pragma mark - 用户切换

- (void)whenUserDidLogin:(NSNotification *)noti {
    [self clearUserRelatedData];
}

- (void)whenUserDidLogout:(NSNotification *)noti {
    [self clearUserRelatedData];
}

- (void)clearUserRelatedData {
    [self.recommendUsers removeAllObjects];
    if (self.collectionView.mj_footer.hidden == NO) {
        self.collectionView.mj_footer.hidden = YES;
    }
    [self loadDataWithPullType:DXDataListPullNewerList Completion:nil];
}


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.recommendUsers.count == 0 && self.firstTimeLoaded) {
        return 1;
    } else {
        return self.recommendUsers.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.recommendUsers.count == 0 && self.firstTimeLoaded) {
        DXNoneDataCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXDiscoverNoneUserViewCell" forIndexPath:indexPath];
        cell.text = self.errorDescription;
        return cell;
    } else {
        DXDiscoverUserViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXDiscoverUserViewCell" forIndexPath:indexPath];
        DXDiscoverUser * user = [self.recommendUsers objectAtIndex:indexPath.item];
        cell.nick = user.nick;
        [cell.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:nil options:SDWebImageRetryFailed];
        cell.avatarView.verified = user.verified;
        cell.avatarView.certificationIconSize = DXCertificationIconSizeLarge;
        [cell.photoView1 sd_setImageWithURL:[NSURL URLWithString:user.bio_pic1] placeholderImage:nil options:SDWebImageRetryFailed];
        [cell.photoView2 sd_setImageWithURL:[NSURL URLWithString:user.bio_pic2] placeholderImage:nil options:SDWebImageRetryFailed];
        [cell.photoView3 sd_setImageWithURL:[NSURL URLWithString:user.bio_pic3] placeholderImage:nil options:SDWebImageRetryFailed];
        cell.text = user.bio;
        cell.relation = user.relations;
        cell.delegate = self;
        return cell;
    }
}


#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath; {
    
    if (self.recommendUsers.count == 0 && self.firstTimeLoaded) {
        return CGSizeMake(DXScreenWidth, DXRealValue(120));
    } else {
        DXDiscoverUser * user = [self.recommendUsers objectAtIndex:indexPath.item];
        
        NSString * cellSizeKey = [NSString stringWithFormat:@"user %@", user.uid];
        NSValue * cellSizeValue = [self.cellSizeCache objectForKey:cellSizeKey];
        if (cellSizeValue) {
            return [cellSizeValue CGSizeValue];
        } else {
            DXDiscoverUserViewCell * cell = [[DXDiscoverUserViewCell alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, 0)];
            cell.text = user.bio;
            cell.nick = user.nick;
            [cell.containerView setNeedsLayout];
            [cell.containerView layoutIfNeeded];
            CGFloat height = [cell.containerView systemLayoutSizeFittingSize:CGSizeMake(DXScreenWidth, 0)].height;
            CGSize itemSize = CGSizeMake(DXScreenWidth, height);
            [self.cellSizeCache setObject:[NSValue valueWithCGSize:itemSize] forKey:cellSizeKey];
            return itemSize;
        }
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 3.3f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //顶部额外减去1个pt是因为导航栏下面原本就有1个pt的阴影间隙
    return UIEdgeInsetsMake(3.3f-1, 0, 3.3f, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.recommendUsers.count > 0) {
        DXDiscoverUser * user = [self.recommendUsers objectAtIndex:indexPath.item];
        DXProfileViewController * profileViewController = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
        profileViewController.uid = user.uid;
        profileViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}


#pragma mark - <DXDiscoverUserViewCellDelegate>

- (void)didTapAvatarInDiscoverUserViewCell:(DXDiscoverUserViewCell *)cell {
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    DXDiscoverUser * user = [self.recommendUsers objectAtIndex:indexPath.item];
    DXProfileViewController * profileViewController = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
    profileViewController.uid = user.uid;
    profileViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)didTapFollowButtonInDiscoverUserViewCell:(DXDiscoverUserViewCell *)cell {
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
    
    
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    __weak DXDiscoverUser * user = [self.recommendUsers objectAtIndex:indexPath.item];
    if (user.relations == DXUserRelationTypeNone || user.relations == DXUserRelationTypeFollower) {
        [[DXDongXiApi api] followUser:user.uid result:^(BOOL success, DXUserRelationType relation, NSError *error) {
            if (success) {
                user.relations = relation;
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            } else {
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                NSString * message = [NSString stringWithFormat:@"关注失败，%@", reason];
                [MBProgressHUD showHUDWithMessage:message];
            }
        }];
    } else {
        [[DXDongXiApi api] unfollowUser:user.uid result:^(BOOL success, DXUserRelationType relation, NSError *error) {
            if (success) {
                user.relations = relation;
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            } else {
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                NSString * message = [NSString stringWithFormat:@"取消关注失败，%@", reason];
                [MBProgressHUD showHUDWithMessage:message];
            }
        }];
    }
}

@end
