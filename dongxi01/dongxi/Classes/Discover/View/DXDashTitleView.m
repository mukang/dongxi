//
//  DXDashTitleView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDashTitleView.h"

@implementation DXDashTitleView {
    UIView * leftDashView;
    UIView * rightDashView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.numberOfLines = 1;
        self.textLabel.textColor = DXRGBColor(143, 143, 143);
        self.textLabel.font = [DXFont fontWithName:DXCommonFontName size:13.0f];
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        leftDashView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        leftDashView.backgroundColor = DXRGBColor(132, 132, 132);
        leftDashView.translatesAutoresizingMaskIntoConstraints = NO;
        
        rightDashView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        rightDashView.backgroundColor = DXRGBColor(132, 132, 132);
        rightDashView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.textLabel];
        [self addSubview:leftDashView];
        [self addSubview:rightDashView];
        
        NSDictionary * views = @{
                                 @"textLabel" : self.textLabel,
                                 @"leftDashView" : leftDashView,
                                 @"rightDashView" : rightDashView
                                 };
        
        NSString * visualFormat = nil;
        NSArray * constraints = nil;
        
        visualFormat = @"H:|-66-[leftDashView(==rightDashView)]-10-[textLabel]-10-[rightDashView]-66-|";
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        
        visualFormat = @"V:[textLabel]";
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        
        visualFormat = @"V:[leftDashView(==0.5)]";
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        
        visualFormat = @"V:[rightDashView(==0.5)]";
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        
        NSLayoutConstraint *centerYContraint = [NSLayoutConstraint constraintWithItem:self.textLabel
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:1
                                                                             constant:0];
        [self addConstraint:centerYContraint];
        
        centerYContraint = [NSLayoutConstraint constraintWithItem:leftDashView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1
                                                         constant:0];
        [self addConstraint:centerYContraint];
        
        centerYContraint = [NSLayoutConstraint constraintWithItem:rightDashView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1
                                                         constant:0];
        [self addConstraint:centerYContraint];
    }
    return self;
}

@end
