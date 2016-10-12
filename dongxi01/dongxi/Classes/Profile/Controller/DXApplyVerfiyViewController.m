//
//  DXApplyVerfiyViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXApplyVerfiyViewController.h"
#import "DXApplyVerfiyButton.h"

@interface DXApplyVerfiyViewController ()

@property (nonatomic, strong) NSArray * titleTexts;
@property (nonatomic, strong) NSArray * contentTexts;
@property (nonatomic, strong) UIView * textContainer;
@property (nonatomic, strong) DXApplyVerfiyButton * applyButton;
@property (nonatomic, strong) DXMutiLineLabel * messageLabel;

@end

@implementation DXApplyVerfiyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_AboutVerification;
    
    self.title = @"申请东西认证";
    
    self.titleTexts = @[@"什么是认证？",
                        @"认证用户有以下特权",
                        @"申请认证的条件"];
    
    self.contentTexts = @[@"认证是对东西用户的个人身份或见解的一种认证，拥有认证的用户在“东西”将是某个领域的行家、潮流的风向标、社交达人，或正努力成为这三者的人。",
                          @"1. 昵称旁有特殊的徽章认证标识\n2. 个人主页有认证说明，凸显认证身份\n3. 发布内容在App首页优先推荐\n4. 在找人页面进行推荐\n5. 其他特权陆续开放中...",
                          @"1. 在某个领域有独到的见解和收集品\n2. 能产生优质的内容\n3. 在app有很强的分享精神，活跃度高"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    self.scrollView.alwaysBounceVertical = YES;
    
    [self setupContents];
    [self estimateScrollViewContentSize];
    
    [self.applyButton addTarget:self action:@selector(applyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.applyButton setEnabled:NO];
    self.messageLabel.text = @"暂未开放，敬请期待";
}

- (void)setupContents {
    /******************************************************************
     *  创建 textContainer、applyButton及约束
     ******************************************************************/
    self.textContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.textContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.textContainer];
    
    self.applyButton = [[DXApplyVerfiyButton alloc] initWithFrame:CGRectZero];
    self.applyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.applyButton];
    
    self.messageLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.textColor = DXRGBColor(143, 143, 143);
    self.messageLabel.font = [DXFont dxDefaultFontWithSize:40.0/3];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.messageLabel];
    
    CGFloat applyButtonWidth = self.applyButton.properButtonSize.width;
    CGFloat applyButtonHeight = self.applyButton.properButtonSize.height;
    CGFloat applyButtonTop = roundf(DXRealValue(60));
    CGFloat messageLabelTop = roundf(DXRealValue(10));
    
    NSMutableArray * constraints = [NSMutableArray array];
    NSDictionary * views = NSDictionaryOfVariableBindings(_textContainer, _applyButton, _messageLabel);
    NSDictionary * metrics = @{@"applyButtonWidth"  :@(applyButtonWidth),
                               @"applyButtonHeight" :@(applyButtonHeight),
                               @"applyButtonTop"    :@(applyButtonTop),
                               @"messageLabelTop"   :@(messageLabelTop)};
    NSArray * visualFormats = @[@"H:|[_textContainer]|",
                                @"H:[_applyButton(==applyButtonWidth)]",
                                @"H:[_messageLabel(==applyButtonWidth)]",
                                @"V:|[_textContainer]-applyButtonTop-[_applyButton(==applyButtonHeight)]-messageLabelTop-[_messageLabel]"];
    for (NSString * vf in visualFormats) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views]];
    }
    //applyButton水平居中
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.applyButton
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.contentView
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0 constant:0]];
    //messageLabel水平居中
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.contentView
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0 constant:0]];
    
    [self.contentView addConstraints:constraints];
    
    /******************************************************************
     *  创建 textContainer的子视图及约束
     ******************************************************************/
    {
        NSMutableArray * titleLabels = [NSMutableArray array];
        NSMutableArray * contentLabels = [NSMutableArray array];
        for (int i = 0; i < self.titleTexts.count; i++) {
            UILabel * titleLabel = [[UILabel alloc] init];
            titleLabel.textColor = DXRGBColor(72, 72, 72);
            titleLabel.font = [DXFont dxDefaultBoldFontWithSize:15];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.text = [self.titleTexts objectAtIndex:i];
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self.textContainer addSubview:titleLabel];
            [titleLabels addObject:titleLabel];
            
            NSMutableParagraphStyle * paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineSpacing = DXRealValue(6);
            DXMutiLineLabel * contentLabel = [[DXMutiLineLabel alloc] init];
            contentLabel.textColor = DXRGBColor(72, 72, 72);
            contentLabel.font = [DXFont dxDefaultFontWithSize:15];
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.paragraphStyle = paragraphStyle;
            contentLabel.text = [self.contentTexts objectAtIndex:i];
            contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self.textContainer addSubview:contentLabel];
            [contentLabels addObject:contentLabel];
        }
        
        CGFloat textLeading = roundf(DXRealValue(36));
        CGFloat textTrailing = textLeading;
        CGFloat firstLabelTop = roundf(DXRealValue(27));
        CGFloat contentLabelBottom = roundf(DXRealValue(21));
        
        NSMutableArray * containerConstraints = [NSMutableArray array];
        
        NSMutableString * verticalVisualFormat = [NSMutableString string];
        NSMutableDictionary * verticalViews = [NSMutableDictionary dictionary];
        NSDictionary * verticalMetrics = @{@"firstLabelTop"         : @(firstLabelTop),
                                           @"contentLabelBottom"    : @(contentLabelBottom)};
        for (int i = 0; i < titleLabels.count; i++) {
            UILabel * titleLabel = [titleLabels objectAtIndex:i];
            NSString * titleLabelName = [NSString stringWithFormat:@"titleLabel%d", i];
            [verticalViews setObject:titleLabel forKey:titleLabelName];
            
            DXMutiLineLabel * contentLabel = [contentLabels objectAtIndex:i];
            NSString * contentLabelName = [NSString stringWithFormat:@"contentLabel%d", i];
            [verticalViews setObject:contentLabel forKey:contentLabelName];
            
            // 水平约束
            NSDictionary * horizonViews = NSDictionaryOfVariableBindings(titleLabel, contentLabel);
            NSDictionary * horizonMetrics = @{@"textLeading"   : @(textLeading),
                                              @"textTrailing"  : @(textTrailing)};
            [containerConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-textLeading-[titleLabel]-textTrailing-|"
                                                                                              options:0
                                                                                              metrics:horizonMetrics
                                                                                                views:horizonViews]];
            [containerConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-textLeading-[contentLabel]-textTrailing-|"
                                                                                              options:0
                                                                                              metrics:horizonMetrics
                                                                                                views:horizonViews]];
            // 垂直约束
            if (i == 0) {
                [verticalVisualFormat appendFormat:@"V:|-firstLabelTop-[%@]-[%@]", titleLabelName, contentLabelName];
            } else {
                [verticalVisualFormat appendFormat:@"-contentLabelBottom-[%@]-[%@]", titleLabelName, contentLabelName];
            }
            
            if (i == titleLabels.count - 1) {
                [verticalVisualFormat appendString:@"|"];
            }
        }
        [containerConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:verticalVisualFormat options:0 metrics:verticalMetrics views:verticalViews]];
        
        [self.contentView addConstraints:containerConstraints];
    }
}

- (void)estimateScrollViewContentSize {
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    CGSize contentSize = CGSizeMake(DXScreenWidth, CGRectGetMaxY(self.messageLabel.frame));
    self.scrollView.contentSize = contentSize;
}


#pragma mark - Button Actions

- (IBAction)applyButtonTapped:(DXApplyVerfiyButton *)sender {
    
}


@end
