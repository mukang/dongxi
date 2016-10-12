//
//  DXLikeRankAlertView.m
//  dongxi
//
//  Created by 穆康 on 16/3/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLikeRankAlertView.h"

@interface DXLikeRankAlertView ()

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIImageView *rankImageView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UIButton *doneButton;

@end

@implementation DXLikeRankAlertView {
    __weak DXLikeRankAlertView *_weakSelf;
    __weak UIViewController *_controller;
}

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content fromController:(UIViewController *)controller {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _weakSelf = self;
        _controller = controller;
        [self setupWithTitle:title content:content];
    }
    return self;
}

- (void)setupWithTitle:(NSString *)title content:(NSString *)content {
    
    [_controller.view addSubview:self];
    self.frame = _controller.view.bounds;
    self.backgroundColor = [UIColor clearColor];
    
    // 容器view
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.size = CGSizeMake(DXRealValue(698/3.0), DXRealValue(304));
    containerView.centerX = self.width * 0.5;
    containerView.centerY = self.height + containerView.height * 0.5;
    containerView.layer.cornerRadius = DXRealValue(7);
    containerView.layer.masksToBounds = YES;
    [self addSubview:containerView];
    
    // 图片
    UIImageView *rankImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"like_rank_alert_image"]];
    rankImageView.size = CGSizeMake(DXRealValue(671/3.0), DXRealValue(350/3.0));
    rankImageView.centerX = containerView.width * 0.5;
    rankImageView.y = DXRealValue(7/3.0);
    [containerView addSubview:rankImageView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = DXRGBColor(72, 72, 72);
    titleLabel.font = [DXFont dxDefaultBoldFontWithSize:15];
    [titleLabel sizeToFit];
    titleLabel.centerX = containerView.width * 0.5;
    titleLabel.y = DXRealValue(466/3.0);
    [containerView addSubview:titleLabel];
    
    // 内容
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = content;
    contentLabel.textColor = DXRGBColor(72, 72, 72);
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.font = [DXFont dxDefaultFontWithSize:12];
    contentLabel.numberOfLines = 0;
    contentLabel.width = containerView.width - 10;
    contentLabel.height = [contentLabel textRectForBounds:CGRectMake(0, 0, contentLabel.width, CGFLOAT_MAX) limitedToNumberOfLines:0].size.height;
    contentLabel.centerX = containerView.width * 0.5;
    contentLabel.y = DXRealValue(182);
    [containerView addSubview:contentLabel];
    
    // 完成按钮
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"我知道啦" forState:UIControlStateNormal];
    [doneButton setTitleColor:DXRGBColor(110, 196, 255) forState:UIControlStateNormal];
    doneButton.titleLabel.font = [DXFont dxDefaultFontWithSize:15];
    [doneButton addTarget:self action:@selector(handleDoneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    doneButton.size = CGSizeMake(containerView.width, DXRealValue(51));
    doneButton.x = 0;
    doneButton.y = containerView.height - doneButton.height;
    [containerView addSubview:doneButton];
    
    self.containerView = containerView;
    self.rankImageView = rankImageView;
    self.titleLabel = titleLabel;
    self.contentLabel = contentLabel;
    self.doneButton = doneButton;
}

- (void)show {
    
    [UIView animateWithDuration:0.2 animations:^{
        _weakSelf.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.55];
        _weakSelf.containerView.centerY = _weakSelf.height * 0.5;
    }];
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.2 animations:^{
        _weakSelf.backgroundColor = [UIColor clearColor];
        _weakSelf.containerView.centerY = _weakSelf.height + _weakSelf.containerView.height * 0.5;
    } completion:^(BOOL finished) {
        [_weakSelf removeFromSuperview];
    }];
}

- (void)handleDoneButtonClick {
    [self dismiss];
}

@end
