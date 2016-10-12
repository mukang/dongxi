//
//  DXRecentContactCell.m
//  dongxi
//
//  Created by 穆康 on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRecentContactCell.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Extension.h"
#import "NSDate+Extension.h"
#import "DXLatestMessage.h"

@interface DXRecentContactCell ()

/** 头像 */
@property (nonatomic, weak) DXAvatarView *avatarV;
/** 昵称 */
@property (nonatomic, weak) UILabel *nickL;
/** 日期 */
@property (nonatomic, weak) UILabel *dateL;
/** 聊天记录 */
@property (nonatomic, weak) UILabel *chatL;
/** 未读数背景 */
@property (nonatomic, weak) UIView *unReadView;
/** 未读数 */
@property (nonatomic, weak) UILabel *unReadL;
/** 分割线 */
@property (nonatomic, weak) UIView *lineV;

@end

@implementation DXRecentContactCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"RecentContactCell";
    
    DXRecentContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXRecentContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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
    
    // 昵称
    UILabel *nickL = [[UILabel alloc] init];
    nickL.textColor = DXRGBColor(102, 102, 102);
    nickL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    [self.contentView addSubview:nickL];
    self.nickL = nickL;
    
    // 日期
    UILabel *dateL = [[UILabel alloc] init];
    dateL.textColor = DXRGBColor(143, 143, 143);
    dateL.textAlignment = NSTextAlignmentRight;
    dateL.font = [DXFont systemFontOfSize:10.0f weight:DXFontWeightLight];
    [self.contentView addSubview:dateL];
    self.dateL = dateL;
    
    // 聊天记录
    UILabel *chatL = [[UILabel alloc] init];
    chatL.textColor = DXRGBColor(143, 143, 143);
    chatL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13.3)];
    chatL.numberOfLines = 1;
    chatL.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    [self.contentView addSubview:chatL];
    self.chatL = chatL;
    
    // 未读数背景
    UIView *unReadView = [[UIView alloc] init];
    unReadView.backgroundColor = DXRGBColor(255, 115, 115);
    [self.contentView addSubview:unReadView];
    self.unReadView = unReadView;
    
    // 未读数
    UILabel *unReadL = [[UILabel alloc] init];
    unReadL.textColor = [UIColor whiteColor];
    unReadL.textAlignment = NSTextAlignmentCenter;
    unReadL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(9.0f)];
    [unReadView addSubview:unReadL];
    self.unReadL = unReadL;
    
    // 分割线
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = DXRGBColor(208, 208, 208);
    [self.contentView addSubview:lineV];
    self.lineV = lineV;
}

- (void)setLatestMessage:(DXLatestMessage *)latestMessage {
    _latestMessage = latestMessage;
    
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(50.0f), DXRealValue(50.0f))];
    [self.avatarV.avatarImageView sd_setImageWithURL:[NSURL URLWithString:latestMessage.chatMessage.other_avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarV.verified = latestMessage.chatMessage.other_verified;
    self.avatarV.certificationIconSize = DXCertificationIconSizeLarge;
    
    self.nickL.text = latestMessage.chatMessage.other_nick;
    
    if (latestMessage.chatMessage.type == eMessageBodyType_Text) {
        self.chatL.text = latestMessage.chatMessage.msg;
    } else {
        self.chatL.text = @"[语音]";
    }
    
    self.dateL.text = [NSDate formattedTimeFromTimeInterval:latestMessage.chatMessage.time];
    
    if (latestMessage.unreadCount) {
        self.unReadView.hidden = NO;
        if (latestMessage.unreadCount > 99) {
            latestMessage.unreadCount = 99;
        }
        self.unReadL.text = [NSString stringWithFormat:@"%zd", latestMessage.unreadCount];
    } else {
        self.unReadView.hidden = YES;
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    // 头像
    self.avatarV.size = CGSizeMake(DXRealValue(50), DXRealValue(50));
    self.avatarV.x = DXRealValue(13);
    self.avatarV.y = DXRealValue(6.0f);
    
    // 昵称
    self.nickL.size = CGSizeMake(DXRealValue(150), DXRealValue(15));
    self.nickL.x = CGRectGetMaxX(self.avatarV.frame) + DXRealValue(13);
    self.nickL.y = DXRealValue(16);
    
    // 日期
    self.dateL.size = CGSizeMake(80, 15);
//    self.dateL.centerY = self.nickL.centerY;
    self.dateL.y = DXRealValue(18);
    self.dateL.x = self.contentView.width - self.dateL.width - DXRealValue(13);
    
    // 聊天记录
    self.chatL.size = CGSizeMake(CGRectGetMaxX(self.dateL.frame) - self.nickL.x, DXRealValue(17.0f));
    self.chatL.x = self.nickL.x;
    self.chatL.y = DXRealValue(38.0f);
    
    // 未读数背景
    CGFloat unReadViewX = DXRealValue(49.6f);
    CGFloat unReadViewY = DXRealValue(5.0f);
    CGFloat unReadViewWH = DXRealValue(14.0f);
    self.unReadView.frame = CGRectMake(unReadViewX, unReadViewY, unReadViewWH, unReadViewWH);
    self.unReadView.layer.cornerRadius = unReadViewWH * 0.5f;
    self.unReadView.layer.masksToBounds = YES;
    
    // 未读数
    self.unReadL.frame = self.unReadView.bounds;
    
    // 分割线
    self.lineV.frame = CGRectMake(0, self.contentView.height - 0.5, self.contentView.width, 0.5);
}

@end
