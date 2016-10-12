//
//  DXLocationListViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLocationListViewController.h"
#import "DXPublishLocationTableViewCell.h"
#import "DXDongXiApi.h"

@interface DXLocationListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UISearchBar * searchBar;
@property (nonatomic, strong) UISearchDisplayController * searchController;

@property (nonatomic, strong) NSArray * locationList;
@property (nonatomic, assign) BOOL locationListLoaded;
@property (nonatomic, strong) NSArray * searchResults;

@property (nonatomic, assign) BOOL updatingLocation;
@property (nonatomic, strong) CLLocationManager * locationManager;

@end

@implementation DXLocationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"所在位置";
    self.view.backgroundColor = DXRGBColor(221, 221, 221);
    
    self.dt_pageName = DXDataTrackingPage_PhotoPublishLocations;

    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 38)];
    searchBar.tintColor = DXCommonColor;
    [searchBar setBackgroundImage:[UIImage imageNamed:@"GrayPixel"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [searchBar setBackgroundImage:[UIImage imageNamed:@"GrayPixel"]];
    searchBar.searchBarStyle = UISearchBarStyleProminent;
    searchBar.placeholder = @"搜索附近位置";
    searchBar.translucent = NO;
    self.searchBar = searchBar;

    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    self.searchController.searchResultsTitle = @"搜索结果";
    self.searchController.searchResultsTableView.separatorColor = DXRGBColor(221, 221, 221);
    self.searchController.searchResultsTableView.backgroundColor = DXRGBColor(221, 221, 221);
    self.searchController.searchResultsTableView.separatorInset = UIEdgeInsetsZero;
    if ([self.searchController.searchResultsTableView respondsToSelector:@selector(layoutMargins)]) {
        self.searchController.searchResultsTableView.layoutMargins = UIEdgeInsetsZero;
    }

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    //暂时屏蔽位置搜索工具栏，待确定是否需要增加
//    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.separatorColor = DXRGBColor(221, 221, 221);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    [self.view addSubview:self.tableView];

    [self.tableView registerClass:[DXPublishLocationTableViewCell class]
           forCellReuseIdentifier:@"DXPublishLocationTableViewCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10.0f;
    self.locationManager.delegate = self;
    
    self.locationList = [NSMutableArray array];
    self.searchResults = [NSMutableArray array];

    if (!self.selectedPOI) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopUpdatingLocation];

    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self stopUpdatingLocation];
}

- (void)dealloc {
    [self stopUpdatingLocation];
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.locationList.count + 1;
    } else if (tableView == self.searchController.searchResultsTableView) {
        return self.searchResults.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXPublishLocationTableViewCell" forIndexPath:indexPath];
    if (tableView == self.tableView) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"不显示位置";
        } else {
            NSDictionary * poi = [self.locationList objectAtIndex:indexPath.row-1];
            NSString * poiAddress = [poi objectForKey:@"addr"];
            NSString * poiName = [poi objectForKey:@"name"];

            cell.textLabel.text = poiName;
            cell.detailTextLabel.text = poiAddress;
        }
    }

    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DXRealValue(162.0/3);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationListViewController:didSelectPOI:)]) {
        NSDictionary * poi = nil;
        if (indexPath.row > 0) {
            poi = [self.locationList objectAtIndex:indexPath.row-1];
        }
        [self.delegate locationListViewController:self didSelectPOI:poi];
    }

    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 

- (void)refreshLocationList {
   [[DXDongXiApi api] getAddressOfLatitude:self.currentCoordinate.latitude andLongitude:self.currentCoordinate.longitude result:^(BOOL status, NSString *address, NSArray *pois, NSError *error) {
       if (!error) {
           if (address != nil && pois != nil) {
               self.locationList = pois;
               [self.tableView reloadData];
               if (self.selectedPOI) {
                   NSString * selectedPOIID = [self.selectedPOI objectForKey:@"uid"];
                   for (int i = 0; i < pois.count; i++) {
                       NSDictionary * poi = [pois objectAtIndex:i];
                       NSString * poiID = [poi objectForKey:@"uid"];
                       if ([poiID isEqualToString:selectedPOIID]) {
                           [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                           break;
                       }
                   }
               } else {
                   [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
               }
           }
       }
   }];
}

- (void)startUpdatingLocation {
    CLAuthorizationStatus authroizationStatus = [CLLocationManager authorizationStatus];
    if (authroizationStatus != kCLAuthorizationStatusRestricted &&
        authroizationStatus != kCLAuthorizationStatusDenied) {
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"无法使用位置服务" message:@"请检查应用设置" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
        return;
    }
    
    [self.locationManager startUpdatingLocation];
}


- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    self.currentCoordinate = newLocation.coordinate;
    if (!self.locationListLoaded) {
        [self refreshLocationList];
        self.locationListLoaded = YES;
    }
}




@end
