//
//  DXHomeViewControllerV2.m
//  dongxi
//
//  Created by 穆康 on 16/8/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXHomeViewControllerV2.h"

#import "DXFeedListViewFlowLayout.h"
#import "DXFeedViewCell.h"
#import "DXFeedHeaderViewV2.h"

#import "UIImage+Extension.h"

@interface DXHomeViewControllerV2 () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) DXDongXiApi *api;
@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation DXHomeViewControllerV2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置导航栏
    [self setupNavBar];
    // 设置内容
    [self setupContent];
    // 首次获取数据
    [self loadDataFirst];
}

#pragma mark - 设置导航栏和内容
/**
 *  设置导航栏
 */
- (void)setupNavBar {
    
    self.navigationItem.title = @"東西";
    UIImage *bgImage = [UIImage imageWithColor:DXRGBColor(247, 250, 251)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont fontWithName:DXCommonBoldFontName size:18],
                                                                    NSForegroundColorAttributeName : DXCommonColor
                                                                    };
}
/**
 *  设置内容
 */
- (void)setupContent {
    DXFeedListViewFlowLayout *layout = [[DXFeedListViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = DXRGBColor(240, 240, 240);
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [collectionView registerClass:[DXFeedViewCell class] forCellWithReuseIdentifier:@"DXFeedViewCell"];
    [collectionView registerClass:[DXFeedHeaderViewV2 class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DXFeedHeaderViewV2"];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
}

#pragma mark - 获取数据

- (void)loadDataFirst {
    [self.api getFeedHomeList:DXDataListPullFirstTime count:20 lastID:nil userTimestamp:0 topicTimestamp:0 result:^(DXFeedHomeList *feedList, NSError *error) {
        if (feedList) {
            [self.feeds addObjectsFromArray:feedList.list];
            [self.collectionView reloadData];
        }
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.feeds.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DXFeedViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXFeedViewCell" forIndexPath:indexPath];
    DXFeed *feed = self.feeds[indexPath.section];
    cell.feed = feed;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DXFeedHeaderViewV2 *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DXFeedHeaderViewV2" forIndexPath:indexPath];
    DXFeed *feed = self.feeds[indexPath.section];
    headerView.feed = feed;
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.feeds) {
        DXFeed *feed = self.feeds[indexPath.section];
        return [DXFeedViewCell collectionView:collectionView heightForRowAtIndexPath:indexPath withFeed:feed];
    } else {
        return CGSizeZero;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
