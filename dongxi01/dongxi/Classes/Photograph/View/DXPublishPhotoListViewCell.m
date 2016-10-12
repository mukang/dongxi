//
//  DXPublishPhotoListViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishPhotoListViewCell.h"

@implementation DXPublishPhotoListViewCell {
    NSMutableArray * _photoListViewConstraints;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.frame = self.bounds;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)setPhotoListView:(UIView *)photoListView {
    if (_photoListView && [_photoListView superview]) {
        [_photoListView removeFromSuperview];
    }
    
    if (_photoListViewConstraints) {
        [self removeConstraints:_photoListViewConstraints];
    }
    
    _photoListView = photoListView;
    [self.contentView addSubview:photoListView];
    
    if (!_photoListViewConstraints) {
        _photoListViewConstraints = [NSMutableArray array];
    }
    [_photoListViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_photoListView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:0]];
    [_photoListViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_photoListView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:0]];
    [_photoListViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_photoListView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1
                                                                       constant:0]];
    [_photoListViewConstraints addObject:[NSLayoutConstraint constraintWithItem:_photoListView
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeTrailing
                                                                     multiplier:1
                                                                       constant:0]];
    [self addConstraints:_photoListViewConstraints];
    
    [self setNeedsUpdateConstraints];
}

@end
