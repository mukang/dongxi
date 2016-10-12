//
//  DXDetailTextCell.m
//  dongxi
//
//  Created by 穆康 on 15/8/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDetailTextCell.h"
#import <UIImageView+WebCache.h>
#import <YYText/YYText.h>
#import "DXDongXiApi.h"
#import "DXFeedTopicView.h"
#import "UIImage+Extension.h"

static CGFloat const addHeight = 1.0;

@interface DXDetailTextCell ()

/** 背景 */
@property (nonatomic, weak) UIView *bgView;
/** 头像 */
@property (nonatomic, weak) DXAvatarView *avatarV;
/** 昵称 */
@property (nonatomic, weak) UILabel *nickL;
/** 话题 */
@property (nonatomic, weak) DXFeedTopicView *topicV;
/** 日期背景图 */
@property (nonatomic, weak) UIImageView *dateV;
/** 日期 */
@property (nonatomic, weak) UILabel *dateL;
/** 正文 */
@property (nonatomic, weak) YYLabel *textL;

@end

@implementation DXDetailTextCell

#pragma mark - 初始化
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"textCell";
    
    DXDetailTextCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXDetailTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = DXRGBColor(222, 222, 222);
        
        [self setup];
    }
    return self;
}

// 初始化子控件
- (void)setup {
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bgView];
    self.bgView = bgView;
    
    // 头像
    DXAvatarView *avatarV = [[DXAvatarView alloc] init];
    [self.bgView addSubview:avatarV];
    self.avatarV = avatarV;
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewDidTap)];
    [avatarV addGestureRecognizer:avatarTap];
    
    
    // 昵称
    UILabel *nickL = [[UILabel alloc] init];
    nickL.textAlignment = NSTextAlignmentCenter;
    nickL.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(17)];
    [self.bgView addSubview:nickL];
    self.nickL = nickL;
    
    // 话题
    DXFeedTopicView *topicV = [[DXFeedTopicView alloc] init];
    topicV.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    [self.bgView addSubview:topicV];
    self.topicV = topicV;
    UITapGestureRecognizer *topicTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topicViewDidTap)];
    [topicV addGestureRecognizer:topicTap];
    
    // 日期背景图
    UIImageView *dateV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"border_calendar_feed"]];
    [self.bgView addSubview:dateV];
    self.dateV = dateV;
    
    // 日期
    UILabel *dateL = [[UILabel alloc] init];
    dateL.textColor = DXRGBColor(48, 48, 48);
    dateL.textAlignment = NSTextAlignmentCenter;
    dateL.numberOfLines = 0;
    [self.bgView addSubview:dateL];
    self.dateL = dateL;
    
    // 正文
    YYLabel *textL = [[YYLabel alloc] init];
    textL.numberOfLines = 0;
    textL.textColor = DXRGBColor(72, 72, 72);
    [self.bgView addSubview:textL];
    self.textL = textL;
}

#pragma mark - 填充数据
- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    // 头像
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(50.0f), DXRealValue(50.0f))];
    [self.avatarV.avatarImageView sd_setImageWithURL:[NSURL URLWithString:feed.avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarV.verified = feed.verified;
    self.avatarV.certificationIconSize = DXCertificationIconSizeLarge;
    
    // 昵称
    self.nickL.text = feed.nick;
    
    // 话题
    if (feed.data.topic.topic) {
        self.topicV.hidden = NO;
        self.topicV.text = [NSString stringWithFormat:@"#%@#", feed.data.topic.topic];
    } else {
        self.topicV.hidden = YES;
    }
    [self.topicV sizeToFit];

    // 日期
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:feed.time];
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:createDate];
    NSString *monthStr = [NSString stringWithFormat:@"%zd月", comp.month];
    NSString *dayStr = [NSString stringWithFormat:@"%02zd", comp.day];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", dayStr, monthStr]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:DXCommonFontName size:DXRealValue(20)] range:NSMakeRange(0, dayStr.length)];
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:DXCommonFontName size:DXRealValue(10)] range:NSMakeRange(dayStr.length, monthStr.length)];
    self.dateL.attributedText = attStr;
    
    // 正文
    NSString *textStr = feed.data.text;
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:textStr];
    attText.yy_font = [UIFont systemFontOfSize:DXRealValue(15.0f)];
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
                        if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(detailTextCell:didSelectReferUserWithUserID:)]) {
                            [weakSelf.delegate detailTextCell:weakSelf didSelectReferUserWithUserID:piece.refer_id];
                        }
                    } else {
                        if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(detailTextCell:didSelectReferTopicWithTopicID:)]) {
                            [weakSelf.delegate detailTextCell:weakSelf didSelectReferTopicWithTopicID:piece.refer_id];
                        }
                    }
                };
                [attText yy_setTextHighlight:textHighlight range:range];
                [attText yy_setColor:DXRGBColor(64, 189, 206) range:range];
            }
        }
    }
    self.textL.attributedText = attText;
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 头像
    self.avatarV.size = CGSizeMake(DXRealValue(50), DXRealValue(50));
    self.avatarV.centerX = self.contentView.width * 0.5;
    self.avatarV.y = DXRealValue(30);
    
    // 昵称
    self.nickL.size = CGSizeMake(self.contentView.width, DXRealValue(19.0f));
    self.nickL.centerX = self.avatarV.centerX;
    self.nickL.y = DXRealValue(90);
    
    // 话题
    self.topicV.centerX = self.avatarV.centerX;
    self.topicV.y = DXRealValue(114);
    
    // 日期背景图
    self.dateV.size = CGSizeMake(DXRealValue(50), DXRealValue(50));
    self.dateV.x = self.contentView.width - self.dateV.width - DXRealValue(42);
    self.dateV.y = DXRealValue(30);
    
    // 日期
    self.dateL.size = CGSizeMake(DXRealValue(30), DXRealValue(50));
    self.dateL.center = self.dateV.center;
    
    // 正文
    CGFloat textLabelX = DXRealValue(13);
    CGFloat textLabelY = DXRealValue(157);
    CGFloat textLabelW = self.contentView.width - textLabelX * 2.0;
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(textLabelW, CGFLOAT_MAX) text:self.textL.attributedText];
    CGFloat textLabelH = layout.textBoundingSize.height + addHeight;
    self.textL.frame = CGRectMake(textLabelX, textLabelY, textLabelW, textLabelH);
    
    // 背景
    self.bgView.frame = self.contentView.bounds;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withFeed:(DXTimelineFeed *)feed {
    
    CGFloat textTopMargin = DXRealValue(157);
    CGFloat textBottomMargin = DXRealValue(20);
    CGFloat textWidth = DXScreenWidth - DXRealValue(13) * 2.0;
    
    NSString *textStr = feed.data.text;
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc ]initWithString:textStr];
    attText.yy_font = [UIFont systemFontOfSize:DXRealValue(15.0f)];
    attText.yy_lineSpacing = DXRealValue(3.0f);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(textWidth, CGFLOAT_MAX) text:attText];
    CGFloat textHeight = layout.textBoundingSize.height + addHeight;
    
    return textTopMargin + textHeight + textBottomMargin;
}

/**
 *  点击了头像
 */
- (void)avatarViewDidTap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAvatarViewInDetailTextCellWithUserID:)]) {
        [self.delegate didTapAvatarViewInDetailTextCellWithUserID:self.feed.uid];
    }
}

/**
 *  点击了话题
 */
- (void)topicViewDidTap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapTopicViewInDetailTextCellWithTopicID:)]) {
        [self.delegate didTapTopicViewInDetailTextCellWithTopicID:self.feed.data.topic.topic_id];
    }
}


@end
