//
//  DXFeedCell.m
//  dongxi
//
//  Created by 穆康 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedCell.h"
#import "UIResponder+Router.h"
#import "DXFeedHeaderView.h"
#import "DXFeedPhotosView.h"
#import "DXFeedTextView.h"
#import "DXFeedLikeInfoView.h"
#import "DXFeedPhotoBrowser.h"

#define TopMargin DXRealValue(7) // cell内容顶部间距

@interface DXFeedCell () <DXFeedPhotosViewDelegate, DXFeedPhotoBrowserDelegate, DXFeedTextViewDelegate>

/** 头部视图 */
@property (nonatomic, weak) DXFeedHeaderView *headerView;

/** 照片视图 */
@property (nonatomic, weak) DXFeedPhotosView *photosView;

/** 文字视图 */
@property (nonatomic, weak) DXFeedTextView *textView;

/** 点赞头像、点赞人数及评论人数视图 */
@property (nonatomic, weak) DXFeedLikeInfoView *likeInfoView;

@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation DXFeedCell

#pragma mark - 初始化方法
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView setBackgroundColor:DXRGBColor(222, 222, 222)];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setup];
    }
    return self;
}

// 初始化子控件
- (void)setup {
    
    // 顶部视图
    DXFeedHeaderView *headerView = [[DXFeedHeaderView alloc] init];
    [self.contentView addSubview:headerView];
    self.headerView = headerView;
    
    // 照片视图
    DXFeedPhotosView *photosView = [[DXFeedPhotosView alloc] init];
    photosView.delegate = self;
    [self.contentView addSubview:photosView];
    self.photosView = photosView;
    
    // 文字视图
    DXFeedTextView *textView = [[DXFeedTextView alloc] init];
    textView.delegate = self;
    [self.contentView addSubview:textView];
    self.textView = textView;
    
    // 点赞头像、点赞人数及评论人数视图
    DXFeedLikeInfoView *likeInfoView = [[DXFeedLikeInfoView alloc] init];
    [self.contentView addSubview:likeInfoView];
    self.likeInfoView = likeInfoView;
    UITapGestureRecognizer *likeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLikeInfoView)];
    [self.likeInfoView addGestureRecognizer:likeTap];
   
    // 底部工具栏
    DXFeedToolBar *toolBar = [[DXFeedToolBar alloc] initWithToolBarType:DXFeedToolBarTypeList];
    [self.contentView addSubview:toolBar];
    self.toolBar = toolBar;
}


#pragma mark - 填充数据

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    // 顶部视图
    self.headerView.feed = feed;
    
    // 照片视图
    self.photosView.feed = feed;
    
    // 文字视图
    self.textView.feed = feed;
    
    // 点赞头像、点赞人数及评论人数视图
    self.likeInfoView.feed = feed;
    
    // 底部工具栏
    self.toolBar.feed = feed;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat headerViewY = TopMargin;
    CGFloat headerViewW = self.contentView.width;
    CGFloat headerViewH = [DXFeedHeaderView heightForHeaderViewWithFeed:self.feed];
    self.headerView.frame = CGRectMake(0, headerViewY, headerViewW, headerViewH);
    
    CGFloat photosViewY = CGRectGetMaxY(self.headerView.frame);
    CGFloat photosViewW = self.contentView.width;
    CGFloat photosViewH = [DXFeedPhotosView heightForPhotosViewWithFeed:self.feed];
    self.photosView.frame = CGRectMake(0, photosViewY, photosViewW, photosViewH);
    
    CGFloat textViewY = CGRectGetMaxY(self.photosView.frame);
    CGFloat textViewW = self.contentView.width;
    CGFloat textViewH = [DXFeedTextView heightForTextViewWithFeed:self.feed];
    self.textView.frame = CGRectMake(0, textViewY, textViewW, textViewH);
    
    CGFloat likeInfoViewY = CGRectGetMaxY(self.textView.frame);
    CGFloat likeInfoViewW = self.contentView.width;
    CGFloat likeInfoViewH = [DXFeedLikeInfoView heightForLikeInfoViewWithFeed:self.feed];
    self.likeInfoView.frame = CGRectMake(0, likeInfoViewY, likeInfoViewW, likeInfoViewH);
    
    CGFloat toolBarY = CGRectGetMaxY(self.likeInfoView.frame);
    CGFloat toolBarW = self.contentView.width;
    CGFloat toolBarH = [DXFeedToolBar heightForToolBarWithFeed:self.feed];
    self.toolBar.frame = CGRectMake(0, toolBarY, toolBarW, toolBarH);
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withFeed:(DXTimelineFeed *)feed {
    
    CGFloat headerViewH = [DXFeedHeaderView heightForHeaderViewWithFeed:feed];
    CGFloat photosViewH = [DXFeedPhotosView heightForPhotosViewWithFeed:feed];
    CGFloat textViewH = [DXFeedTextView heightForTextViewWithFeed:feed];
    CGFloat likeInfoViewH = [DXFeedLikeInfoView heightForLikeInfoViewWithFeed:feed];
    CGFloat toolBarH = [DXFeedToolBar heightForToolBarWithFeed:feed];
    
    return TopMargin + headerViewH + photosViewH + textViewH + likeInfoViewH + toolBarH;
}

#pragma mark - 点击了点赞信息视图

- (void)didTapLikeInfoView {
    
    if (self.feed.data.total_like) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLikeAvatarViewInFeedCellWithFeedID:)]) {
            [self.delegate didTapLikeAvatarViewInFeedCellWithFeedID:self.feed.fid];
        }
    }
}

#pragma mark - responder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    
    DXTimelineFeed *feed = userInfo[kFeedKey];
    
    if ([eventName isEqualToString:kRouterEventAvatarViewDidTapEventName]) { // 点击了头像
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAvatarViewInFeedCellWithUserID:)]) {
            [self.delegate didTapAvatarViewInFeedCellWithUserID:feed.uid];
        }
        
    } else if ([eventName isEqualToString:kRouterEventTopicViewDidTapEventName]) { // 点击了话题
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapTopicViewInFeedCellWithTopicID:)]) {
            [self.delegate didTapTopicViewInFeedCellWithTopicID:feed.data.topic.topic_id];
        }
        
    } else if ([eventName isEqualToString:kRouterEventLikeViewDidTapEventName]) { // 点赞
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(feedCell:didTapLikeViewWithFeed:)]) {
            [self.delegate feedCell:self didTapLikeViewWithFeed:feed];
        }
        
    } else if ([eventName isEqualToString:kRouterEventCommentViewDidTapEventName]) { // 评论
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(feedCell:didTapCommentViewWithFeed:)]) {
            [self.delegate feedCell:self didTapCommentViewWithFeed:feed];
        }
        
    } else if ([eventName isEqualToString:kRouterEventChatViewDidTapEventName]) { // 私聊
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChatViewInFeedCellWithFeed:)]) {
            [self.delegate didTapChatViewInFeedCellWithFeed:feed];
        }
        
    } else if ([eventName isEqualToString:kRouterEventShareViewDidTapEventName]) { // 分享和收藏
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapShareViewInFeedCellWithFeed:)]) {
            [self.delegate didTapShareViewInFeedCellWithFeed:feed];
        }
    }
}

#pragma mark - DXFeedPhotosViewDelegate

- (void)feedPhotosView:(DXFeedPhotosView *)view didTapPhotoWithPhotoView:(DXFeedPhotoView *)photoView {
    
    [self.photos removeAllObjects];
    NSArray *photoList = self.feed.data.photo;
    for (DXTimelineFeedPhoto *photo in photoList) {
        [self.photos addObject:[DXFeedPhoto photoWithURL:[NSURL URLWithString:photo.url]]];
    }
    
    DXFeedPhotoBrowser *photoBrowser = [[DXFeedPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.sourceImage = photoView.image;
    photoBrowser.sourceImageViewFrame = photoView.frame;
    photoBrowser.sourceImageContainerView = view;
    [photoBrowser setCurrentPhotoIndex:photoView.photoIndex];
    [photoBrowser show];
}

#pragma mark - DXFeedTextViewDelegate 

- (void)feedTextView:(DXFeedTextView *)view didTapMoreButtonWithFeed:(DXTimelineFeed *)feed {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedCell:didTapMoreButtonWithFeed:)]) {
        [self.delegate feedCell:self didTapMoreButtonWithFeed:feed];
    }
}

- (void)feedTextView:(DXFeedTextView *)cell didSelectReferUserWithUserID:(NSString *)userID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedCell:didSelectReferUserWithUserID:)]) {
        [self.delegate feedCell:self didSelectReferUserWithUserID:userID];
    }
}

- (void)feedTextView:(DXFeedTextView *)cell didSelectReferTopicWithTopicID:(NSString *)topicID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedCell:didSelectReferTopicWithTopicID:)]) {
        [self.delegate feedCell:self didSelectReferTopicWithTopicID:topicID];
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(DXFeedPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <DXFeedPhoto>)photoBrowser:(DXFeedPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}

#pragma mark - 懒加载

- (NSMutableArray *)photos {
    if (_photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

@end
