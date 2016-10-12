//
//  DXMessageCommentView.m
//  dongxi
//
//  Created by 穆康 on 15/10/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageCommentView.h"
#import "DXMessageCommentFeedView.h"
#import <YYText.h>

#define Margin         DXRealValue(13.0f)   // 间距
#define TopMargin      DXRealValue(10.0f)   // 顶部间距
#define YYLabelPadding DXRealValue(6.0f)    // label内容的上下边距之和

@interface DXMessageCommentView ()

/** 我的评论或回复 */
@property (nonatomic, weak) YYLabel *commentL;

@end

@implementation DXMessageCommentView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = DXRGBColor(222, 222, 222);
    
    // 我的评论或回复
    YYLabel *commentL = [[YYLabel alloc] init];
    commentL.numberOfLines = 0;
    [self addSubview:commentL];
    self.commentL = commentL;
}

- (void)setComment:(DXNoticeComment *)comment {
    _comment = comment;
    
    __weak typeof(self) weakSelf = self;
    NSString *textStr;
    NSMutableAttributedString *attText;
    NSMutableString *tempTextStr = [[NSMutableString alloc] init];
    YYTextBorder *border = [YYTextBorder borderWithFillColor:DXRGBColor(240, 240, 240) cornerRadius:0];
    if (!comment.txt) {
        textStr = @"此评论已删除";
        attText = [[NSMutableAttributedString alloc] initWithString:textStr];
        attText.yy_color = DXRGBColor(102, 102, 102);
    } else {
        // 我的评论或回复
        if (!comment.at_nick.length) { // 我评论feed
            textStr = [NSString stringWithFormat:@"@%@：%@", comment.nick, comment.txt];
            attText = [[NSMutableAttributedString alloc] initWithString:textStr];
            attText.yy_color = DXRGBColor(102, 102, 102);
            
            [tempTextStr appendFormat:@"@%@：", comment.nick];
            YYTextHighlight *myHighlight = [[YYTextHighlight alloc] init];
            [myHighlight setBackgroundBorder:border];
            myHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(messageCommentView:didSelectReferUserWithUserID:)]) {
                    [weakSelf.delegate messageCommentView:weakSelf didSelectReferUserWithUserID:comment.uid];
                }
            };
            NSRange replayRange = [tempTextStr rangeOfString:[NSString stringWithFormat:@"@%@", comment.nick]];
            [attText yy_setColor:DXRGBColor(64, 189, 206) range:replayRange];
            [attText yy_setTextHighlight:myHighlight range:replayRange];
            
        } else { // 我回复别人
            textStr = [NSString stringWithFormat:@"@%@ 回复@%@：%@", comment.nick, comment.at_nick, comment.txt];
            attText = [[NSMutableAttributedString alloc] initWithString:textStr];
            attText.yy_color = DXRGBColor(102, 102, 102);
            
            [tempTextStr appendFormat:@"@%@ 回复@%@：", comment.nick, comment.at_nick];
            YYTextHighlight *myHighlight = [[YYTextHighlight alloc] init];
            [myHighlight setBackgroundBorder:border];
            myHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(messageCommentView:didSelectReferUserWithUserID:)]) {
                    [weakSelf.delegate messageCommentView:weakSelf didSelectReferUserWithUserID:comment.uid];
                }
            };
            YYTextHighlight *otherHighlight = [[YYTextHighlight alloc] init];
            [otherHighlight setBackgroundBorder:border];
            otherHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(messageCommentView:didSelectReferUserWithUserID:)]) {
                    [weakSelf.delegate messageCommentView:weakSelf didSelectReferUserWithUserID:comment.at_uid];
                }
            };
            NSRange myRange = [tempTextStr rangeOfString:[NSString stringWithFormat:@"@%@", comment.nick]];
            NSRange otherRange = [tempTextStr rangeOfString:[NSString stringWithFormat:@"@%@", comment.at_nick]];
            [attText yy_setColor:DXRGBColor(64, 189, 206) range:myRange];
            [attText yy_setTextHighlight:myHighlight range:myRange];
            [attText yy_setColor:DXRGBColor(64, 189, 206) range:otherRange];
            [attText yy_setTextHighlight:otherHighlight range:otherRange];
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
                            if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(messageCommentView:didSelectReferUserWithUserID:)]) {
                                [weakSelf.delegate messageCommentView:weakSelf didSelectReferUserWithUserID:peice.refer_id];
                            }
                        } else {
                            if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(messageCommentView:didSelectReferTopicWithTopicID:)]) {
                                [weakSelf.delegate messageCommentView:weakSelf didSelectReferTopicWithTopicID:peice.refer_id];
                            }
                        }
                    };
                    [attText yy_setTextHighlight:textHighlight range:range];
                    [attText yy_setColor:DXRGBColor(64, 189, 206) range:range];
                }
            }
        }
    }
    attText.yy_font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    attText.yy_lineSpacing = DXRealValue(3.0f);
    self.commentL.attributedText = attText;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.comment.comment_type == 2) {
        
        CGFloat commentLX = Margin;
        CGFloat commentLY = TopMargin;
        CGFloat commentLW = self.width - Margin * 2.0f;
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(commentLW, CGFLOAT_MAX) text:self.commentL.attributedText];
        CGFloat commentLH = layout.textBoundingSize.height + YYLabelPadding;
        self.commentL.frame = CGRectMake(commentLX, commentLY, commentLW, commentLH);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGFloat commentLW = size.width - Margin * 2.0f;
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(commentLW, CGFLOAT_MAX) text:self.commentL.attributedText];
    CGFloat commentLH = layout.textBoundingSize.height + YYLabelPadding;
    
    return CGSizeMake(size.width, TopMargin + commentLH + Margin);
}

+ (CGFloat)heightForMessageCommentViewWithComment:(DXNoticeComment *)comment {
    
    CGFloat commentViewW = DXScreenWidth - Margin * 2.0f;
    CGFloat commentLW = commentViewW - Margin * 2.0f;
    NSString *textStr;
    if (!comment.txt) {
        textStr = @"此评论已删除";
    } else {
        if (!comment.at_nick.length) {
            textStr = [NSString stringWithFormat:@"@%@：%@", comment.nick, comment.txt];
        } else {
            textStr = [NSString stringWithFormat:@"@%@ 回复@%@：%@", comment.nick, comment.at_nick, comment.txt];
        }
    }
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:textStr];
    attText.yy_font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13)];
    attText.yy_lineSpacing = DXRealValue(3.0f);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(commentLW, CGFLOAT_MAX) text:attText];
    CGFloat commentLH = layout.textBoundingSize.height + YYLabelPadding;
    
    return TopMargin + commentLH + Margin;
}

@end
