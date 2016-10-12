//
//  DXFeedTextView.m
//  dongxi
//
//  Created by 穆康 on 15/11/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedTextView.h"
#import <YYText.h>

#define TextL_Left_Margin             DXRealValue(12.0f)  // 文字内容距视图的左边距
#define TextL_Top_Margin              DXRealValue(7.0f)  // 文字内容距视图的上边距
#define TextL_MoreButton_Margin       DXRealValue(5.0f)   // 文字内容和更多按钮的间距
#define MoreButton_Bottom_Margin      DXRealValue(7.0f)  // 更多按钮距视图的下边距

@interface DXFeedTextView ()

/** feed文字内容 */
@property (nonatomic, weak) YYLabel *textL;
@property (nonatomic, weak) UIButton *moreButton;

@end

@implementation DXFeedTextView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    // feed文字内容
    YYLabel *textL = [[YYLabel alloc] init];
    textL.numberOfLines = 3;
    textL.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:textL];
    self.textL = textL;
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"button_viewall_normal"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.hidden = YES;
    [self addSubview:moreButton];
    self.moreButton = moreButton;
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    NSString *textStr = feed.data.text;
    CGFloat textLW = DXScreenWidth - TextL_Left_Margin * 2.0;
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:textStr];
    attText.yy_font = [UIFont systemFontOfSize:DXRealValue(15.0f)];
    attText.yy_color = DXRGBColor(72, 72, 72);
    attText.yy_lineSpacing = DXRealValue(3.0f);
    
    if (feed.data.content_pieces.count) {
        NSMutableString *tempTextStr = [[NSMutableString alloc] init];
        YYTextBorder *border = [YYTextBorder borderWithFillColor:DXRGBColor(240, 240, 240) cornerRadius:0];
        __weak typeof(self) weakSelf = self;
        
        for (DXContentPiece *piece in feed.data.content_pieces) {
            [tempTextStr appendString:piece.content];
            if (piece.type == DXContentPieceTypeRefer) {
                NSRange range = NSMakeRange(tempTextStr.length - piece.content.length, piece.content.length);
                YYTextHighlight *textHighlight = [[YYTextHighlight alloc] init];
                [textHighlight setBackgroundBorder:border];
                textHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                    if (piece.refer_type == DXReferTypeUser) {
                        if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(feedTextView:didSelectReferUserWithUserID:)]) {
                            [weakSelf.delegate feedTextView:weakSelf didSelectReferUserWithUserID:piece.refer_id];
                        }
                    } else {
                        if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(feedTextView:didSelectReferTopicWithTopicID:)]) {
                            [weakSelf.delegate feedTextView:weakSelf didSelectReferTopicWithTopicID:piece.refer_id];
                        }
                    }
                };
                [attText yy_setTextHighlight:textHighlight range:range];
                [attText yy_setColor:DXRGBColor(64, 189, 206) range:range];
            }
        }
    }
    
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(textLW, CGFLOAT_MAX)];
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:attText];
    container.maximumNumberOfRows = 3;
    if (layout.rowCount > 3) {
        layout = [YYTextLayout layoutWithContainer:container text:attText];
        self.moreButton.hidden = NO;
    } else {
        self.moreButton.hidden = YES;
    }
    self.textL.attributedText = attText;
    CGFloat textLH = layout.textBoundingSize.height + DXRealValue(3.0f) * 2.0f;
    self.textL.size = CGSizeMake(textLW, textLH);
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.textL.origin = CGPointMake(TextL_Left_Margin, TextL_Top_Margin);
    
    if (self.moreButton.hidden == NO) {
        self.moreButton.size = CGSizeMake(DXRealValue(70), DXRealValue(24));
        self.moreButton.centerX = self.width * 0.5;
        self.moreButton.y = CGRectGetMaxY(self.textL.frame) + TextL_MoreButton_Margin;
    }
}

+ (CGFloat)heightForTextViewWithFeed:(DXTimelineFeed *)feed {
    
    CGFloat textLW = DXScreenWidth - TextL_Left_Margin * 2.0;
    CGFloat moreButtonH = DXRealValue(24);
    NSString *textStr = feed.data.text;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:textStr];
    attStr.yy_font = [UIFont systemFontOfSize:DXRealValue(15.0f)];
    attStr.yy_lineSpacing = DXRealValue(3.0f);
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(textLW, CGFLOAT_MAX)];
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:attStr];
    container.maximumNumberOfRows = 3;
    if (layout.rowCount > 3) {
        layout = [YYTextLayout layoutWithContainer:container text:attStr];
        CGFloat textLH = layout.textBoundingSize.height + DXRealValue(3.0f) * 2.0f;
        return TextL_Top_Margin + textLH + TextL_MoreButton_Margin + moreButtonH + MoreButton_Bottom_Margin;
    } else {
        CGFloat textLH = layout.textBoundingSize.height + DXRealValue(3.0f) * 2.0f;
        return TextL_Top_Margin + textLH + MoreButton_Bottom_Margin;
    }
}

- (void)moreButtonTapped:(UIButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedTextView:didTapMoreButtonWithFeed:)]) {
        [self.delegate feedTextView:self didTapMoreButtonWithFeed:self.feed];
    }
}

@end
