//
//  DXActivityDetailCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityDetailCell.h"

@implementation DXActivityDetailCell {
    UIImageView * timeIcon;
    UIImageView * placeIcon;
    UIImageView * addressIcon;
    UIImageView * priceIcon;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews {
    timeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_event_detail_calendar"]];
    timeIcon.translatesAutoresizingMaskIntoConstraints = NO;
    
    placeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_event_detail_place"]];
    placeIcon.translatesAutoresizingMaskIntoConstraints = NO;
    
    addressIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_event_detail_location"]];
    addressIcon.translatesAutoresizingMaskIntoConstraints = NO;
    
    priceIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_event_detail_price"]];
    priceIcon.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineSpacing = DXRealValue(15 * 0.2);
    
    self.timeLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.timeLabel.textColor = DXRGBColor(72, 72, 72);
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeLabel.paragraphStyle = paragraphStyle;
    
    self.placeLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    self.placeLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.placeLabel.textColor = DXRGBColor(72, 72, 72);
    self.placeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeLabel.paragraphStyle = paragraphStyle;
    
    self.addressLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    self.addressLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.addressLabel.textColor = DXRGBColor(72, 72, 72);
    self.addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.addressLabel.paragraphStyle = paragraphStyle;
    
    self.priceLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    self.priceLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.priceLabel.textColor = DXRGBColor(72, 72, 72);
    self.priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.priceLabel.paragraphStyle = paragraphStyle;
    
    [self addSubview:timeIcon];
    [self addSubview:placeIcon];
    [self addSubview:addressIcon];
    [self addSubview:priceIcon];
    
    [self addSubview:self.timeLabel];
    [self addSubview:self.placeLabel];
    [self addSubview:self.addressLabel];
    [self addSubview:self.priceLabel];
}

- (void)setupConstraints {
    CGFloat iconLeftMargin = DXRealValue(40.0/3);
    CGFloat labelLeftMargin = DXRealValue(108.0/3);
    CGFloat timeLabelTopMargin = DXRealValue(100.0/3);
    CGFloat labelVerticalSpace = DXRealValue(45.0/3);
    
    NSDictionary * views = @{
                             @"timeIcon"        : timeIcon,
                             @"placeIcon"       : placeIcon,
                             @"addressIcon"     : addressIcon,
                             @"priceIcon"       : priceIcon,
                             @"timeLabel"       : self.timeLabel,
                             @"placeLabel"      : self.placeLabel,
                             @"addressLabel"    : self.addressLabel,
                             @"priceLabel"      : self.priceLabel
                             };
    NSDictionary * metrics = @{
                               @"iconLeftMargin"        : @(iconLeftMargin),
                               @"labelLeftMargin"       : @(labelLeftMargin),
                               @"timeLabelTopMargin"    : @(timeLabelTopMargin),
                               @"labelVerticalSpace"    : @(labelVerticalSpace)
                               };
    NSArray * visualFormats = @[
                                @"H:|-iconLeftMargin-[timeIcon]",
                                @"H:|-iconLeftMargin-[placeIcon]",
                                @"H:|-iconLeftMargin-[addressIcon]",
                                @"H:|-iconLeftMargin-[priceIcon]",
                                @"H:|-labelLeftMargin-[timeLabel]-|",
                                @"H:|-labelLeftMargin-[placeLabel]-|",
                                @"H:|-labelLeftMargin-[addressLabel]-|",
                                @"H:|-labelLeftMargin-[priceLabel]-|",
                                @"V:|-timeLabelTopMargin-[timeLabel]-labelVerticalSpace-[placeLabel]-labelVerticalSpace-[addressLabel]-labelVerticalSpace-[priceLabel]-timeLabelTopMargin-|"
                                ];
    for (NSString * vf in visualFormats) {
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
    }
    
    NSLayoutConstraint * topAlign = [NSLayoutConstraint constraintWithItem:timeIcon
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.timeLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:-1];
    [self addConstraint:topAlign];
    
    topAlign = [NSLayoutConstraint constraintWithItem:placeIcon
                                            attribute:NSLayoutAttributeTop
                                            relatedBy:NSLayoutRelationEqual
                                               toItem:self.placeLabel
                                            attribute:NSLayoutAttributeTop
                                           multiplier:1
                                             constant:-1];
    [self addConstraint:topAlign];
    
    topAlign = [NSLayoutConstraint constraintWithItem:addressIcon
                                            attribute:NSLayoutAttributeTop
                                            relatedBy:NSLayoutRelationEqual
                                               toItem:self.addressLabel
                                            attribute:NSLayoutAttributeTop
                                           multiplier:1
                                             constant:-1];
    [self addConstraint:topAlign];
    
    topAlign = [NSLayoutConstraint constraintWithItem:priceIcon
                                            attribute:NSLayoutAttributeTop
                                            relatedBy:NSLayoutRelationEqual
                                               toItem:self.priceLabel
                                            attribute:NSLayoutAttributeTop
                                           multiplier:1
                                             constant:-1];
    [self addConstraint:topAlign];
    
    
}


@end
