//
//  DXFeedCommentCountView.m
//  dongxi
//
//  Created by 穆康 on 16/1/29.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedCommentCountView.h"

@interface DXFeedCommentCountView ()



@end

@implementation DXFeedCommentCountView

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect targetRect = CGRectMake(1, 1, rect.size.width - 2, rect.size.height - 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:targetRect cornerRadius:rect.size.height];
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetStrokeColorWithColor(ctx, DXRGBColor(109, 158, 255).CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.textColor = DXRGBColor(109, 158, 255);
    countLabel.font = [DXFont dxDefaultFontWithSize:9];
    [self addSubview:countLabel];
    self.countLabel = countLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.countLabel.frame = self.bounds;
    self.layer.cornerRadius = self.height * 0.5;
    self.layer.masksToBounds = YES;
}


@end
