//
//  DXMessageNoticeCell.m
//  dongxi
//
//  Created by 穆康 on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageNoticeCell.h"
#import "DXDongXiApi.h"
#import <UIImageView+WebCache.h>
#import "DXRichTextView.h"
#import "UIImage+Extension.h"
#import <YYText.h>

static NSString *const testStr = @"@小红帽：hahahahhahhahhahahahah你好啊#百事可乐#NIKE AIR TRAINER 1 MID";

@interface DXMessageNoticeCell () <DXRichTextViewDelegate>

/** 头像 */
@property (nonatomic, weak) DXAvatarView *avatarV;
/** 内容 */
@property (nonatomic, weak) YYLabel *contentLabel;
/** 日期 */
@property (nonatomic, weak) UILabel *dateLabel;
/** 分割线 */
@property (nonatomic, weak) UIView *separatorV;

@end

@implementation DXMessageNoticeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"MessageNoticeCell";
    
    DXMessageNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXMessageNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
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
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarDidTap)];
    [avatarV addGestureRecognizer:avatarTap];
    
    // 内容
    YYLabel *contentLabel = [[YYLabel alloc] init];
    contentLabel.textColor = DXRGBColor(102, 102, 102);
    [self.contentView addSubview:contentLabel];
    self.contentLabel = contentLabel;
    
    // 时间
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.textColor = DXRGBColor(143, 143, 143);
    dateLabel.font = [DXFont systemFontOfSize:12.0f weight:DXFontWeightLight];
    [self.contentView addSubview:dateLabel];
    self.dateLabel = dateLabel;
    
    // 分割线
    UIView *separatorV = [[UIView alloc] init];
    separatorV.backgroundColor = DXRGBColor(208, 208, 208);
    [self.contentView addSubview:separatorV];
    self.separatorV = separatorV;
}

- (void)setNotice:(DXNotice *)notice {
    
    _notice = notice;
    
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(50.0f), DXRealValue(50.0f))];
    [self.avatarV.avatarImageView sd_setImageWithURL:[NSURL URLWithString:notice.avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarV.verified = notice.verified;
    self.avatarV.certificationIconSize = DXCertificationIconSizeLarge;
    
    NSString *textStr;
    if (notice.type == 4) {
        textStr = [NSString stringWithFormat:@"%@，%@", notice.nick, notice.txt];
    } else {
        textStr = notice.txt;
    }
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:textStr];
    attText.yy_font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13.0f)];
    attText.yy_lineSpacing = DXRealValue(3.0f);
    self.contentLabel.attributedText = attText;
    
    self.dateLabel.text = notice.fmtTime;
    [self.dateLabel sizeToFit];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 头像
    self.avatarV.frame = CGRectMake(DXRealValue(13), DXRealValue(10), DXRealValue(50), DXRealValue(50));
    
    // 内容
    CGFloat contentLabelX = CGRectGetMaxX(self.avatarV.frame) + DXRealValue(13) - richTextViewPadding;
    CGFloat contentLabelY = DXRealValue(13);
    CGFloat contentLabelW = self.contentView.width - contentLabelX - DXRealValue(13);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(contentLabelW, CGFLOAT_MAX) text:self.contentLabel.attributedText];
    CGFloat contentLabelH = layout.textBoundingSize.height + DXRealValue(3.0f) * 2.0f;
    self.contentLabel.frame = CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH);
    
    // 时间
    CGFloat dateLabelX = contentLabelX;
    CGFloat dateLabelY = self.contentView.height - DXRealValue(10.0f) - self.dateLabel.height;
    self.dateLabel.origin = CGPointMake(dateLabelX, dateLabelY);
    
    // 分割线
    self.separatorV.size = CGSizeMake(self.contentView.width, 0.5);
    self.separatorV.x = 0;
    self.separatorV.y = self.contentView.height - 0.5;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withNotice:(DXNotice *)notice {
    
    CGFloat marginH = DXRealValue(13);
    
    CGFloat contentLabelW = DXScreenWidth - DXRealValue(89);
    NSString *textStr;
    if (notice.type == 4) {
        textStr = [NSString stringWithFormat:@"%@，%@", notice.nick, notice.txt];
    } else {
        textStr = notice.txt;
    }
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:textStr];
    attText.yy_font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13.0f)];
    attText.yy_lineSpacing = DXRealValue(3.0f);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(contentLabelW, CGFLOAT_MAX) text:attText];
    CGFloat contentLabelH = layout.textBoundingSize.height + DXRealValue(3.0f) * 2.0f;
    
    CGFloat contentLabel_DateLabel_Margin = DXRealValue(10.0f);
    CGFloat dateLabelH = DXRealValue(12.0f);
    
    CGFloat defaultH = DXRealValue(70);
    CGFloat realH = marginH + contentLabelH + contentLabel_DateLabel_Margin + dateLabelH + marginH;
    
    return (realH > defaultH) ? realH : defaultH;
}

- (void)avatarDidTap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAvatarInMessageNoticeCellWithUserID:)]) {
        [self.delegate didTapAvatarInMessageNoticeCellWithUserID:self.notice.uid];
    }
}

#pragma mark - DXRichTextViewDelegate

- (void)richTextView:(DXRichTextView *)richTextView didTapNick:(NSString *)nick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageNoticeCell:didTapNick:)]) {
        [self.delegate messageNoticeCell:self didTapNick:nick];
    }
}

- (void)richTextView:(DXRichTextView *)richTextView didTapTopic:(NSString *)topic {
    
    DXLog(@"%@", topic);
}

@end
