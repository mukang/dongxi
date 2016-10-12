//
//  DXInvitationView.m
//  dongxi
//
//  Created by 穆康 on 15/11/26.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXInvitationView.h"

@interface DXInvitationView ()

@property (nonatomic, weak) UIViewController *controller;
/** 黑色透明背景 */
@property (nonatomic, weak) UIView *bgView;
/** 白色图片view */
@property (nonatomic, weak) UIImageView *whiteView;
/** 提示文字 */
@property (nonatomic, weak) UILabel *warnLabel;
/** 有邀请码按钮 */
@property (nonatomic, weak) UIButton *hadKeyBtn;
/** 获取邀请码 */
@property (nonatomic, weak) UIButton *getKeyBtn;
/** 取消 */
@property (nonatomic, weak) UIButton *cancelBtn;

@end

@implementation DXInvitationView {
    __weak DXInvitationView *weakSelf;
}

- (instancetype)initWithController:(UIViewController *)controller {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self setupWithController:controller];
    }
    
    return self;
}

- (void)setupWithController:(UIViewController *)controller {
    
    weakSelf = self;
    [controller.view addSubview:self];
    self.controller = controller;
    self.frame = CGRectMake(0.0f, controller.view.height, controller.view.width, controller.view.height);
    
    // 黑色透明背景
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.0f;
    bgView.frame = controller.view.bounds;
    [controller.view insertSubview:bgView belowSubview:self];
    self.bgView = bgView;
    
    // 白色图片view
    UIImageView *whiteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"layer_white_warning"]];
    whiteView.userInteractionEnabled = YES;
    whiteView.size = CGSizeMake(DXRealValue(280.0f), DXRealValue(320.0f));
    whiteView.center = CGPointMake(self.width * 0.5f, self.height * 0.5f);
    [self addSubview:whiteView];
    self.whiteView = whiteView;
    
    // 提示文字
    UILabel *warnLabel = [[UILabel alloc] init];
    warnLabel.text = @"暂时需要邀请码\n才能注册";
    warnLabel.textColor = DXRGBColor(143, 143, 143);
    warnLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15.0f)];
    warnLabel.textAlignment = NSTextAlignmentCenter;
    warnLabel.numberOfLines = 2;
    [warnLabel sizeToFit];
    warnLabel.centerX = whiteView.width * 0.5f;
    warnLabel.y = DXRealValue(41.0f);
    [whiteView addSubview:warnLabel];
    
    // 有邀请码按钮
    UIButton *hadKeyBtn = [self buttonWithImageName:@"button_hadkey_normal" highlightedImageName:@"button_hadkey_click"];
    [hadKeyBtn addTarget:self action:@selector(hadKeyBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    hadKeyBtn.y = DXRealValue(118.0f);
    [whiteView addSubview:hadKeyBtn];
    
    // 获取邀请码
    UIButton *getKeyBtn = [self buttonWithImageName:@"button_getkey_normal" highlightedImageName:@"button_getkey_click"];
    [getKeyBtn addTarget:self action:@selector(getKeyBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    getKeyBtn.y = CGRectGetMaxY(hadKeyBtn.frame) + DXRealValue(10.0f);
    [whiteView addSubview:getKeyBtn];
    
    // 取消
    UIButton *cancelBtn = [self buttonWithImageName:@"button_cancel_normal" highlightedImageName:@"button_cancel_click"];
    [cancelBtn addTarget:self action:@selector(cancelBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.y = CGRectGetMaxY(getKeyBtn.frame) + DXRealValue(10.0f);
    [whiteView addSubview:cancelBtn];
}

#pragma mark - 快速创建btn

- (UIButton *)buttonWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    btn.size = CGSizeMake(DXRealValue(220.0f), DXRealValue(44.0f));
    btn.centerX = self.whiteView.width * 0.5f;
    
    return btn;
}

#pragma mark - 显示

- (void)show {
    
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.y = 0.0f;
        weakSelf.bgView.alpha = 0.65f;
    }];
}

#pragma mark - 点击按钮

// 点击有邀请码按钮
- (void)hadKeyBtnDidClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapHadKeyBtn)]) {
        [self.delegate didTapHadKeyBtn];
    }
}

// 点击获取邀请码按钮
- (void)getKeyBtnDidClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapGetKeyBtn)]) {
        [self.delegate didTapGetKeyBtn];
    }
}

// 点击取消按钮
- (void)cancelBtnDidClick {
    
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.y = self.controller.view.height;
        weakSelf.bgView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [weakSelf.bgView removeFromSuperview];
        [weakSelf removeFromSuperview];
    }];
}

@end
