//
//  DXDetailViewController.h
//  dongxi
//
//  Created by 穆康 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXTimelineFeed;

typedef NS_ENUM(NSInteger, DXDetailType) {
    DXDetailTypeContent,                   // 显示feed内容
    DXDetailTypeComment                    // 显示feed评论
};

typedef NS_ENUM(NSInteger, DXDetailViewControllerType) {
    DXDetailViewControllerTypeFeed,        // 通过feed来访问
    DXDetailViewControllerTypeFeedID       // 通过feedID来访问
};

typedef void(^DXFeedInfoChangeBlock)(DXTimelineFeed *feed);

@interface DXDetailViewController : UIViewController

/** feedID和feed传一个就行 */
@property (nonatomic, copy) NSString *feedID;
@property (nonatomic, strong) DXTimelineFeed *feed;

/** 展示详情还是评论 */
@property (nonatomic, assign) DXDetailType detailType;
/** feed内容变化的回调 */
@property (nonatomic, copy) DXFeedInfoChangeBlock infoChangeBlock;

@property (nonatomic, readonly, assign) DXDetailViewControllerType controllerType;

/** 指定初始化方法 */
- (instancetype)initWithControllerType:(DXDetailViewControllerType)controllerType;

@end
