//
//  DXSearchResultsUserCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/22.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchResultsUserCell.h"
#import "DXAvatarView.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Extension.h"

@interface DXSearchResultsUserCell ()

@property (nonatomic, weak) DXAvatarView *avatarView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIView *separateView;

@end

@implementation DXSearchResultsUserCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    DXAvatarView *avatarView = [[DXAvatarView alloc] init];
    [self.contentView addSubview:avatarView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textColor = DXRGBColor(72, 72, 72);
    nameLabel.font = [DXFont dxDefaultFontWithSize:15];
    [self.contentView addSubview:nameLabel];
    
    UIView *separateView = [[UIView alloc] init];
    separateView.backgroundColor = DXRGBColor(200, 200, 200);
    [self.contentView addSubview:separateView];
    
    self.avatarView = avatarView;
    self.nameLabel = nameLabel;
    self.separateView = separateView;
}

- (void)setUser:(DXUser *)user {
    _user = user;
    
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(40), DXRealValue(40))];
    [self.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarView.verified = user.verified;
    self.avatarView.certificationIconSize = DXCertificationIconSizeMedium;
    
    self.nameLabel.attributedText = [self setHighlightedString:self.keywords withOriginString:user.nick];
    [self.nameLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat avatarViewWH = DXRealValue(40);
    self.avatarView.size = CGSizeMake(avatarViewWH, avatarViewWH);
    self.avatarView.x = DXRealValue(40/3.0);
    self.avatarView.centerY = self.contentView.height * 0.5;
    
    self.nameLabel.x = CGRectGetMaxX(self.avatarView.frame) + DXRealValue(46/3.0);
    self.nameLabel.centerY = self.avatarView.centerY;
    
    CGFloat separateViewX = DXRealValue(40/3.0);
    CGFloat separateViewW = self.contentView.width - separateViewX;
    CGFloat separateViewH = 0.5;
    CGFloat separateViewY = self.contentView.height - separateViewH;
    self.separateView.frame = CGRectMake(separateViewX, separateViewY, separateViewW, separateViewH);
}

- (NSAttributedString *)setHighlightedString:(NSString *)highlightedString withOriginString:(NSString *)originString {
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:originString];
    if (self.keywords) {
        NSRange highlightedRange = [originString rangeOfString:highlightedString options:NSCaseInsensitiveSearch];
        if (highlightedRange.location != NSNotFound) {
            [attrStr addAttribute:NSForegroundColorAttributeName value:DXCommonColor range:highlightedRange];
        }
    }
    return [attrStr copy];
}

@end
