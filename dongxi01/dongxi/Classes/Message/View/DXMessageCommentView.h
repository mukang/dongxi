//
//  DXMessageCommentView.h
//  dongxi
//
//  Created by 穆康 on 15/10/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXNoticeComment;
@class DXMessageCommentView;

@protocol DXMessageCommentViewDelegate <NSObject>

@optional

- (void)messageCommentView:(DXMessageCommentView *)view didSelectReferUserWithUserID:(NSString *)userID;
- (void)messageCommentView:(DXMessageCommentView *)view didSelectReferTopicWithTopicID:(NSString *)topicID;

@end

@interface DXMessageCommentView : UIView

@property (nonatomic, strong) DXNoticeComment *comment;

@property (nonatomic, weak) id<DXMessageCommentViewDelegate> delegate;

/**
 *  视图高度
 */
+ (CGFloat)heightForMessageCommentViewWithComment:(DXNoticeComment *)comment;

@end
