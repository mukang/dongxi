//
//  DXMapViewController.m
//  dongxi
//
//  Created by 穆康 on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMapViewController.h"
#import "UIBarButtonItem+Extension.h"
#import <MapKit/MapKit.h>
#import "DXAnnotation.h"
#import "DXDongXiApi.h"

@interface DXMapViewController ()

@property (nonatomic, weak) MKMapView *mapView;

@end

@implementation DXMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏
    [self setupNavBar];
    
    // 设置地图
    [self setupMapView];
}

/**
 *  设置导航栏
 */
- (void)setupNavBar {
    
    self.title = @"地图";
    self.dt_pageName = DXDataTrackingPage_PhotoMap;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(backBtnDidClick)];
}

/**
 *  设置地图
 */
- (void)setupMapView {
    
    MKMapView *mapView = [[MKMapView alloc] init];
    mapView.mapType = MKMapTypeStandard;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.feed.data.lat, self.feed.data.lng);
    mapView.region = MKCoordinateRegionMake(coordinate, span);
    mapView.frame = self.view.bounds;
    [self.view addSubview:mapView];
    self.mapView = mapView;
    
    [self addAnnotationWithCoordinate:coordinate];
}

- (void)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    
    DXAnnotation *annotation = [[DXAnnotation alloc] init];
    annotation.title = self.feed.data.place;
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
}

#pragma mark - 点击按钮执行的方法

/**
 *  点击返回按钮
 */
- (void)backBtnDidClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
