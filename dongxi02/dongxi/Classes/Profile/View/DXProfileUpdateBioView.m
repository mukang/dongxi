//
//  DXProfileUpdateBioView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileUpdateBioView.h"

@implementation DXProfileUpdateBioView {
    UILabel * _titleLabel;
    UIImageView * _moreImageView;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareSubviews];
    }
    return self;
}


- (void)prepareSubviews {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.text = @"简介";
    _titleLabel.font = [DXFont dxDefaultFontWithSize:50.0/3];
    _titleLabel.textColor = DXRGBColor(72, 72, 72);
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_titleLabel];
    
    _bioLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    _bioLabel.font = [DXFont dxDefaultFontWithSize:50.0/3];
    _bioLabel.textColor = DXRGBColor(72, 72, 72);
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = DXRealValue(6);
    _bioLabel.paragraphStyle = paragraphStyle;
    _bioLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bioLabel];
    
    UIImage * moreIcon = [UIImage imageNamed:@"set_more"];
    _moreImageView = [[UIImageView alloc] initWithImage:moreIcon];
    _moreImageView.image = moreIcon;
    _moreImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_moreImageView];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [self setupConstraints];
    
    [super updateConstraints];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints {
    [self removeConstraints:self.constraints];
    
    CGFloat titleLabelLeading = DXRealValue(40.0/3);
    CGFloat titleLabelWidth = DXRealValue(182.0/3);
    CGFloat bioLabelTop = DXRealValue(63.0/3);
    CGFloat bioLabelBottom = bioLabelTop;
    CGFloat bioLabelMinHeight = DXRealValue(62)-bioLabelTop-bioLabelBottom;
    CGFloat bioLabelTrailing = DXRealValue(144.0/3);
    CGFloat moreIconTrailing = DXRealValue(53.0/3);
    
    NSMutableArray * constraints = [NSMutableArray array];
    
    NSDictionary * views = NSDictionaryOfVariableBindings(_titleLabel,_bioLabel,_moreImageView);
    NSDictionary * metrics = @{
                               @"titleLabelLeading"     : @(titleLabelLeading),
                               @"titleLabelWidth"       : @(titleLabelWidth),
                               @"bioLabelMinHeight"     : @(bioLabelMinHeight),
                               @"bioLabelTop"           : @(bioLabelTop),
                               @"bioLabelBottom"        : @(bioLabelBottom),
                               @"bioLabelTrailing"      : @(bioLabelTrailing),
                               @"moreIconTrailing"      : @(moreIconTrailing)
                               };
    NSMutableArray * visualFormats = [NSMutableArray array];
    [visualFormats addObject:@"H:|-titleLabelLeading-[_titleLabel(==titleLabelWidth)][_bioLabel]-bioLabelTrailing-|"];
    [visualFormats addObject:@"H:[_moreImageView]-moreIconTrailing-|"];
    [visualFormats addObject:@"V:|-bioLabelTop-[_bioLabel(>=bioLabelMinHeight@800)]-bioLabelBottom-|"];
    
    for (NSString * vf in visualFormats) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views]];
    }
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_bioLabel
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_moreImageView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0]];
    [self addConstraints:constraints];
}

@end
