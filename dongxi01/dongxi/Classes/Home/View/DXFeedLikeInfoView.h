//
//  DXFeedLikeInfoView.h
//  dongxi
//
//  Created by 穆康 on 15/11/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  点赞头像、点赞人数及评论人数视图

#import <UIKit/UIKit.h>
@class DXTimelineFeed;

@interface DXFeedLikeInfoView : UIView

@property (nonatomic, strong) DXTimelineFeed *feed;

/**
 *  视图高度
 */
+ (CGFloat)heightForLikeInfoViewWithFeed:(DXTimelineFeed *)feed;

@end
