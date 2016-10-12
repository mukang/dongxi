//
//  DXDetailLikeCell.m
//  dongxi
//
//  Created by 穆康 on 15/8/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDetailLikeCell.h"
#import "DXDongXiApi.h"
#import <UIImageView+WebCache.h>
#import "DXFeedLikeAvatarView.h"

#define TopMargin                 DXRealValue(7)    // 内容顶部间距
#define AvatarV_Top_Margin        DXRealValue(48)   // 头像视图距背景的顶部和底部间距
#define AvatarV_Bottom_Margin     DXRealValue(20)   // 头像视图距背景的顶部和底部间距

@interface DXDetailLikeCell ()

/** 背景 */
@property (nonatomic, weak) UIView *bgView;
/** 点赞数 */
@property (nonatomic, weak) UILabel *likeCountLabel;
/** 点赞头像视图 */
@property (nonatomic, strong) DXFeedLikeAvatarView *avatarV;

@end

@implementation DXDetailLikeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"likeCell";
    
    DXDetailLikeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXDetailLikeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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
    
    // 背景
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bgView];
    self.bgView = bgView;
    
    // 点赞数
    UILabel *likeCountLabel = [[UILabel alloc] init];
    likeCountLabel.textColor = DXRGBColor(143, 143, 143);
    likeCountLabel.font = [DXFont dxDefaultFontWithSize:14];
    [self.bgView addSubview:likeCountLabel];
    self.likeCountLabel = likeCountLabel;
    
    // 点赞头像视图
    DXFeedLikeAvatarView *avatarV = [[DXFeedLikeAvatarView alloc] init];
    [self.bgView addSubview:avatarV];
    self.avatarV = avatarV;
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    // 点赞数
    self.likeCountLabel.text = [NSString stringWithFormat:@"%zd人点赞", feed.data.total_like];
    [self.likeCountLabel sizeToFit];
    
    // 点赞头像视图
    self.avatarV.feed = feed;
    [self.avatarV sizeToFit];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.feed.data.total_like > 0) {
        
        // 点赞数
        self.likeCountLabel.centerX = self.contentView.width * 0.5;
        self.likeCountLabel.y = DXRealValue(16);
        
        // 点赞头像视图
        self.avatarV.centerX = self.contentView.width * 0.5;
        self.avatarV.y = AvatarV_Top_Margin;
        
        // 背景
        self.bgView.frame = CGRectMake(0, TopMargin, self.contentView.width, self.contentView.height - TopMargin);
    }
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withFeed:(DXTimelineFeed *)feed {
    
    CGFloat AvatarVH = [DXFeedLikeAvatarView heightForLikeAvatarViewWithFeed:feed];
    
    if (feed.data.total_like > 0) {
        
        return TopMargin + AvatarV_Top_Margin + AvatarVH + AvatarV_Bottom_Margin;
    } else {
        
        return 0;
    }
}

@end
