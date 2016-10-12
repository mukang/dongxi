//
//  DXPublishAlbumSaveOptionCell.m
//  dongxi
//
//  Created by Xu Shiwen on 16/2/23.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishAlbumSaveOptionCell.h"

@implementation DXPublishAlbumSaveOptionCell {
    UIView * _borderView;
    UILabel * _titleLabel;
    UISwitch * _switchControl;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-0.5, frame.size.width, 0.5)];
        _borderView.backgroundColor = DXRGBColor(221, 221, 221);
        _borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_borderView];
    }
    return self;
}

- (void)setupViews {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"保存图片到相册";
    _titleLabel.font = [DXFont dxDefaultFontWithSize:15];
    _titleLabel.textColor = DXRGBColor(143, 143, 143);
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _switchControl = [[UISwitch alloc] init];
    _switchControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_switchControl];
    [self addSubview:_titleLabel];
    
    NSDictionary * views = @{
                             @"titleLabel"      : _titleLabel,
                             @"switchControl"   : _switchControl
                             };
    NSDictionary * metrics = @{
                               @"titleLabelLeftSpace"       : @(DXRealValue(32.0/3)),
                               @"switchControlRightSpace"   : @(DXRealValue(40.0/3))
                               };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-titleLabelLeftSpace-[titleLabel]-[switchControl]-switchControlRightSpace-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_switchControl
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0]];
}

@end
