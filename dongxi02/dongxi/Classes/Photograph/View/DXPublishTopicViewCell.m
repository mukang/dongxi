//
//  DXPublishTopicViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishTopicViewCell.h"

@implementation DXPublishTopicViewCell {
    UIView * _borderView;
    UILabel * _titleLabel;
    UILabel * _textLabel;
    UIImageView * _decoratorView;
    
    BOOL _showDecoratorView;
}

- (instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        
        // 由于话题不再可以修改，所以去除点击反馈 (since v1.2.0)
        // self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        // self.selectedBackgroundView.backgroundColor = DXRGBColor(222, 222, 222);
        
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-0.5, frame.size.width, 0.5)];
        _borderView.backgroundColor = DXRGBColor(221, 221, 221);
        _borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_borderView];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}


- (void)setupViews {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"话题";
    _titleLabel.font = [DXFont dxDefaultFontWithSize:15];
    _titleLabel.textColor = DXRGBColor(143, 143, 143);
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.text = @"#话题#";
    _textLabel.font = [DXFont dxDefaultFontWithSize:15];
    _textLabel.textColor = DXRGBColor(64, 189, 206);
    _textLabel.textAlignment = NSTextAlignmentRight;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _decoratorView = [[UIImageView alloc] init];
    _decoratorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_titleLabel];
    [self addSubview:_textLabel];
    [self addSubview:_decoratorView];
}

- (void)updateConstraints {
    [self removeConstraints:self.constraints];
    [self setupConstraints];
    
    [super updateConstraints];
}

- (void)setupConstraints {
    NSMutableDictionary * views = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   _titleLabel, @"titleLabel",
                                   _textLabel, @"textLabel",
                                   nil];
    
    NSMutableDictionary * metrics = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @(DXRealValue(32.0/3)), @"titleLabelLeftSpace",
                                     @(DXRealValue(29.0/3)), @"textLabelRightSpace",
                                     @(DXRealValue(40.0/3)), @"decoratorViewRightSpace",
                                     nil];
    
    if (_showDecoratorView) {
        [views setObject:_decoratorView forKey:@"decoratorView"];
        [metrics setObject:@(DXRealValue(self.decoratorImage.size.height)) forKey:@"decoratorViewHeight"];
        [metrics setObject:@(DXRealValue(self.decoratorImage.size.width)) forKey:@"decoratorViewWidth"];
    }
    
    
    if (_showDecoratorView) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-titleLabelLeftSpace-[titleLabel]-[textLabel]-textLabelRightSpace-[decoratorView(==decoratorViewWidth)]-decoratorViewRightSpace-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[decoratorView(==decoratorViewHeight)]"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_decoratorView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0 constant:0]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-titleLabelLeftSpace-[titleLabel]-[textLabel]-decoratorViewRightSpace-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_textLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0]];
}

- (void)setDecoratorImage:(UIImage *)decoratorImage {
    BOOL needsUpdateConstraints = NO;
    if (_decoratorImage != decoratorImage) {
        needsUpdateConstraints = YES;
    }
    
    _decoratorImage = decoratorImage;
    [_decoratorView setImage:_decoratorImage];
    
    
    if (decoratorImage) {
        _showDecoratorView = YES;
    } else {
        _showDecoratorView = NO;
    }
    
    if (needsUpdateConstraints) {
        [self setNeedsUpdateConstraints];
    }
}

@end
