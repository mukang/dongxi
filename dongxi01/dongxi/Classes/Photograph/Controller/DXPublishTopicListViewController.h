//
//  DXPublishTopicListViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXTopicDetail;
@protocol DXPublishTopicListViewControllerDelegate;


@interface DXPublishTopicListViewController : UIViewController

@property (nonatomic, strong) NSString * topicID;
@property (nonatomic, weak) id<DXPublishTopicListViewControllerDelegate> delegate;

@end



@protocol DXPublishTopicListViewControllerDelegate <NSObject>

@optional

- (void)userDidSelectTopic:(NSString *)topicID andTitle:(NSString *)text;

@end
