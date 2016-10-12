//
//  DXFeedHeaderView.h
//  dongxi
//
//  Created by 穆康 on 15/9/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXTimelineFeed;

/** 点击了头像 */
extern NSString *const kRouterEventAvatarViewDidTapEventName;
/** 点击了话题 */
extern NSString *const kRouterEventTopicViewDidTapEventName;

@interface DXFeedHeaderView : UIView

@property (nonatomic, strong) DXTimelineFeed *feed;

/**
 *  视图高度
 */
+ (CGFloat)heightForHeaderViewWithFeed:(DXTimelineFeed *)feed;

@end
