//
//  DXMessageCommentFeedCell.m
//  dongxi
//
//  Created by 穆康 on 15/11/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageCommentFeedCell.h"
#import "DXMessageCommentFeedView.h"

#define Margin      DXRealValue(13.0f)
#define TopMargin   DXRealValue(7.0f)

@interface DXMessageCommentFeedCell () <DXMessageCommentFeedViewDelegate>

@property (nonatomic, weak) UIView *bgView;

@property (nonatomic, weak) DXMessageCommentFeedView *feedView;

@property (nonatomic, weak) UIView *dividerView;

@end

@implementation DXMessageCommentFeedCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"MessageCommentFeedCell";
    
    DXMessageCommentFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXMessageCommentFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = DXRGBColor(222, 222, 222);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bgView];
    self.bgView = bgView;
    
    DXMessageCommentFeedView *feedView = [[DXMessageCommentFeedView alloc] init];
    feedView.delegate = self;
    [bgView addSubview:feedView];
    self.feedView = feedView;
    
    UIView *dividerView = [[UIView alloc] init];
    dividerView.backgroundColor = DXRGBColor(222, 222, 222);
    [self.contentView addSubview:dividerView];
    self.dividerView = dividerView;
}

- (void)setCommentWrapper:(DXNoticeCommentWrapper *)commentWrapper {
    
    _commentWrapper = commentWrapper;
    
    self.feedView.commentWrapper = commentWrapper;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat bgViewY = TopMargin;
    CGFloat bgViewW = self.contentView.width;
    CGFloat bgViewH = self.contentView.height - TopMargin;
    self.bgView.frame = CGRectMake(0, bgViewY, bgViewW, bgViewH);
    
    CGFloat feedViewX = Margin;
    CGFloat feedViewY = Margin;
    CGFloat feedViewW = bgViewW - Margin * 2.0f;
    CGFloat feedViewH = bgViewH - Margin * 2.0f;
    self.feedView.frame = CGRectMake(feedViewX, feedViewY, feedViewW, feedViewH);
    
    CGFloat dividerViewW = self.contentView.width;
    CGFloat dividerViewH = 0.5f;
    CGFloat dividerViewX = 0;
    CGFloat dividerViewY = self.contentView.height - dividerViewH;
    self.dividerView.frame = CGRectMake(dividerViewX, dividerViewY, dividerViewW, dividerViewH);
}

#pragma mark - DXMessageCommentFeedViewDelegate
- (void)didTapMessageCommentFeedView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCommentFeedCell:didTapFeedViewWithFeedID:)]) {
        [self.delegate messageCommentFeedCell:self didTapFeedViewWithFeedID:self.commentWrapper.fid];
    }
}

@end
