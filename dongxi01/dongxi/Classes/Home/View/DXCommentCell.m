//
//  DXCommentCell.m
//  dongxi
//
//  Created by 穆康 on 15/8/23.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCommentCell.h"
#import "DXDongXiApi.h"
#import <UIImageView+WebCache.h>
#import <YYText.h>
#import "UIImage+Extension.h"

// label内容的上下边距之和
#define YYLabelPadding DXRealValue(6.0f)

@interface DXCommentCell ()

/** 分割线 */
@property (nonatomic, weak) UIView *dividerV;
/** 头像 */
@property (nonatomic, weak) DXAvatarView *avatarV;
/** 昵称 */
@property (nonatomic, weak) UILabel *nickL;
/** 日期 */
@property (nonatomic, weak) UILabel *dateL;
/** 评论内容 */
@property (nonatomic, weak) YYLabel *commentL;

@end

@implementation DXCommentCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"commentCell";
    
    DXCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
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
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewDidTap)];
    [avatarV addGestureRecognizer:avatarTap];
    
    // 昵称
    UILabel *nickL = [[UILabel alloc] init];
    nickL.textColor = DXRGBColor(72, 72, 72);
    nickL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    [self.contentView addSubview:nickL];
    [nickL sizeToFit];
    self.nickL = nickL;
    
    // 日期
    UILabel *dateL = [[UILabel alloc] init];
    dateL.textColor = DXRGBColor(143, 143, 143);
    dateL.font = [DXFont systemFontOfSize:13.0f weight:DXFontWeightLight];
    [self.contentView addSubview:dateL];
    [dateL sizeToFit];
    self.dateL = dateL;
    
    // 评论内容
    YYLabel *commentL = [[YYLabel alloc] init];
    commentL.numberOfLines = 0;
    [self.contentView addSubview:commentL];
    self.commentL = commentL;
    
    // 分割线
    UIView *dividerV = [[UIView alloc] init];
    dividerV.backgroundColor = DXRGBColor(208, 208, 208);
    [self.contentView addSubview:dividerV];
    self.dividerV = dividerV;
}

- (void)setComment:(DXComment *)comment {
    
    _comment = comment;
    
    // 头像
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(40.0f), DXRealValue(40.0f))];
    [self.avatarV.avatarImageView sd_setImageWithURL:[NSURL URLWithString:comment.avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarV.verified = comment.verified;
    self.avatarV.certificationIconSize = DXCertificationIconSizeMedium;
    
    // 昵称
    self.nickL.text = comment.nick;
    [self.nickL sizeToFit];
    
    // 日期
    self.dateL.text = comment.fmtTime;
    [self.dateL sizeToFit];
    
    // 评论内容
    __weak typeof(self) weakSelf = self;
    NSString *textStr;
    NSMutableAttributedString *attText;
    NSMutableString *tempTextStr = [[NSMutableString alloc] init];
    YYTextBorder *border = [YYTextBorder borderWithFillColor:DXRGBColor(240, 240, 240) cornerRadius:0];
    if (comment.at_nick) { // 回复某人
        textStr = [NSString stringWithFormat:@"回复@%@：%@", comment.at_nick, comment.txt];
        attText = [[NSMutableAttributedString alloc] initWithString:textStr];
        attText.yy_color = DXRGBColor(72, 72, 72);
        
        [tempTextStr appendFormat:@"回复@%@：", comment.at_nick];
        YYTextHighlight *replayHighlight = [[YYTextHighlight alloc] init];
        [replayHighlight setBackgroundBorder:border];
        replayHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(commentCell:didSelectReferUserWithUserID:)]) {
                [weakSelf.delegate commentCell:weakSelf didSelectReferUserWithUserID:comment.at_uid];
            }
        };
        NSRange replayRange = [tempTextStr rangeOfString:[NSString stringWithFormat:@"@%@", comment.at_nick]];
        [attText yy_setColor:DXRGBColor(64, 189, 206) range:replayRange];
        [attText yy_setTextHighlight:replayHighlight range:replayRange];
    } else {
        textStr = comment.txt;
        attText = [[NSMutableAttributedString alloc] initWithString:textStr];
        attText.yy_color = DXRGBColor(72, 72, 72);
    }
    if (comment.content_pieces.count) {
        // 1. 得到attributed string
        // 2. 拿到事件回调
        
        for (DXContentPiece *piece in comment.content_pieces) {
            [tempTextStr appendString:piece.content];
            if (piece.type == DXContentPieceTypeRefer) {
                NSRange range = NSMakeRange(tempTextStr.length - piece.content.length, piece.content.length);
                YYTextHighlight *textHighlight = [[YYTextHighlight alloc] init];
                [textHighlight setBackgroundBorder:border];
                textHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                    if (piece.refer_type == DXReferTypeUser) {
                        if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(commentCell:didSelectReferUserWithUserID:)]) {
                            [weakSelf.delegate commentCell:weakSelf didSelectReferUserWithUserID:piece.refer_id];
                        }
                    } else {
                        if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(commentCell:didSelectReferTopicWithTopicID:)]) {
                            [weakSelf.delegate commentCell:weakSelf didSelectReferTopicWithTopicID:piece.refer_id];
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
    self.avatarV.frame = CGRectMake(DXRealValue(13), DXRealValue(13), DXRealValue(40), DXRealValue(40));
    
    // 昵称
    self.nickL.origin = CGPointMake(DXRealValue(63), DXRealValue(15));
    
    // 日期
    self.dateL.origin = CGPointMake(self.nickL.x, DXRealValue(35));
    
    // 评论内容
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(DXRealValue(308.0f), CGFLOAT_MAX) text:self.commentL.attributedText];
    CGFloat commentLX = self.nickL.x;
    CGFloat commentLY = DXRealValue(56.0f);
    CGFloat commentLW = layout.textBoundingSize.width;
    CGFloat commentLH = layout.textBoundingSize.height + YYLabelPadding;
    self.commentL.frame = CGRectMake(commentLX, commentLY, commentLW, commentLH);
    
    // 分割线
    self.dividerV.frame = CGRectMake(0, self.contentView.height - 0.5, self.contentView.width, 0.5);
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withComment:(DXComment *)comment {
    
    NSString *textStr;
    if (comment.at_nick) {
        textStr = [NSString stringWithFormat:@"回复@%@：%@", comment.at_nick, comment.txt];
    } else {
        textStr = [NSString stringWithFormat:@"%@", comment.txt];
    }
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:textStr];
    attText.yy_font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    attText.yy_lineSpacing = DXRealValue(3.0f);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(DXRealValue(308.0f), CGFLOAT_MAX) text:attText];
    CGFloat commentLH = layout.textBoundingSize.height + YYLabelPadding;
    
    CGFloat topMargin = DXRealValue(56.0f);
    CGFloat bottomMargin = DXRealValue(13.0f);
    
    return topMargin + commentLH + bottomMargin;
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.contentView.backgroundColor = DXRGBColor(240, 240, 240);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.contentView.backgroundColor = [UIColor whiteColor];
}
 */



#pragma mark - 点击按钮

- (void)avatarViewDidTap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentCell:didTapAvatarViewWithUserID:)]) {
        [self.delegate commentCell:self didTapAvatarViewWithUserID:self.comment.uid];
    }
}

@end
