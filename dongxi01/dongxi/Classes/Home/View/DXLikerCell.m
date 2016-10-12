//
//  DXLikerCell.m
//  dongxi
//
//  Created by 穆康 on 15/10/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLikerCell.h"
#import "UIResponder+Router.h"
#import "DXDongXiApi.h"
#import <UIImageView+WebCache.h>
#import "DXButton.h"
#import "AppDelegate.h"
#import "UIImage+Extension.h"

static NSString *const kUnFollowImageName = @"attention_add";      // 未关注
static NSString *const kFollowedImageName = @"attention_ok";         // 已关注
static NSString *const kFriendImageName = @"attention_mutual";     // 互相关注

@interface DXLikerCell ()

/** 头像 */
@property (nonatomic, weak) DXAvatarView *avatarV;
/** 昵称 */
@property (nonatomic, weak) UILabel *nickL;
/** 来自 */
@property (nonatomic, weak) UILabel *addrL;
/** 关注 */
@property (nonatomic, weak) DXButton *followBtn;
/** 分割线 */
@property (nonatomic, weak) UIView *separatorV;

@end

@implementation DXLikerCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"likerCell";
    
    DXLikerCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXLikerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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

- (void)setup {
    
    // 头像
    DXAvatarView *avatarV = [[DXAvatarView alloc] init];
    [self.contentView addSubview:avatarV];
    self.avatarV = avatarV;
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarDidTap)];
    [avatarV addGestureRecognizer:avatarTap];
    
    // 昵称
    UILabel *nickL = [[UILabel alloc] init];
    nickL.textColor = DXRGBColor(72, 72, 72);
    nickL.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(17)];
    [self.contentView addSubview:nickL];
    self.nickL = nickL;
    
    // 来自
    UILabel *addrL = [[UILabel alloc] init];
    addrL.textColor = DXCommonColor;
    addrL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    [self.contentView addSubview:addrL];
    self.addrL = addrL;
    
    // 关注
    DXButton *followBtn = [DXButton buttonWithType:UIButtonTypeCustom];
    [followBtn addTarget:self action:@selector(followBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:followBtn];
    self.followBtn = followBtn;
    
    // 分割线
    UIView *separatorV = [[UIView alloc] init];
    separatorV.backgroundColor = DXRGBColor(222, 222, 222);
    [self.contentView addSubview:separatorV];
    self.separatorV = separatorV;
}

- (void)setUser:(DXUser *)user {
    
    _user = user;
    
    // 头像
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(50.0f), DXRealValue(50.0f))];
    [self.avatarV.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarV.verified = user.verified;
    self.avatarV.certificationIconSize = DXCertificationIconSizeLarge;
    
    // 昵称
    self.nickL.text = user.nick;
    
    // 来自
    self.addrL.text = user.location;
    
    self.followBtn.hidden = NO;
    
    // 关注
    self.relation = user.relations;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.avatarV.size = CGSizeMake(DXRealValue(50), DXRealValue(50));
    self.avatarV.x = DXRealValue(13);
    self.avatarV.centerY = self.contentView.height * 0.5;
    
    [self.nickL sizeToFit];
    self.nickL.x = CGRectGetMaxX(self.avatarV.frame) + DXRealValue(13);
    self.nickL.y = DXRealValue(12);
    
    [self.addrL sizeToFit];
    self.addrL.x = self.nickL.x;
    self.addrL.y = CGRectGetMaxY(self.nickL.frame) + DXRealValue(7);
    
    self.followBtn.size = CGSizeMake(DXRealValue(58), DXRealValue(33));
    self.followBtn.x = self.contentView.width - DXRealValue(13) - self.followBtn.width;
    self.followBtn.centerY = self.contentView.height * 0.5;
    
    self.separatorV.size = CGSizeMake(self.contentView.width, 0.5);
    self.separatorV.x = 0;
    self.separatorV.y = self.contentView.height - self.separatorV.height;
}

- (void)avatarDidTap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAvatarInLikerCellWithUserID:)]) {
        [self.delegate didTapAvatarInLikerCellWithUserID:self.user.uid];
    }
}

- (void)followBtnDidClick {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didTapFollowBtnInLikerCell:withUser:)]) {
            //新的代理方法，由controller改变按钮样式，更灵活
            [self.delegate didTapFollowBtnInLikerCell:self withUser:self.user];
        } else if ([self.delegate respondsToSelector:@selector(didTapFollowBtnInLikerCellWithUser:)]) {
            //旧的代理方法，自动改变关注按钮样式，无法提前判断登陆
            switch (self.user.relations) {
                case DXUserRelationTypeNone:
                    [self.followBtn setImage:[UIImage imageNamed:kFollowedImageName] forState:UIControlStateNormal];
                    break;
                case DXUserRelationTypeFollower:
                    [self.followBtn setImage:[UIImage imageNamed:kFriendImageName] forState:UIControlStateNormal];
                    break;
                case DXUserRelationTypeFollowed:
                    [self.followBtn setImage:[UIImage imageNamed:kUnFollowImageName] forState:UIControlStateNormal];
                    break;
                case DXUserRelationTypeFriend:
                    [self.followBtn setImage:[UIImage imageNamed:kFollowedImageName] forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
            [self.delegate didTapFollowBtnInLikerCellWithUser:self.user];
        }
    }
}

- (void)setRelation:(DXUserRelationType)relation {
    _relation = relation;
    
    self.followBtn.hidden = NO;
    
    switch (relation) {
        case DXUserRelationTypeNone:
            [self.followBtn setImage:[UIImage imageNamed:kUnFollowImageName] forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeFollower:
            [self.followBtn setImage:[UIImage imageNamed:kUnFollowImageName] forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeFollowed:
            [self.followBtn setImage:[UIImage imageNamed:kFollowedImageName] forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeFriend:
            [self.followBtn setImage:[UIImage imageNamed:kFriendImageName] forState:UIControlStateNormal];
            break;
        default:
            self.followBtn.hidden = YES;
            break;
    }
}



@end
