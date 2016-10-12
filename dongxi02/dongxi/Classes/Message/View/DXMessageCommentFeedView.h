//
//  DXMessageCommentFeedView.h
//  dongxi
//
//  Created by 穆康 on 15/10/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXNoticeCommentWrapper;

@protocol DXMessageCommentFeedViewDelegate <NSObject>

@optional
/** 点击了feed视图 */
- (void)didTapMessageCommentFeedView;

@end

@interface DXMessageCommentFeedView : UIView

@property (nonatomic, strong) DXNoticeCommentWrapper *commentWrapper;

@property (nonatomic, weak) id<DXMessageCommentFeedViewDelegate> delegate;
/**
 *  视图高度
 */
//+ (CGFloat)heightForMessageCommentFeedViewWithFeed:(DXTimelineFeed *)feed;

@end
