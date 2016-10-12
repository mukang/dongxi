//
//  DXTopTopicItemView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopTopicItemView.h"

@interface DXTopTopicItemView ()

@property (nonatomic, strong) UIImageView *topTypeView;

@end

@implementation DXTopTopicItemView {
    UIView * backgroundImageMaskView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.backgroundImageView.backgroundColor = [UIColor blackColor];
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        backgroundImageMaskView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundImageMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
        backgroundImageMaskView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.topTypeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"discover_top_topicLabel_border"]];
        self.topTypeView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.topTypeLabel = [[UILabel alloc] init];
        self.topTypeLabel.text = @"推荐话题";
        self.topTypeLabel.textColor = [UIColor whiteColor];
        self.topTypeLabel.font = [DXFont fontWithName:DXCommonFontName size:13];
        self.topTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.topicLabel = [[UILabel alloc] init];
        self.topicLabel.text = @"";
        self.topicLabel.font = [DXFont fontWithName:DXCommonFontName size:17.0f];
        self.topicLabel.textColor = [UIColor whiteColor];
        self.topicLabel.textAlignment = NSTextAlignmentCenter;
        self.topicLabel.numberOfLines = 1;
        [self.topicLabel sizeToFit];
        self.topicLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.subTitleLabel = [[UILabel alloc] init];
        self.subTitleLabel.text = @"";
        self.subTitleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
        self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subTitleLabel.font = [DXFont fontWithName:DXCommonFontName size:40/3.0];
        self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.backgroundImageView];
        [self addSubview:backgroundImageMaskView];
        [self addSubview:self.topTypeView];
        [self addSubview:self.topTypeLabel];
        [self addSubview:self.topicLabel];
        [self addSubview:self.subTitleLabel];
        
        NSDictionary * views = @{
                                 @"backgroundImageView"         : self.backgroundImageView,
                                 @"backgroundImageMaskView"     : backgroundImageMaskView,
                                 @"topicLabel"                  : self.topicLabel,
                                 @"subTitleLabel"               : self.subTitleLabel
                                 };
        NSDictionary * metrics = @{
                                   @"topicLabelTopMargin"       : @(DXRealValue(305/3.0)),
                                   @"topicLabelHeight"          : @17,
                                   @"subTitleLabelTopMargin"    : @(DXRealValue(374/3.0)),
                                   @"subTitleLabelMargin"       : @(DXRealValue(20)),
                                   @"subTitleLabelHeight"       : @14,
                                   };
        NSArray * visualFormats = @[
                                    @"H:|[backgroundImageView]|",
                                    @"H:|[backgroundImageMaskView]|",
                                    @"H:|[topicLabel]|",
                                    @"H:|-subTitleLabelMargin-[subTitleLabel]-subTitleLabelMargin-|",
                                    @"V:|[backgroundImageView]|",
                                    @"V:|[backgroundImageMaskView]|",
                                    @"V:|-topicLabelTopMargin-[topicLabel(==topicLabelHeight)]",
                                    @"V:|-subTitleLabelTopMargin-[subTitleLabel(==subTitleLabelHeight)]"
                                    ];
        for (NSString * vf in visualFormats) {
            NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views];
            [self addConstraints:constraints];
        }
        
        NSLayoutConstraint *constraint;
        constraint = [NSLayoutConstraint constraintWithItem:self.topTypeView
                                                  attribute:NSLayoutAttributeCenterX
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeCenterX
                                                 multiplier:1
                                                   constant:0];
        [self addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.topTypeView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1
                                                   constant:DXRealValue(67)];
        [self addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.topTypeView
                                                  attribute:NSLayoutAttributeWidth
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:0
                                                 multiplier:1
                                                   constant:196/3.0];
        [self addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.topTypeView
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:0
                                                 multiplier:1
                                                   constant:20];
        [self addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.topTypeLabel
                                                  attribute:NSLayoutAttributeCenterX
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.topTypeView
                                                  attribute:NSLayoutAttributeCenterX
                                                 multiplier:1
                                                   constant:0];
        [self addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.topTypeLabel
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.topTypeView
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1
                                                   constant:0];
        [self addConstraint:constraint];
    }
    return self;
}

- (IBAction)tapped:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapTopicItemView:)]) {
            [self.delegate userDidTapTopicItemView:self];
        }
    }
}

@end
