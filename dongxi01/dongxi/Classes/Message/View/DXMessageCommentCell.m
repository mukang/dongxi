//
//  DXMessageCommentCell.m
//  dongxi
//
//  Created by 穆康 on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageCommentCell.h"
#import "DXMessageCommentView.h"
#import <UIImageView+WebCache.h>
#import <YYText.h>
#import "UIImage+Extension.h"

#define Margin         DXRealValue(13.0f)   // 间距
#define YYLabelPadding DXRealValue(6.0f)    // label内容的上下边距之和

@interface DXMessageCommentCell () <DXMessageCommentViewDelegate>

/** 头像 */
@property (nonatomic, weak) DXAvatarView *avatarV;
/** 昵称 */
@property (nonatomic, weak) UILabel *nickL;
/** 日期 */
@property (nonatomic, weak) UILabel *dateL;
/** 回复按钮 */
@property (nonatomic, weak) UIButton *replyBtn;
/** 别人的回复或评论 */
@property (nonatomic, weak) YYLabel *commentL;
/** 我的评论或回复的内容 */
@property (nonatomic, weak) DXMessageCommentView *commentView;
/** 分割线 */
@property (nonatomic, weak) UIView *dividerView;

@end

@implementation DXMessageCommentCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"MessageCommentCell";
    
    DXMessageCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXMessageCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setup];
    }
    return self;
}

// 初始化子控件
- (void)setup {
    
    // 头像
    DXAvatarView *avatarV = [[DXAvatarView alloc] init];
    [self.contentView addSubview:avatarV];
    self.avatarV = avatarV;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarVDidTap)];
    [avatarV addGestureRecognizer:tap];
    
    // 昵称
    UILabel *nickL = [[UILabel alloc] init];
    nickL.textColor = DXRGBColor(72, 72, 72);
    nickL.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(15)];
    [self.contentView addSubview:nickL];
    self.nickL = nickL;
    
    // 日期
    UILabel *dateL = [[UILabel alloc] init];
    dateL.textColor = DXRGBColor(143, 143, 143);
    dateL.font = [DXFont systemFontOfSize:13.0f weight:DXFontWeightLight];
    [self.contentView addSubview:dateL];
    self.dateL = dateL;
    
    // 回复按钮
    UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [replyBtn setImage:[UIImage imageNamed:@"button_respond_icon"] forState:UIControlStateNormal];
    [replyBtn addTarget:self action:@selector(replyBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:replyBtn];
    self.replyBtn = replyBtn;
    
    // 别人的回复或评论
    YYLabel *commentL = [[YYLabel alloc] init];
    commentL.numberOfLines = 0;
    [self.contentView addSubview:commentL];
    self.commentL = commentL;
    
    // 被回复的内容
    DXMessageCommentView *commentView = [[DXMessageCommentView alloc] init];
    commentView.delegate = self;
    [self.contentView addSubview:commentView];
    self.commentView = commentView;
    
    // 分割线
    UIView *dividerView = [[UIView alloc] init];
    dividerView.backgroundColor = DXRGBColor(222, 222, 222);
    [self.contentView addSubview:dividerView];
    self.dividerView = dividerView;
}

- (void)setComment:(DXNoticeComment *)comment {
    
    _comment = comment;
    
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(40.0f), DXRealValue(40.0f))];
    [self.avatarV.avatarImageView sd_setImageWithURL:[NSURL URLWithString:comment.comment_avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarV.verified = comment.comment_verified;
    self.avatarV.certificationIconSize = DXCertificationIconSizeMedium;
    
    self.nickL.text = comment.comment_nick;
    [self.nickL sizeToFit];
    
    self.dateL.text = comment.fmtTime;
    [self.dateL sizeToFit];
    
    // 别人的回复或评论
    __weak typeof(self) weakSelf = self;
    NSString *textStr;
    NSMutableAttributedString *attText;
    NSMutableString *tempTextStr = [[NSMutableString alloc] init];
    YYTextBorder *border = [YYTextBorder borderWithFillColor:DXRGBColor(240, 240, 240) cornerRadius:0];
    if (comment.comment_type == 2) { // 评论我的评论
        if (!comment.nick) {
            comment.nick = [[DXDongXiApi api] currentUserSession].nick;
            comment.uid = [[DXDongXiApi api] currentUserSession].uid;
        }
        textStr = [NSString stringWithFormat:@"回复@%@：%@", comment.nick, comment.comment_txt];
        attText = [[NSMutableAttributedString alloc] initWithString:textStr];
        attText.yy_color = DXRGBColor(102, 102, 102);
        
        [tempTextStr appendFormat:@"回复@%@：", comment.nick];
        YYTextHighlight *replayHighlight = [[YYTextHighlight alloc] init];
        [replayHighlight setBackgroundBorder:border];
        replayHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(messageCommentCell:didSelectReferUserWithUserID:)]) {
                [weakSelf.delegate messageCommentCell:weakSelf didSelectReferUserWithUserID:comment.uid];
            }
        };
        NSRange replayRange = [tempTextStr rangeOfString:[NSString stringWithFormat:@"@%@", comment.nick]];
        [attText yy_setColor:DXRGBColor(64, 189, 206) range:replayRange];
        [attText yy_setTextHighlight:replayHighlight range:replayRange];
        
        self.commentView.hidden = NO;
        self.commentView.comment = comment;
        
    } else { // 评论我的feed
        textStr = comment.comment_txt;
        attText = [[NSMutableAttributedString alloc] initWithString:textStr];
        attText.yy_color = DXRGBColor(102, 102, 102);
        
        self.commentView.hidden = YES;
    }
    if (comment.content_pieces.count) {
        for (DXContentPiece *peice in comment.content_pieces) {
            [tempTextStr appendString:peice.content];
            if (peice.type == DXContentPieceTypeRefer) {
                NSRange range = NSMakeRange(tempTextStr.length - peice.content.length, peice.content.length);
                YYTextHighlight *textHighlight = [[YYTextHighlight alloc] init];
                [textHighlight setBackgroundBorder:border];
                textHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                    if (peice.refer_type == DXReferTypeUser) {
                        if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(messageCommentCell:didSelectReferUserWithUserID:)]) {
                            [weakSelf.delegate messageCommentCell:weakSelf didSelectReferUserWithUserID:peice.refer_id];
                        }
                    } else {
                        if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(messageCommentCell:didSelectReferTopicWithTopicID:)]) {
                            [weakSelf.delegate messageCommentCell:weakSelf didSelectReferTopicWithTopicID:peice.refer_id];
                        }
                    }
                };
                [attText yy_setTextHighlight:textHighlight range:range];
                [attText yy_setColor:DXRGBColor(64, 189, 206) range:range];
            }
        }
    }
    attText.yy_font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    attText.yy_lineSpacing = DXRealValue(3.0f);
    self.commentL.attributedText = attText;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 头像
    CGFloat avatarVX = DXRealValue(13);
    CGFloat avatarVY = DXRealValue(12.0f);
    CGFloat avatarVWH = DXRealValue(40);
    self.avatarV.frame = CGRectMake(avatarVX, avatarVY, avatarVWH, avatarVWH);
    
    // 昵称
    CGFloat nickLX = CGRectGetMaxX(self.avatarV.frame) + DXRealValue(16);
    CGFloat nickLY = avatarVY + DXRealValue(7);
    self.nickL.origin = CGPointMake(nickLX, nickLY);
    
    // 日期
    CGFloat dateLX = nickLX;
    CGFloat dateLY = CGRectGetMaxY(self.nickL.frame) + DXRealValue(5);
    self.dateL.origin = CGPointMake(dateLX, dateLY);
    
    // 回复按钮
    CGFloat replyBtnW = DXRealValue(53);
    CGFloat replyBtnH = DXRealValue(28);
    CGFloat replyBtnX = self.contentView.width - DXRealValue(13) - replyBtnW;
    CGFloat replyBtnY = avatarVY + DXRealValue(9);
    self.replyBtn.frame = CGRectMake(replyBtnX, replyBtnY, replyBtnW, replyBtnH);
    
    // 别人的回复或评论
    CGFloat commentLX = avatarVX;
    CGFloat commentLY = CGRectGetMaxY(self.avatarV.frame) + DXRealValue(13.0f);
    CGFloat commentLW = self.contentView.width - commentLX * 2.0f;
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(commentLW, CGFLOAT_MAX) text:self.commentL.attributedText];
    CGFloat commentLH = layout.textBoundingSize.height + YYLabelPadding;
    self.commentL.frame = CGRectMake(commentLX, commentLY, commentLW, commentLH);
    
    // 我的评论
    if (self.comment.comment_type == 2) {  // 评论我的评论
        // 我的评论内容
        CGFloat commentViewX = commentLX;
        CGFloat commentViewY = CGRectGetMaxY(self.commentL.frame) + DXRealValue(7.0f);
        CGFloat commentViewW = commentLW;
        CGFloat commentViewH = [self.commentView sizeThatFits:CGSizeMake(commentViewW, CGFLOAT_MAX)].height;
        self.commentView.frame = CGRectMake(commentViewX, commentViewY, commentViewW, commentViewH);
    }
    
    // 分割线
    CGFloat dividerViewW = self.contentView.width;
    CGFloat dividerViewH = 0.5f;
    CGFloat dividerViewX = 0;
    CGFloat dividerViewY = self.contentView.height - dividerViewH;
    self.dividerView.frame = CGRectMake(dividerViewX, dividerViewY, dividerViewW, dividerViewH);
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withComment:(DXNoticeComment *)comment {
    
    CGFloat topMargin = DXRealValue(12.0f);
    CGFloat bottomMargin = DXRealValue(8.0f);
    CGFloat avatarVH = DXRealValue(40);
    CGFloat commentLW = DXScreenWidth - Margin * 2.0f;
    
    NSString *textStr;
    if (comment.comment_type == 1) {
        textStr = [NSString stringWithFormat:@"%@", comment.comment_txt];
    } else {
        if (!comment.nick) {
            comment.nick = [[DXDongXiApi api] currentUserSession].nick;
        }
        textStr = [NSString stringWithFormat:@"回复@%@：%@", comment.nick, comment.comment_txt];
    }
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:textStr];
    attText.yy_font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    attText.yy_lineSpacing = DXRealValue(3.0f);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(commentLW, CGFLOAT_MAX) text:attText];
    CGFloat commentLH = layout.textBoundingSize.height + YYLabelPadding;
    
    if (comment.comment_type == 1) {  // 评论我的feed
        return topMargin + avatarVH + Margin + commentLH + Margin;
    } else {
        CGFloat commentViewH = [DXMessageCommentView heightForMessageCommentViewWithComment:comment];
        return topMargin + avatarVH + Margin + commentLH + DXRealValue(7.0f) + commentViewH + bottomMargin;
    }
}

#pragma mark - 点击回复按钮
- (void)replyBtnDidClick:(UIButton *)btn {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCommentCell:didTapReplyBtnWithComment:feedID:)]) {
        [self.delegate messageCommentCell:self didTapReplyBtnWithComment:self.comment feedID:self.feedID];
    }
}

#pragma mark - DXMessageCommentViewDelegate

- (void)messageCommentView:(DXMessageCommentView *)view didSelectReferUserWithUserID:(NSString *)userID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCommentCell:didSelectReferUserWithUserID:)]) {
        [self.delegate messageCommentCell:self didSelectReferUserWithUserID:userID];
    }
}

- (void)messageCommentView:(DXMessageCommentView *)view didSelectReferTopicWithTopicID:(NSString *)topicID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCommentCell:didSelectReferTopicWithTopicID:)]) {
        [self.delegate messageCommentCell:self didSelectReferTopicWithTopicID:topicID];
    }
}

#pragma mark - 点击头像

- (void)avatarVDidTap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCommentCell:didTapAvatarWithUserID:)]) {
        [self.delegate messageCommentCell:self didTapAvatarWithUserID:self.comment.comment_uid];
    }
}

@end
