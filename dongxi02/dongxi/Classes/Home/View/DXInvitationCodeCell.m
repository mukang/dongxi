//
//  DXInvitationCodeCell.m
//  dongxi
//
//  Created by 穆康 on 15/11/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXInvitationCodeCell.h"
#import "DXDongXiApi.h"

@interface DXInvitationCodeCell ()

@property (nonatomic, weak) UIButton *bgBtn;

@property (nonatomic, weak) UILabel *invitationCodeL;

@property (nonatomic, weak) UILabel *promptsL;

@property (nonatomic, weak) UIView *coverV;

@end

@implementation DXInvitationCodeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"InvitationCodeCell";
    
    DXInvitationCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXInvitationCodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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

- (void)setup {

    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bgBtn setBackgroundImage:[UIImage imageNamed:@"invite_bg"] forState:UIControlStateNormal];
    [bgBtn addTarget:self action:@selector(bgBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:bgBtn];
    self.bgBtn = bgBtn;
    
    UILabel *invitationCodeL = [[UILabel alloc] init];
    invitationCodeL.textColor = [UIColor whiteColor];
    invitationCodeL.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(17.0f)];
    [self.bgBtn addSubview:invitationCodeL];
    self.invitationCodeL = invitationCodeL;
    
    UILabel *promptsL = [[UILabel alloc] init];
    promptsL.text = @"点击分享给朋友";
    promptsL.textColor = DXRGBColor(210, 237, 241);
    promptsL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13.3f)];
    [self.bgBtn addSubview:promptsL];
    self.promptsL = promptsL;
    
    UIView *coverV = [[UIView alloc] init];
    coverV.backgroundColor = [UIColor blackColor];
    coverV.alpha = 0.2f;
    [self.bgBtn addSubview:coverV];
    self.coverV = coverV;
}

- (void)setCoupon:(DXUserCoupon *)coupon {
    
    _coupon = coupon;
    
    self.invitationCodeL.text = [NSString stringWithFormat:@"邀请码：%@", coupon.coupon_id];
    self.coverV.hidden = !coupon.isShared;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat bgBtnW = DXRealValue(388.0f);
    CGFloat bgBtnH = DXRealValue(311.0f / 3.0f);
    self.bgBtn.size = CGSizeMake(bgBtnW, bgBtnH);
    self.bgBtn.centerX = self.contentView.width * 0.5f;
    self.bgBtn.y = 0;
    
    [self.invitationCodeL sizeToFit];
    self.invitationCodeL.centerX = bgBtnW * 0.5f;
    self.invitationCodeL.y = DXRealValue(137.0f / 3.0f);
    
    [self.promptsL sizeToFit];
    self.promptsL.centerX = bgBtnW * 0.5f;
    self.promptsL.y = DXRealValue(68.0f);
    
    self.coverV.frame = self.bgBtn.bounds;
    self.coverV.layer.cornerRadius = DXRealValue(40.0f / 3.0f);
    self.coverV.layer.masksToBounds = YES;
}

- (void)bgBtnDidClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(invitationCodeCell:shareInvitationCodeWithCouponIndex:)]) {
        [self.delegate invitationCodeCell:self shareInvitationCodeWithCouponIndex:self.couponIndex];
    }
}

@end
