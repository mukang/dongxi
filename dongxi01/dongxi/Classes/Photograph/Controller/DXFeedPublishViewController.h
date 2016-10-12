//
//  DXFeedPublishViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXTimelineFeed;
@protocol DXFeedPublishDelegateController;


@interface DXFeedPublishViewController : UIViewController

/** 用于修改feed */
@property (nonatomic, strong) DXTimelineFeed *feed;

/** 话题ID，可以为nil */
@property (nonatomic, strong) NSString * topicID;

/** 如果有话题ID，话题名称 */
@property (nonatomic, strong) NSString * topicTitle;

/** 如果有话题ID，话题是否为有奖话题 */
@property (nonatomic, assign) BOOL topicHasPrize;

@property (nonatomic, weak) UIViewController<DXFeedPublishDelegateController> * delegateController;

- (void)appendPhoto:(UIImage *)photo;

@end


@protocol DXFeedPublishDelegateController <NSObject>

@required
- (void)feedPublishController:(DXFeedPublishViewController *)feedPublishController didPublishFeed:(DXTimelineFeed *)feed;

@end