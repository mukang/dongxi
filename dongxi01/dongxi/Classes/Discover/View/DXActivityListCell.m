//
//  DXActivityListCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityListCell.h"

@implementation DXActivityListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
        [self setupContraints];
    }
    return self;
}

- (void)setupSubviews {
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.coverImageView.translatesAutoresizingMaskIntoConstraints = NO;

    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.font = [DXFont fontWithName:DXCommonFontName size:19];
    self.nameLabel.textColor = DXRGBColor(72, 72, 72);
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descriptionLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.descriptionLabel.textColor = DXRGBColor(72, 72, 72);
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.separateView = [[UIView alloc] init];
    self.separateView.backgroundColor = DXRGBColor(200, 200, 200);
    self.separateView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.infoLabel];
    [self.contentView addSubview:self.descriptionLabel];
    [self.contentView addSubview:self.separateView];
}

- (void)setupContraints {
    CGFloat coverLeftMargin = DXRealValue(6.67f);
    CGFloat coverTopMargin = DXRealValue(6.67f);
    CGFloat coverHeight = DXRealValue(100.0f) - coverTopMargin * 2;
    CGFloat coverWidth = coverHeight;
    CGFloat labelLeftMargin = DXRealValue(104.0f);
    CGFloat labelTopMargin = DXRealValue(13.0f);
    
    NSDictionary * views = @{
                             @"coverImageView"      : self.coverImageView,
                             @"nameLabel"           : self.nameLabel,
                             @"infoLabel"           : self.infoLabel,
                             @"descriptionLabel"    : self.descriptionLabel,
                             @"separateView"        : self.separateView
                             };
    NSDictionary * metrics = @{
                               @"coverLeftMargin"   : @(coverLeftMargin),
                               @"coverTopMargin"    : @(coverTopMargin),
                               @"coverHeight"       : @(coverHeight),
                               @"coverWidth"        : @(coverWidth),
                               @"labelLeftMargin"   : @(labelLeftMargin),
                               @"labelTopMargin"    : @(labelTopMargin),
                               @"labelVerticalSpace": @(DXRealValue(5)),
                               @"separateViewH"     : @0.5,
                               @"separateViewMargin": @0
                               };
    NSArray * visualFormats = @[
                                @"H:|-coverLeftMargin-[coverImageView(==coverWidth)]",
                                @"H:|-labelLeftMargin-[nameLabel]-|",
                                @"H:|-labelLeftMargin-[infoLabel]-|",
                                @"H:|-labelLeftMargin-[descriptionLabel]-|",
                                @"V:|-coverTopMargin-[coverImageView(==coverWidth)]",
                                @"V:|-coverTopMargin-[coverImageView(==coverWidth)]",
                                @"V:|-labelTopMargin-[nameLabel]-labelVerticalSpace-[infoLabel]-labelVerticalSpace-[descriptionLabel]",
                                @"H:|-coverLeftMargin-[separateView]-separateViewMargin-|",
                                @"V:[separateView(separateViewH)]-separateViewMargin-|"
                                ];
    for (NSString * vf in visualFormats) {
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
    }
}

- (void)setTypeAndPlace:(NSString *)typeAndPlace {
    _typeAndPlace = typeAndPlace;
    [self updateInfoLabel];
}

- (void)setTime:(NSString *)time {
    _time = time;
    [self updateInfoLabel];
}

- (void)updateInfoLabel {
    NSString * typeAndPlace = self.typeAndPlace ? self.typeAndPlace : @"";
    NSString * time = self.time ? self.time : @"";
    NSString * infoString = [NSString stringWithFormat:@"%@  %@", typeAndPlace, time];
    
    NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:infoString];
    [attributedText addAttributes:@{
                                    NSFontAttributeName : [DXFont dxDefaultFontWithSize:45.0/3]
                                    }
                            range:NSMakeRange(0, typeAndPlace.length)];
    [attributedText addAttributes:@{
                                    NSFontAttributeName : [DXFont systemFontOfSize:45.0/3 weight:DXFontWeightLight],
                                    NSForegroundColorAttributeName : DXRGBColor(143, 143, 143)
                                    }
                            range:NSMakeRange(typeAndPlace.length+2, time.length)];
    if (self.keywords) { // 搜索
        [attributedText addAttribute:NSForegroundColorAttributeName value:DXRGBColor(143, 143, 143) range:NSMakeRange(0, typeAndPlace.length)];
        NSRange highlightedRange = [typeAndPlace rangeOfString:self.keywords options:NSCaseInsensitiveSearch];
        if (highlightedRange.location != NSNotFound) {
            [attributedText addAttribute:NSForegroundColorAttributeName value:DXCommonColor range:highlightedRange];
        }
    } else {
        [attributedText addAttributes:@{
                                        NSForegroundColorAttributeName : DXCommonColor
                                        }
                                range:NSMakeRange(0, typeAndPlace.length)];
    }
    
    self.infoLabel.attributedText = attributedText;
}

@end
