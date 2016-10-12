//
//  DXLocationListViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol DXLocationListViewControllerDelegate;


@interface DXLocationListViewController : UIViewController

@property (nonatomic, weak) id<DXLocationListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary * selectedPOI;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;

@end


@protocol DXLocationListViewControllerDelegate <NSObject>

@optional
- (void)locationListViewController:(DXLocationListViewController *)controller didSelectPOI:(NSDictionary *)poi;

@end


