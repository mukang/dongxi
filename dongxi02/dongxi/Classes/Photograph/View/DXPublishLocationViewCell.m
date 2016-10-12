//
//  DXPublishLocationViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishLocationViewCell.h"

@implementation DXPublishLocationViewCell {
    UIButton * _locationIconView;
    UILabel *_locationLabel;
    CGFloat _iconAspect;
    BOOL _isConstraintsSet;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.frame = self.bounds;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = DXRGBColor(221, 221, 221);
        
        UIImage * locationIcon = [UIImage imageNamed:@"icon_address"];
        UIImage * locationSelectIcon = [UIImage imageNamed:@"icon_address_click"];
        _locationIconView = [[UIButton alloc] initWithFrame:CGRectZero];
        [_locationIconView setImage:locationIcon forState:UIControlStateNormal];
        [_locationIconView setImage:locationSelectIcon forState:UIControlStateSelected];
        _locationIconView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _iconAspect = locationIcon.size.height / locationIcon.size.width;
        
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.font = [DXFont dxDefaultFontWithSize:40.0/3];
        _locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_locationIconView];
        [self.contentView addSubview:_locationLabel];
        [self setLocation:nil];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setupConstraints {
    [self removeConstraints:self.constraints];
    
    NSDictionary * views = @{
                             @"locationIconView"    : _locationIconView,
                             @"locationLabel"       : _locationLabel
                             };
    NSDictionary * metrics = @{
                               @"iconLeftMargin"    : @(DXRealValue(40.0/3)),
                               @"iconTextSpace"     : @(DXRealValue(20.0/3))
                               };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-iconLeftMargin-[locationIconView]-iconTextSpace-[locationLabel]-|"
                                                                 options:0
                                                                 metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_locationIconView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_locationIconView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_locationIconView
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:_iconAspect constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_locationLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_locationIconView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0]];
}


- (void)updateConstraints {
    if (!_isConstraintsSet) {
        [self setupConstraints];
        _isConstraintsSet = YES;
    }

    [super updateConstraints];
}


- (void)setLocation:(NSString *)location {
    _location = location;

    if (location) {
        _locationLabel.text = location;
        _locationLabel.textColor = DXRGBColor(66, 189, 205);
        [_locationIconView setSelected:YES];
    } else {
        _locationLabel.text = @"显示位置";
        _locationLabel.textColor = DXRGBColor(143, 143, 143);
        [_locationIconView setSelected:NO];
    }
}

@end
