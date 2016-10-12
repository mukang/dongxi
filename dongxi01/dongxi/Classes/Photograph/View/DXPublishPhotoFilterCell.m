//
//  DXPublishPhotoFilterCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishPhotoFilterCell.h"

@implementation DXPublishPhotoFilterCell {
    UIColor * _normalTextColor;
    UIColor * _selectedTextColor;
    UIImageView * _selectedBorderView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        
        _selectedTextColor = DXRGBColor(72, 72, 72);
        _normalTextColor = DXRGBColor(181, 181, 181);
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    UIImage * selectedBorderImage = [UIImage imageNamed:@"bg_Filter_choice"];
    _selectedBorderView = [[UIImageView alloc] initWithImage:selectedBorderImage];
    _selectedBorderView.hidden = YES;
    _selectedBorderView.translatesAutoresizingMaskIntoConstraints = NO;

    _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _previewImageView.backgroundColor = DXRGBColor(222, 222, 222);
    _previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _filterNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _filterNameLabel.font = [DXFont dxDefaultFontWithSize:45.0/3];
    _filterNameLabel.textAlignment = NSTextAlignmentCenter;
    _filterNameLabel.textColor = _normalTextColor;
    _filterNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_selectedBorderView];
    [self addSubview:_previewImageView];
    [self addSubview:_filterNameLabel];
    
    NSDictionary * views = @{
                             @"previewImageView"    : _previewImageView,
                             @"filterNameLabel"     : _filterNameLabel,
                             };
    
    NSDictionary * metrics = @{
                               @"filterNameLabelTopSpace": @(DXRealValue(30.0/3)),
                               @"previewImageViewLength": @(self.bounds.size.width)
                               };
    NSArray * visualFormats = @[
                                @"H:|[previewImageView]|",
                                @"H:|[filterNameLabel]|",
                                @"V:|[previewImageView(==previewImageViewLength)]-filterNameLabelTopSpace-[filterNameLabel]|"
                                ];
    for (NSString * vf in visualFormats) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views]];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.previewImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.previewImageView
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_selectedBorderView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_previewImageView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_selectedBorderView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_previewImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_selectedBorderView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_previewImageView
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:DXRealValue(6)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_selectedBorderView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_previewImageView
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0 constant:DXRealValue(6)]];
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        _selectedBorderView.hidden = NO;
        _filterNameLabel.textColor = _selectedTextColor;
    } else {
        _selectedBorderView.hidden = YES;
        _filterNameLabel.textColor = _normalTextColor;
    }
}

@end
