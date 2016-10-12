//
//  DXPublishWatermarkCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/15.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishWatermarkCell.h"

@implementation DXPublishWatermarkCell {
    UIImageView * _selectedBorderView;
    UIImageView * _topicMarkView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;

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
    
    _topicMarkView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _topicMarkView.image = [UIImage imageNamed:@"watermark_topic"];
    _topicMarkView.translatesAutoresizingMaskIntoConstraints = NO;
    _topicMarkView.hidden = !self.showTopicMark;
    
    [self addSubview:_selectedBorderView];
    [self addSubview:_previewImageView];
    [self addSubview:_topicMarkView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.previewImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.previewImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
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
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topicMarkView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.previewImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topicMarkView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.previewImageView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topicMarkView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:DXRealValue(1)
                                                      constant:_topicMarkView.image.size.height]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_topicMarkView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:DXRealValue(1)
                                                      constant:_topicMarkView.image.size.width]];
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        _selectedBorderView.hidden = NO;
    } else {
        _selectedBorderView.hidden = YES;
    }
}


- (void)setShowTopicMark:(BOOL)showTopicMark {
    _showTopicMark = showTopicMark;
    
    _topicMarkView.hidden = !showTopicMark;
}

@end
