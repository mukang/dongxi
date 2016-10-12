//
//  DXFeedToolBar.h
//  dongxi
//
//  Created by 穆康 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXFeedLikeView.h"
@class DXTimelineFeed;

extern NSString *const kRouterEventLikeViewDidTapEventName;
extern NSString *const kRouterEventCommentViewDidTapEventName;
extern NSString *const kRouterEventChatViewDidTapEventName;
extern NSString *const kRouterEventShareViewDidTapEventName;

typedef NS_ENUM(NSInteger, DXFeedToolBarType) {
    DXFeedToolBarTypeList,       // 列表里的工具栏
    DXFeedToolBarTypeDetail      // 详情里的工具栏
};

@protocol DXFeedToolBarDelegate <NSObject>

@optional
/**
 *  点赞
 */
- (void)didTapLikeViewInFeedToolBarWithFeed:(DXTimelineFeed *)feed;
/**
 *  评论
 */
- (void)didTapCommentViewInFeedToolBarWithFeed:(DXTimelineFeed *)feed;
/**
 *  私聊
 */
- (void)didTapChatViewInFeedToolBarWithFeed:(DXTimelineFeed *)feed;
/**
 *  收藏与分享
 */
- (void)didTapShareViewInFeedToolBarWithFeed:(DXTimelineFeed *)feed;

@end

@interface DXFeedToolBar : UIView

@property (nonatomic, strong) DXTimelineFeed *feed;
@property (nonatomic, weak) id<DXFeedToolBarDelegate> delegate;
/** 点赞 */
@property (nonatomic, weak) DXFeedLikeView *likeView;

/** 工具栏类型 */
@property (nonatomic, assign, readonly) DXFeedToolBarType toolBarType;
/** 工具栏构造器 */
- (instancetype)initWithToolBarType:(DXFeedToolBarType)toolBarType;

/**
 *  视图高度
 */
+ (CGFloat)heightForToolBarWithFeed:(DXTimelineFeed *)feed;

@end
