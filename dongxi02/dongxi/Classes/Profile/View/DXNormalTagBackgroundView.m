//
//  DXNormalTagBackgroundView.m
//  dongxi
//
//  Created by 穆康 on 16/1/29.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNormalTagBackgroundView.h"

// 标签的颜色
#define TagColor(s)         [UIColor colorWithRed:109/255.0*(s) green:197/255.0*(s) blue:255/255.0*(s) alpha:1.0]

@implementation DXNormalTagBackgroundView

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect targetRect = CGRectMake(1, 1, rect.size.width - 2, rect.size.height - 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:targetRect cornerRadius:(targetRect.size.height-2)/3.0];
    CGFloat lengths[] = {3, 3};
    CGContextSetLineDash(ctx, 0, lengths, 2);
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, DXRGBColor(109, 197, 255).CGColor);
    CGContextAddPath(ctx, path.CGPath);
    CGContextStrokePath(ctx);
}

@end
