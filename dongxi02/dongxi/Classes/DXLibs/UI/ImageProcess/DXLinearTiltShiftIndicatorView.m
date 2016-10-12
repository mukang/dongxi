//
//  DXLinearTiltShiftIndicatorView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLinearTiltShiftIndicatorView.h"

@implementation DXLinearTiltShiftIndicatorView {
    BOOL isBoundsChanged;
    UIView * topLine;
    UIView * middleLine;
    UIView * bottomLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    isBoundsChanged = YES;
    
    [self updateSubviews];
}


- (void)setDistance:(CGFloat)distance {
    _distance = distance;
    
    [self updateSubviews];
}

- (void)setMiddleLineY:(CGFloat)middleLineY {
    _middleLineY = middleLineY;
    
    [self updateSubviews];
}

- (void)setupSubviews {
    topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    middleLine = [[UIView alloc] init];
    middleLine.backgroundColor = [UIColor whiteColor];
    
    bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];

    [self addSubview:topLine];
    [self addSubview:middleLine];
    [self addSubview:bottomLine];
}

- (void)updateSubviews {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat topLineWidth = width - DXRealValue(191.0/3)*2;
    CGFloat middleLineWidth = width - DXRealValue(72.0/3)*2;
    CGFloat bottomLineWidth = topLineWidth;
    
    if (isBoundsChanged) {
        topLine.bounds = CGRectMake(0, 0, topLineWidth, DXRealValue(3));
        middleLine.bounds = CGRectMake(0, 0, middleLineWidth, DXRealValue(2));
        bottomLine.bounds = CGRectMake(0, 0, bottomLineWidth, DXRealValue(3));
        isBoundsChanged = NO;
    }
    
    topLine.center = CGPointMake(width/2, (self.middleLineY + self.distance) * height);
    middleLine.center = CGPointMake(width/2, self.middleLineY * height);
    bottomLine.center = CGPointMake(width/2, (self.middleLineY - self.distance) * height);
}

@end
