//
//  DXRadialTiltShiftIndicatorView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/14.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRadialTiltShiftIndicatorView.h"
#import <pop/POP.h>

@interface DXRadialTiltShiftIndicatorView ()

@property (nonatomic) CGFloat realRadius;
@property (nonatomic) CGPoint realCircleCenter;
@property (nonatomic) POPAnimatableProperty * radiusProperty;
@property (nonatomic) POPBasicAnimation * radiusAnimation;

@end

@implementation DXRadialTiltShiftIndicatorView {
    CAShapeLayer * circleLayer;
    CAShapeLayer * dotLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSublayers];
    }
    return self;
}

- (void)setupSublayers {
    circleLayer = [CAShapeLayer layer];
    circleLayer.strokeColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    circleLayer.fillColor = nil;
    circleLayer.lineWidth = 2;
    [self.layer addSublayer:circleLayer];
    
    UIBezierPath * circlePath = [UIBezierPath bezierPathWithArcCenter:self.realCircleCenter radius:self.realRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    circleLayer.path = circlePath.CGPath;

    dotLayer = [CAShapeLayer layer];
    dotLayer.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:dotLayer];

    UIBezierPath * dotPath = [UIBezierPath bezierPathWithArcCenter:self.realCircleCenter radius:DXRealValue(12) startAngle:0 endAngle:M_PI*2 clockwise:YES];
    dotLayer.path = dotPath.CGPath;
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;

    self.realRadius = MIN(self.bounds.size.width, self.bounds.size.height) * self.radius;
    
    [self updateCircleLayer];
    [self updateDotLayer];
}

- (void)setCirlceCenter:(CGPoint)cirlceCenter {
    _cirlceCenter = cirlceCenter;
    
    self.realCircleCenter = CGPointMake(self.bounds.size.width * self.cirlceCenter.x,
                                        self.bounds.size.height * self.cirlceCenter.y);
    [self updateCircleLayer];
    [self updateDotLayer];
}


- (void)updateCircleLayer {
    UIBezierPath * circlePath = [UIBezierPath bezierPathWithArcCenter:self.realCircleCenter radius:self.realRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    circleLayer.path = circlePath.CGPath;
}

- (void)updateDotLayer {
    UIBezierPath * dotPath = [UIBezierPath bezierPathWithArcCenter:self.realCircleCenter radius:DXRealValue(12) startAngle:0 endAngle:M_PI*2 clockwise:YES];
    dotLayer.path = dotPath.CGPath;
}

@end
