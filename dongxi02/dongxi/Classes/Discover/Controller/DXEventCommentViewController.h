//
//  DXEventCommentViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXActivity;

extern NSString * const DXEventCommentNeedRefreshNotification;

@interface DXEventCommentViewController : UIViewController

@property (nonatomic) DXActivity * activity;

@end