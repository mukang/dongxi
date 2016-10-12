//
//  DXFeedViewCell.m
//  dongxi
//
//  Created by 穆康 on 16/8/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedViewCell.h"
#import "DXFeedPhotoView.h"
#import "DXFeedPhotoContainerView.h"
#import <YYText/YYText.h>
#import "DXButton.h"

@interface DXFeedViewCell () <DXFeedPhotoContainerViewDelegate>

@property (nonatomic, weak) DXFeedPhotoContainerView *photoContainerView;
@property (nonatomic, weak) UIButton *likeInfoBtn;
@property (nonatomic, weak) UILabel *recommendLabel;
@property (nonatomic, weak) YYLabel *contentLabel;
@property (nonatomic, weak) UILabel *topicsLabel;
@property (nonatomic, weak) UIButton *commentInfoBtn;
@property (nonatomic, weak) DXButton *likeBtn;
@property (nonatomic, weak) UIButton *commentBtn;
@property (nonatomic, weak) UIButton *chatBtn;
@property (nonatomic, weak) UIButton *shareBtn;

@end

@implementation DXFeedViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupContent];
    }
    return self;
}

- (void)setupContent {
    self.backgroundColor = [UIColor whiteColor];
    
    DXFeedPhotoContainerView *photoContainerView = [[DXFeedPhotoContainerView alloc] init];
    photoContainerView.backgroundColor = DXRandomColor;
    photoContainerView.delegate = self;
    [self.contentView addSubview:photoContainerView];
    
    UIButton *likeInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    likeInfoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [likeInfoBtn setImage:[UIImage imageNamed:@"feed_like_info"] forState:UIControlStateNormal];
    [likeInfoBtn setImage:[UIImage imageNamed:@"feed_like_info"] forState:UIControlStateHighlighted];
    [likeInfoBtn setTitleColor:DXRGBColor(72, 72, 72) forState:UIControlStateNormal];
    likeInfoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    likeInfoBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    [likeInfoBtn addTarget:self action:@selector(handleLikeInfoBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:likeInfoBtn];
    
    UILabel *recommendLabel = [[UILabel alloc] init];
    recommendLabel.textColor = DXRGBColor(165, 165, 165);
    recommendLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:recommendLabel];
    
    YYLabel *contentLabel = [[YYLabel alloc] init];
    contentLabel.numberOfLines = 1;
    contentLabel.textColor = DXRGBColor(72, 72, 72);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:contentLabel];
    
    UILabel *topicsLabel = [[UILabel alloc] init];
    topicsLabel.numberOfLines = 2;
    topicsLabel.textColor = DXRGBColor(60, 187, 217);
    topicsLabel.textAlignment = NSTextAlignmentLeft;
    topicsLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:topicsLabel];
    
    UIButton *commentInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commentInfoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    commentInfoBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [commentInfoBtn setTitleColor:DXRGBColor(165, 165, 165) forState:UIControlStateNormal];
    [commentInfoBtn addTarget:self action:@selector(handleCommentInfoBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:commentInfoBtn];
    
    DXButton *likeBtn = [DXButton buttonWithType:UIButtonTypeCustom];
    [likeBtn setImage:[UIImage imageNamed:@"feed_like_normal"] forState:UIControlStateNormal];
    [likeBtn setImage:[UIImage imageNamed:@"feed_like_highlighted"] forState:UIControlStateSelected];
    [likeBtn addTarget:self action:@selector(handleLikeBtnTap:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:likeBtn];
    
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn setImage:[UIImage imageNamed:@"feed_comment"] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(handleCommentBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:commentBtn];
    
    UIButton *chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [chatBtn setImage:[UIImage imageNamed:@"feed_chat"] forState:UIControlStateNormal];
    [chatBtn addTarget:self action:@selector(handleChatBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:chatBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"feed_comment"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(handleShareBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:shareBtn];
    
    self.photoContainerView = photoContainerView;
    self.likeInfoBtn = likeInfoBtn;
    self.recommendLabel = recommendLabel;
    self.contentLabel = contentLabel;
    self.topicsLabel = topicsLabel;
    self.commentInfoBtn = commentInfoBtn;
    self.likeBtn = likeBtn;
    self.commentBtn = commentBtn;
    self.chatBtn = chatBtn;
    self.shareBtn = shareBtn;
}

- (void)setFeed:(DXFeed *)feed {
    _feed = feed;
    
    self.photoContainerView.feed = feed;
    
    NSString *likeInfo = nil;
    if (feed.total_like) {
        likeInfo = [NSString stringWithFormat:@"%zd个赞", feed.total_like];
    } else {
        likeInfo = @"还没有人点赞哦";
    }
    [self.likeInfoBtn setTitle:likeInfo forState:UIControlStateNormal];
    
    if (feed.recommend.reason) {
        self.recommendLabel.text = feed.recommend.reason;
        self.recommendLabel.hidden = NO;
    } else {
        self.recommendLabel.hidden = YES;
    }
    
    self.contentLabel.text = feed.content;
    
    NSArray *topics = feed.topics;
    if (topics.count) {
        NSMutableArray *topicParts = [NSMutableArray array];
        for (DXTopic *topic in topics) {
            [topicParts addObject:[NSString stringWithFormat:@"#%@#", topic.topic]];
        }
        NSString *topicStr = [topicParts componentsJoinedByString:@" "];
        self.topicsLabel.text = topicStr;
        self.topicsLabel.hidden = NO;
    } else {
        self.topicsLabel.hidden = YES;
    }
    
    NSString *commentInfo = nil;
    if (feed.total_comment) {
        commentInfo = [NSString stringWithFormat:@"查看全部%zd条评论", feed.total_comment];
    } else {
        commentInfo = @"还没有人评论哦";
    }
    [self.commentInfoBtn setTitle:commentInfo forState:UIControlStateNormal];
    
    self.likeBtn.selected = feed.current_user.is_like;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat leftPadding = 13;
    CGFloat width = self.contentView.width;
    
    self.photoContainerView.frame = CGRectMake(0, 0, width, width);
    
    self.likeInfoBtn.size = CGSizeMake(width - 80, 19);
    self.likeInfoBtn.x = leftPadding;
    self.likeInfoBtn.centerY = CGRectGetMaxY(self.photoContainerView.frame) + 16;
    
    self.recommendLabel.x = width - 14 - self.recommendLabel.width;
    self.recommendLabel.centerY = self.likeInfoBtn.centerY;
    
    self.contentLabel.size = CGSizeMake(width - 26, 19);
    self.contentLabel.x = leftPadding;
    self.contentLabel.centerY = CGRectGetMaxY(self.photoContainerView.frame) + 38;
    
    if (self.feed.topics.count) {
        CGFloat topicsLabelWidth = width - 26;
        self.topicsLabel.size = [self.topicsLabel textRectForBounds:CGRectMake(0, 0, topicsLabelWidth, CGFLOAT_MAX) limitedToNumberOfLines:2].size;
        self.topicsLabel.x = leftPadding;
        self.topicsLabel.y = CGRectGetMaxY(self.photoContainerView.frame) + 51;
    }
    
    self.commentInfoBtn.size = CGSizeMake(self.contentLabel.width, 19);
    self.commentInfoBtn.x = leftPadding;
    if (self.feed.topics.count) {
        self.commentInfoBtn.centerY = CGRectGetMaxY(self.topicsLabel.frame) + 17;
    } else {
        self.commentInfoBtn.centerY = CGRectGetMaxY(self.photoContainerView.frame) + 58;
    }
    
    CGFloat btnCenterY = self.commentInfoBtn.centerY + 38;
    
    self.likeBtn.size = CGSizeMake(23, 20);
    self.likeBtn.x = 16;
    self.likeBtn.centerY = btnCenterY;
    
    self.commentBtn.size = CGSizeMake(23, 20);
    self.commentBtn.x = 75;
    self.commentBtn.centerY = btnCenterY;
    
    self.chatBtn.size = CGSizeMake(20, 21);
    self.chatBtn.x = 137;
    self.chatBtn.centerY = btnCenterY;
    
    self.shareBtn.size = CGSizeMake(22, 19);
    self.shareBtn.x = width - 26 - self.shareBtn.width;
    self.shareBtn.centerY = btnCenterY;
}

#pragma mark - 点击事件

- (void)handleLikeInfoBtnTap:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedViewCell:didTapLikeInfoBtnWithFeed:)]) {
        [self.delegate feedViewCell:self didTapLikeInfoBtnWithFeed:self.feed];
    }
}

- (void)handleCommentInfoBtnTap:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedViewCell:didTapCommentInfoBtnWithFeed:)]) {
        [self.delegate feedViewCell:self didTapCommentInfoBtnWithFeed:self.feed];
    }
}

- (void)handleLikeBtnTap:(DXButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedViewCell:didTapLikeBtnWithFeed:)]) {
        [self.delegate feedViewCell:self didTapLikeBtnWithFeed:self.feed];
    }
}

- (void)handleCommentBtnTap:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedViewCell:didTapCommentBtnWithFeed:)]) {
        [self.delegate feedViewCell:self didTapCommentBtnWithFeed:self.feed];
    }
}

- (void)handleChatBtnTap:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedViewCell:didTapChatBtnWithFeed:)]) {
        [self.delegate feedViewCell:self didTapChatBtnWithFeed:self.feed];
    }
}

- (void)handleShareBtnTap:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedViewCell:didTapShareBtnWithFeed:)]) {
        [self.delegate feedViewCell:self didTapShareBtnWithFeed:self.feed];
    }
}

#pragma mark - DXFeedPhotoContainerViewDelegate

- (void)feedPhotoContainerView:(DXFeedPhotoContainerView *)view didTapPhotoView:(DXFeedPhotoView *)photoView {
    DXLog(@"点击了第%zd张照片", photoView.photoIndex);
}

+ (CGSize)collectionView:(UICollectionView *)collectionView heightForRowAtIndexPath:(NSIndexPath *)indexPath withFeed:(DXFeed *)feed {
    
    CGFloat cellHeight = 0;
    CGFloat photoContainerViewHeight = DXScreenWidth;
    if (feed.topics.count) {
        NSMutableArray *topicParts = [NSMutableArray array];
        for (DXTopic *topic in feed.topics) {
            [topicParts addObject:[NSString stringWithFormat:@"#%@#", topic.topic]];
        }
        NSString *topicStr = [topicParts componentsJoinedByString:@" "];
        CGFloat topicsLabelWidth = DXScreenWidth - 26;
        UILabel *topicsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, topicsLabelWidth, 0)];
        topicsLabel.numberOfLines = 2;
        topicsLabel.text = topicStr;
        topicsLabel.textAlignment = NSTextAlignmentLeft;
        topicsLabel.font = [UIFont systemFontOfSize:13];
        [topicsLabel sizeToFit];
        CGFloat topicsLabelHeight = topicsLabel.height;
        cellHeight = photoContainerViewHeight + 51 + topicsLabelHeight + 80;
    } else {
        cellHeight = photoContainerViewHeight + 126;
    }
    
    return CGSizeMake(DXScreenWidth, cellHeight);
}

@end
