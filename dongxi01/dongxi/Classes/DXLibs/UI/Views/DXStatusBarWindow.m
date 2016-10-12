//
//  DXStatusBarWindow.m
//  dongxi
//
//  Created by 穆康 on 15/12/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXStatusBarWindow.h"

@interface DXStatusBarWindow ()

/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;
/** 用于计数的数量 */
@property (nonatomic, assign) NSInteger count;
/** 当前需要显示的数量 */
@property (nonatomic, assign) NSInteger currentCount;

@end

@implementation DXStatusBarWindow

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat radius = 1.0f;
    CGFloat startAngle = 0;
    CGFloat endAngle = M_PI * 2.0f;
    CGFloat margin = 6.0f;
    CGFloat centerX = DXScreenWidth * 0.5f;
    CGFloat centerY = 10.0f;
    CGFloat centerMargin = self.distance * 0.5f;
    
    for (NSInteger i=0; i<self.currentCount; i++) {
        
        CGPoint leftPoint = CGPointMake(centerX - centerMargin - margin * i, centerY);
        CGPoint rightPpint = CGPointMake(centerX + centerMargin + margin * i, centerY);
        
        UIBezierPath *leftPath = [UIBezierPath bezierPathWithArcCenter:leftPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        UIBezierPath *rightPath = [UIBezierPath bezierPathWithArcCenter:rightPpint radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        CGContextAddPath(ctx, leftPath.CGPath);
        CGContextAddPath(ctx, rightPath.CGPath);
    }
    
    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillPath(ctx);
}

- (void)startAnimating {
    
    self.count = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(startLoadingAnimating) userInfo:nil repeats:YES];
}

- (void)startLoadingAnimating {
    
    self.count += 1;
    self.currentCount = self.count % 4;
    [self setNeedsDisplay];
}


- (void)stopAnimating {
    
    self.count = 0;
    [self setNeedsDisplay];
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc {
    
    [self stopAnimating];
}

@end
