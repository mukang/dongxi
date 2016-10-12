//
//  DXDiscoverEventViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDiscoverEventViewController.h"
#import "DXDongXiApi.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "DXTopActivityCell.h"
#import "DXActivityListCell.h"
#import "DXEventViewController.h"
#import "DXNoneDataCollectionViewCell.h"
#import "UIImage+Extension.h"
#import <MJRefresh.h>
#import "UIViewController+DXDataTracking.h"

@interface DXDiscoverEventViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) DXDongXiApi * api;
@property (nonatomic, strong) DXActivity * topActivity;
@property (nonatomic, strong) NSMutableArray * activityList;

@property (nonatomic, assign) BOOL firstTimeLoaded;
@property (nonatomic, copy) NSString * errorDescription;

@end

@implementation DXDiscoverEventViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = DXRGBColor(0xde, 0xde, 0xde);
    self.dt_pageName = DXDataTrackingPage_DiscoverActivities;
    
    [self setupSubviews];
    
    [self refreshActivityList:nil];
    
    // 添加下拉刷新
    self.collectionView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadNetData)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews {
    UICollectionViewFlowLayout * collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:collectionViewLayout];
    self.collectionView.backgroundColor = DXRGBColor(0xde, 0xde, 0xde);
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[DXTopActivityCell class] forCellWithReuseIdentifier:@"DXTopActivityCell"];
    [self.collectionView registerClass:[DXActivityListCell class] forCellWithReuseIdentifier:@"DXActivityListCell"];
    [self.collectionView registerClass:[DXNoneDataCollectionViewCell class] forCellWithReuseIdentifier:@"DXNoneDataCollectionViewCell"];
    
    [self.view addSubview:self.collectionView];
}


#pragma mark - Property Methods

- (DXDongXiApi *)api {
    if (nil == _api) {
        _api = [DXDongXiApi api];
    }
    return _api;
}

- (NSMutableArray *)activityList {
    if (nil == _activityList) {
        _activityList = [NSMutableArray array];
    }
    return _activityList;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.firstTimeLoaded && self.topActivity == nil && self.activityList.count == 0) {
        if (section == 0) {
            return 1;
        }
    }
    
    if (section == 0) {
        return self.topActivity == nil ? 0 : 1;
    } else {
        return self.activityList.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = nil;
    
    if (self.firstTimeLoaded && self.topActivity == nil && self.activityList.count == 0) {
        if (indexPath.section == 0) {
            DXNoneDataCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXNoneDataCollectionViewCell" forIndexPath:indexPath];
            cell.text = self.errorDescription;
            return cell;
        }
    }
    
    if (indexPath.section == 0) {
        DXTopActivityCell * topActivityCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXTopActivityCell" forIndexPath:indexPath];
        topActivityCell.nameLabel.text = self.topActivity.activity;
        topActivityCell.typeAndPlaceLabel.text = [NSString stringWithFormat:@"%@・%@", self.topActivity.typeText, self.topActivity.city];
        topActivityCell.timeLabel.text = self.topActivity.days;
        UIImage * placeHolderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXScreenWidth, DXRealValue(160))];
        [topActivityCell.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.topActivity.cover] placeholderImage:placeHolderImage options:SDWebImageRetryFailed];
        cell = topActivityCell;
    } else {
        DXActivity * activity = [self.activityList objectAtIndex:indexPath.item];
        DXActivityListCell * activityListCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXActivityListCell" forIndexPath:indexPath];
        activityListCell.separateView.hidden = YES;
        activityListCell.nameLabel.text = activity.activity;
        activityListCell.typeAndPlace = [NSString stringWithFormat:@"%@・%@", activity.typeText, activity.city];
        activityListCell.time = activity.days;
        activityListCell.descriptionLabel.text = activity.abstract;
        UIImage * placeHolderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(100), DXRealValue(100))];
        [activityListCell.coverImageView sd_setImageWithURL:[NSURL URLWithString:activity.avatar] placeholderImage:placeHolderImage options:SDWebImageRetryFailed];
        cell = activityListCell;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.firstTimeLoaded && self.topActivity == nil && self.activityList.count == 0) {
        if (indexPath.section == 0) {
            return CGSizeMake(DXScreenWidth, DXRealValue(120));
        }
    }
    
    if (indexPath.section == 0) {
        return CGSizeMake(DXScreenWidth, DXRealValue(160));
    } else {
        return CGSizeMake(DXScreenWidth, DXRealValue(100));
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 3.3f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 3.3f, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.firstTimeLoaded && self.topActivity == nil && self.activityList.count == 0) {
        if (indexPath.section == 0) {
            return;
        }
    }
    
    
    DXActivity * activity = nil;
    if (indexPath.section == 0) {
        activity = self.topActivity;
    } else {
        if (self.activityList.count > indexPath.item) {
            activity = [self.activityList objectAtIndex:indexPath.item];
        }
    }
    
    if (activity) {
        DXEventViewController * eventVC = [[DXEventViewController alloc] init];
        eventVC.activityID = activity.activity_id;
        eventVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:eventVC animated:YES];
    }
}


#pragma mark -

- (void)reloadNetData {
    
    __weak typeof(self) weakSelf = self;
    [self refreshActivityList:^(BOOL success) {
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
}

- (void)refreshActivityList:(void(^)(BOOL success))finshBlock {
    __weak typeof(self) weakSelf = self;
    
    [self.api getActivityList:^(NSArray *activityList, NSError *error) {
        weakSelf.firstTimeLoaded = YES;
        
        if (!error) {
            [weakSelf.activityList removeAllObjects];
            BOOL findTopActivity = NO;
            for (DXActivity * activity in activityList) {
                if (!findTopActivity && activity.is_top) {
                    weakSelf.topActivity = activity;
                    findTopActivity = YES;
                } else {
                    [weakSelf.activityList addObject:activity];
                }
            }
            if (weakSelf.topActivity == nil || weakSelf.activityList.count == 0) {
                weakSelf.errorDescription = @"暂时没有活动，先去其他地方看看吧";
            }
        } else {
            if (error.localizedDescription) {
                weakSelf.errorDescription = error.localizedDescription;
            } else {
                weakSelf.errorDescription = @"请稍后重试";
            }
            
            if (weakSelf.activityList.count > 0) {
                DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                [alert setMessage:weakSelf.errorDescription];
                [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:nil]];
                [alert showInController:weakSelf animated:YES completion:nil];
            }
        }
        
        [weakSelf.collectionView reloadData];
        if (finshBlock) {
            finshBlock(error == nil);
        }
    }];
}


@end
