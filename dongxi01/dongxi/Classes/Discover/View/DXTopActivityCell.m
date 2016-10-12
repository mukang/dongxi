//
//  DXTopActivityCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopActivityCell.h"

@interface DXTopActivityCell ()

@property (nonatomic) UIView * coverMaskView;

@end



@implementation DXTopActivityCell

- (instancetype)initWithFrame:(CGRect)frame {
    CGFloat width = frame.size.width;
    CGFloat height = width * 480 / 1242;
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height)];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
        [self setupContraints];
    }
    return self;
}

- (void)setupSubviews {
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.coverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.coverMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    self.coverMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.40];
    self.coverMaskView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.font = [DXFont fontWithName:DXCommonFontName size:20];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.typeAndPlaceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.typeAndPlaceLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.typeAndPlaceLabel.textColor = [UIColor whiteColor];
    self.typeAndPlaceLabel.textAlignment = NSTextAlignmentCenter;
    self.typeAndPlaceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.font = [DXFont systemFontOfSize:15 weight:DXFontWeightLight];
    self.timeLabel.textColor = DXRGBColor(177, 177, 177);
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.coverMaskView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.typeAndPlaceLabel];
    [self.contentView addSubview:self.timeLabel];
}

- (void)setupContraints {
    NSDictionary * views = @{
                             @"coverImageView"      : self.coverImageView,
                             @"coverMaskView"       : self.coverMaskView,
                             @"nameLabel"           : self.nameLabel,
                             @"typeAndPlaceLabel"   : self.typeAndPlaceLabel,
                             @"timeLabel"           : self.timeLabel
                             };
    NSDictionary * metrics = @{
                               @"coverImageViewWidth"   : @(self.bounds.size.width),
                               @"nameLabelTopMargin"    : @(DXRealValue(144.0/3))
                               };
    NSArray * visualFormats = @[
                                @"H:|[coverImageView]|",
                                @"H:|[coverMaskView]|",
                                @"H:|[nameLabel]|",
                                @"H:|[typeAndPlaceLabel]|",
                                @"H:|[timeLabel]|",
                                @"V:|[coverImageView]|",
                                @"V:|[coverMaskView]|",
                                @"V:|-nameLabelTopMargin-[nameLabel]-[typeAndPlaceLabel]-[timeLabel]"
                                ];
    for (NSString * vf in visualFormats) {
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
    }
}

@end
