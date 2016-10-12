//
//  DXMessageLikeCell.m
//  dongxi
//
//  Created by 穆康 on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageLikeCell.h"
#import "DXDongXiApi.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Extension.h"

@interface DXMessageLikeCell ()

/** 头像 */
@property (nonatomic, weak) DXAvatarView *avatarV;
/** 内容 */
@property (nonatomic, weak) UILabel *textL;
/** 日期 */
@property (nonatomic, weak) UILabel *dateL;
/** feed图片 */
@property (nonatomic, weak) UIImageView *feedImageV;
/** 分割线 */
@property (nonatomic, weak) UIView *separatorV;

@end

@implementation DXMessageLikeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"RecentContactCell";
    
    DXMessageLikeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXMessageLikeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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
    UILabel *textL = [[UILabel alloc] init];
    textL.textColor = DXRGBColor(102, 102, 102);
    textL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13)];
    [self.contentView addSubview:textL];
    self.textL = textL;
    
    // 日期
    UILabel *dateL = [[UILabel alloc] init];
    dateL.textColor = DXRGBColor(143, 143, 143);
    dateL.font = [DXFont systemFontOfSize:12.0f weight:DXFontWeightLight];
    [self.contentView addSubview:dateL];
    self.dateL = dateL;
    
    // feed图片
    UIImageView *feedImageV = [[UIImageView alloc] init];
    [self.contentView addSubview:feedImageV];
    self.feedImageV = feedImageV;
    
    // 分割线
    UIView *separatorV = [[UIView alloc] init];
    separatorV.backgroundColor = DXRGBColor(208, 208, 208);
    [self.contentView addSubview:separatorV];
    self.separatorV = separatorV;
}

- (void)setLike:(DXNoticeLike *)like {
    
    _like = like;
    
    // 头像
    NSURL *avatarUrl = [NSURL URLWithString:like.avatar];
    UIImage *avatarPlaceholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(50.0f), DXRealValue(50.0f))];
    [self.avatarV.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:avatarPlaceholderImage options:SDWebImageRetryFailed];
    self.avatarV.verified = like.verified;
    self.avatarV.certificationIconSize = DXCertificationIconSizeLarge;
    
    // 内容
    self.textL.text = [NSString stringWithFormat:@"%@，赞了", like.nick];
    
    // 日期
    self.dateL.text = like.likeTime;
    
    // feed图片
    UIImage *feedPlaceholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(60.0f), DXRealValue(60.0f))];
    [self.feedImageV sd_setImageWithURL:[NSURL URLWithString:like.photo] placeholderImage:feedPlaceholderImage options:SDWebImageRetryFailed];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 头像
    self.avatarV.size = CGSizeMake(DXRealValue(50), DXRealValue(50));
    self.avatarV.x = DXRealValue(13);
    self.avatarV.centerY = self.contentView.height * 0.5;
    
    // 内容
    self.textL.size = CGSizeMake(DXRealValue(250), DXRealValue(14));
    self.textL.x = CGRectGetMaxX(self.avatarV.frame) + DXRealValue(13);
    self.textL.y = DXRealValue(25);
    
    // 日期
    self.dateL.size = CGSizeMake(DXRealValue(150), DXRealValue(12));
    self.dateL.x = self.textL.x;
    self.dateL.y = CGRectGetMaxY(self.textL.frame) + DXRealValue(7);
    
    // feed图片
    self.feedImageV.size = CGSizeMake(DXRealValue(60), DXRealValue(60));
    self.feedImageV.x = DXScreenWidth - self.feedImageV.width - DXRealValue(13);
    self.feedImageV.centerY = self.contentView.height * 0.5;
    
    // 分割线
    self.separatorV.size = CGSizeMake(self.contentView.width, 0.5);
    self.separatorV.x = 0;
    self.separatorV.y = self.contentView.height - self.separatorV.height;
}

/**
 *  头像被点击
 */
- (void)avatarDidTap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAvatarInMessageLikeCellWithUserID:)]) {
        [self.delegate didTapAvatarInMessageLikeCellWithUserID:self.like.uid];
    }
}

@end
