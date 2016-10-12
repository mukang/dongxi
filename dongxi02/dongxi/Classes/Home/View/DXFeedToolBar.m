//
//  DXFeedToolBar.m
//  dongxi
//
//  Created by 穆康 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedToolBar.h"
#import "DXFeedToolView.h"
#import "UIResponder+Router.h"

static const NSInteger defaultTag = 1000;

NSString *const kRouterEventLikeViewDidTapEventName = @"kRouterEventLikeViewDidTapEventName";
NSString *const kRouterEventCommentViewDidTapEventName = @"kRouterEventCommentViewDidTapEventName";
NSString *const kRouterEventChatViewDidTapEventName = @"kRouterEventChatViewDidTapEventName";
NSString *const kRouterEventShareViewDidTapEventName = @"kRouterEventShareViewDidTapEventName";

@interface DXFeedToolBar ()

/** 评论 */
@property (nonatomic, weak) DXFeedToolView *commentView;
/** 私聊 */
@property (nonatomic, weak) DXFeedToolView *chatView;
/** 分享与收藏 */
@property (nonatomic, weak) DXFeedToolView *shareView;

@end

@implementation DXFeedToolBar

- (instancetype)initWithToolBarType:(DXFeedToolBarType)toolBarType {
    self = [self initWithToolBarType:toolBarType frame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithToolBarType:DXFeedToolBarTypeDetail frame:frame];
    return self;
}

- (instancetype)initWithToolBarType:(DXFeedToolBarType)toolBarType frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _toolBarType = toolBarType;
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    // 点赞
    DXFeedLikeView *likeView = [[DXFeedLikeView alloc] init];
    likeView.tag = defaultTag + 1;
    [self addSubview:likeView];
    self.likeView = likeView;
    UITapGestureRecognizer *likeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolViewDidTap:)];
    [likeView addGestureRecognizer:likeTap];
    
    // 评论
    DXFeedToolView *commentView = nil;
    if (self.toolBarType == DXFeedToolBarTypeList) {
        commentView = [[DXFeedToolView alloc] initWithToolViewType:DXFeedToolViewTypeBrowseComment];
        commentView.imageName = @"feed_act_comment_list";
    } else {
        commentView = [[DXFeedToolView alloc] initWithToolViewType:DXFeedToolViewTypeOther];
        commentView.imageName = @"icon_comment";
    }
    commentView.titleName = @"评论";
    commentView.tag = defaultTag + 2;
    [self addSubview:commentView];
    self.commentView = commentView;
    UITapGestureRecognizer *commentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolViewDidTap:)];
    [commentView addGestureRecognizer:commentTap];
    
    // 私聊
    DXFeedToolView *chatView = [[DXFeedToolView alloc] initWithToolViewType:DXFeedToolViewTypeOther];
    chatView.titleName = @"私聊";
    chatView.imageName = @"feed_act_comment";
    chatView.tag = defaultTag + 3;
    [self addSubview:chatView];
    self.chatView = chatView;
    UITapGestureRecognizer *chatTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolViewDidTap:)];
    [chatView addGestureRecognizer:chatTap];
    
    // 分享与收藏
    DXFeedToolView *shareView = [[DXFeedToolView alloc] initWithToolViewType:DXFeedToolViewTypeOther];
    shareView.titleName = @"分享与收藏";
    shareView.tag = defaultTag + 4;
    [self addSubview:shareView];
    self.shareView = shareView;
    UITapGestureRecognizer *shareTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolViewDidTap:)];
    [shareView addGestureRecognizer:shareTap];
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    self.likeView.like = feed.data.is_like;
    
    if (self.toolBarType == DXFeedToolBarTypeList) {
        self.commentView.commentCount = feed.data.total_comments;
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat viewH = self.height;
    
    // 点赞
    self.likeView.frame = CGRectMake(0, 0, DXRealValue(81), viewH);
    
    // 评论
    CGFloat commentViewX = CGRectGetMaxX(self.likeView.frame);
    CGFloat commentViewW = DXRealValue(104);
    self.commentView.frame = CGRectMake(commentViewX, 0, commentViewW, viewH);
    
    // 私聊
    CGFloat chatViewX = CGRectGetMaxX(self.commentView.frame);
    CGFloat chatViewW = DXRealValue(104);
    self.chatView.frame = CGRectMake(chatViewX, 0, chatViewW, viewH);
    
    // 分享与收藏
    CGFloat shareViewX = CGRectGetMaxX(self.chatView.frame);
    CGFloat shareViewW = self.width - shareViewX;
    self.shareView.frame = CGRectMake(shareViewX, 0, shareViewW, viewH);
}

+ (CGFloat)heightForToolBarWithFeed:(DXTimelineFeed *)feed {
    
    return DXRealValue(49);
}

/**
 *  点击工具控件
 */
- (void)toolViewDidTap:(UITapGestureRecognizer *)tap {
    
    NSDictionary *userInfo = nil;
    if (self.feed) {
        userInfo = @{kFeedKey: self.feed};
    }
    
    UIView *view = tap.view;
    if (view.tag == defaultTag + 1) { // 点赞
        [self routerEventWithName:kRouterEventLikeViewDidTapEventName userInfo:userInfo];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLikeViewInFeedToolBarWithFeed:)]) {
            [self.delegate didTapLikeViewInFeedToolBarWithFeed:self.feed];
        }
    } else if (view.tag == defaultTag + 2) { // 评论
        [self routerEventWithName:kRouterEventCommentViewDidTapEventName userInfo:userInfo];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapCommentViewInFeedToolBarWithFeed:)]) {
            [self.delegate didTapCommentViewInFeedToolBarWithFeed:self.feed];
        }
    } else if (view.tag == defaultTag + 3) { // 私聊
        [self routerEventWithName:kRouterEventChatViewDidTapEventName userInfo:userInfo];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChatViewInFeedToolBarWithFeed:)]) {
            [self.delegate didTapChatViewInFeedToolBarWithFeed:self.feed];
        }
    } else { // 分享与收藏
        [self routerEventWithName:kRouterEventShareViewDidTapEventName userInfo:userInfo];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapShareViewInFeedToolBarWithFeed:)]) {
            [self.delegate didTapShareViewInFeedToolBarWithFeed:self.feed];
        }
    }
}

@end
