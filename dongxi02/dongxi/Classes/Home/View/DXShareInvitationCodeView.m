//
//  DXShareInvitationCodeView.m
//  dongxi
//
//  Created by 穆康 on 15/11/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXShareInvitationCodeView.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <SDWebImageManager.h>

static NSString *const kRedirectURI = @"https://api.weibo.com/oauth2/default.html";
static NSInteger const defautTag = 20000;

@interface DXShareInvitationCodeView ()

@end

@implementation DXShareInvitationCodeView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat btnWH = DXRealValue(50);
    CGFloat btnY = DXRealValue(26);
    CGFloat labelY = DXRealValue(80);
    
    // 微信好友
    UIButton *sessionBtn = [self setupButtonWithImageName:@"button_wechat_normal" highlightedImageName:@"button_wechat_click" disabledImageName:@"button_wechat_disabled"];
    sessionBtn.tag = defautTag;
    [sessionBtn addTarget:self action:@selector(weChatBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    sessionBtn.frame = CGRectMake(DXRealValue(56), btnY, btnWH, btnWH);
    [self addSubview:sessionBtn];
    
    UILabel *sessionL = [self setupLabelWithText:@"微信好友"];
    sessionL.centerX = sessionBtn.centerX;
    sessionL.y = labelY;
    [self addSubview:sessionL];
    
    // 朋友圈
    UIButton *timelineBtn = [self setupButtonWithImageName:@"button_friend_normal" highlightedImageName:@"button_friend_click" disabledImageName:@"button_friend_disabled"];
    timelineBtn.tag = defautTag + 1;
    [timelineBtn addTarget:self action:@selector(weChatBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    timelineBtn.frame = CGRectMake(DXRealValue(140), btnY, btnWH, btnWH);
    [self addSubview:timelineBtn];
    
    UILabel *timelineL = [self setupLabelWithText:@"朋友圈"];
    timelineL.centerX = timelineBtn.centerX;
    timelineL.y = labelY;
    [self addSubview:timelineL];
    
    // 短信
    UIButton *smsBtn = [self setupButtonWithImageName:@"share_shit_icon" highlightedImageName:@"share_shit_icon_click"];
    [smsBtn addTarget:self action:@selector(smsBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    smsBtn.frame = CGRectMake(DXRealValue(224), btnY, btnWH, btnWH);
    [self addSubview:smsBtn];
    
    UILabel *smsL = [self setupLabelWithText:@"短信"];
    smsL.centerX = smsBtn.centerX;
    smsL.y = labelY;
    [self addSubview:smsL];
    
    // 邮件
    UIButton *emailBtn = [self setupButtonWithImageName:@"share_icon_clickl" highlightedImageName:@"share_email_icon"];
    [emailBtn addTarget:self action:@selector(emailBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    emailBtn.frame = CGRectMake(DXRealValue(308), btnY, btnWH, btnWH);
    [self addSubview:emailBtn];
    
    UILabel *emailL = [self setupLabelWithText:@"邮件"];
    emailL.centerX = emailBtn.centerX;
    emailL.y = labelY;
    [self addSubview:emailL];
    
    // 分割线
    UIView *dividerV = [[UIView alloc] init];
    dividerV.backgroundColor = DXRGBColor(208, 208, 208);
    dividerV.frame = CGRectMake(0, DXRealValue(120), DXScreenWidth, 0.5);
    [self addSubview:dividerV];
    
    // 取消按钮
    UIButton *cancellBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancellBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancellBtn setTitleColor:DXRGBColor(72, 72, 72) forState:UIControlStateNormal];
    cancellBtn.titleLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13)];
    [cancellBtn addTarget:self action:@selector(cancellBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    cancellBtn.frame = CGRectMake(0, DXRealValue(120), DXScreenWidth, DXRealValue(50));
    [self addSubview:cancellBtn];
    
    // 判断用户设备是否安装了微信客户端
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        sessionBtn.enabled = NO;
        timelineBtn.enabled = NO;
        DXLog(@"没有安装微信客户端");
    }
}

- (UIButton *)setupButtonWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    
    return btn;
}

- (UIButton *)setupButtonWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName disabledImageName:(NSString *)disabledImageName {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:disabledImageName] forState:UIControlStateDisabled];
    
    return btn;
}

- (UILabel *)setupLabelWithText:(NSString *)text {
    
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = DXRGBColor(72, 72, 72);
    label.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(14)];
    [label sizeToFit];
    
    return label;
}

#pragma mark - 点击按钮

/**
 *  点击分享微信好友或朋友圈按钮
 */
- (void)weChatBtnDidClick:(UIButton *)btn {
    
    int sence = (int)(btn.tag - defautTag);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareInvitationCodeView:didTapWechatBtnWithSence:)]) {
        [self.delegate shareInvitationCodeView:self didTapWechatBtnWithSence:sence];
    }
}

/**
 *  点击短信按钮
 */
- (void)smsBtnDidClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapSmsBtnInShareInvitationCodeView:)]) {
        [self.delegate didTapSmsBtnInShareInvitationCodeView:self];
    }
}

/**
 *  点击邮件按钮
 */
- (void)emailBtnDidClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapEmailBtnInShareInvitationCodeView:)]) {
        [self.delegate didTapEmailBtnInShareInvitationCodeView:self];
    }
}

/**
 *  点击取消按钮
 */
- (void)cancellBtnDidClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCancellBtnInShareInvitationCodeView:)]) {
        [self.delegate didClickCancellBtnInShareInvitationCodeView:self];
    }
}

@end
