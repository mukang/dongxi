//
//  DXPublishPhotoListViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXPublishPhotoListViewControllerDelegate;


@interface DXPublishPhotoListViewController : UIViewController

@property (nonatomic, weak) id<DXPublishPhotoListViewControllerDelegate> delegate;
@property (nonatomic, readonly) NSArray * photos;

@property (nonatomic, assign, getter=isEditingFeed) BOOL editingFeed;
@property (nonatomic, strong) NSMutableArray *editingPhotos;

@property (nonatomic, strong, readonly) NSArray *editingPhotoIDs;
@property (nonatomic, strong, readonly) NSArray *editingPhotoURLs;

- (CGFloat)viewHeightForWidth:(CGFloat)width;
- (void)appendPhoto:(UIImage *)photo;

@end


@protocol DXPublishPhotoListViewControllerDelegate <NSObject>

@optional
- (void)photosDidChangeInController:(UIViewController *)controller;

@end
