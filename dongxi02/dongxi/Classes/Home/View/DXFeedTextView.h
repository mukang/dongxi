//
//  DXFeedTextView.h
//  dongxi
//
//  Created by 穆康 on 15/11/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  feed文字视图

#import <UIKit/UIKit.h>
@class DXFeedTextView;

@protocol DXFeedTextViewDelegate <NSObject>

@optional

- (void)feedTextView:(DXFeedTextView *)view didTapMoreButtonWithFeed:(DXTimelineFeed *)feed;

- (void)feedTextView:(DXFeedTextView *)view didSelectReferUserWithUserID:(NSString *)userID;
- (void)feedTextView:(DXFeedTextView *)view didSelectReferTopicWithTopicID:(NSString *)topicID;

@end

@interface DXFeedTextView : UIView

@property (nonatomic, strong) DXTimelineFeed *feed;
@property (nonatomic, weak) id<DXFeedTextViewDelegate> delegate;

/**
 *  视图高度
 */
+ (CGFloat)heightForTextViewWithFeed:(DXTimelineFeed *)feed;

@end
