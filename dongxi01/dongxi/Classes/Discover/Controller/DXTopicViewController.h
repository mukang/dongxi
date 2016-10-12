//
//  DXTopicViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXTableView.h"
#import "DXTabBarView.h"

@class DXTopic;
@class DXTimelineFeed;

@interface DXTopicViewController : UIViewController

@property (nonatomic, strong) NSString * topicID;

@property (nonatomic, copy) void(^updateTopicBlock)(DXTopicDetail *topicDetail);

@property (nonatomic, strong) DXTableView * tableView;
@property (nonatomic, strong) DXTableView * hotTableView;

- (void)selectTableAtIndex:(NSInteger)tableIndex;

- (void)insertFeed:(DXTimelineFeed *)feed atRow:(NSUInteger)row inTable:(NSUInteger)tableIndex;

@end
