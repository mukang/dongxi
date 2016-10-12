//
//  DXPhotoFilterIntensityBar.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPhotoFilterIntensityBar.h"

@implementation DXPhotoFilterIntensityBar {
    CGSize barSize;
    UIImageView * _buttonView;
    UIImageView * _barView;
    UILabel * _valueLabel;
    CGPoint _startPoint;
    CGFloat _value;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _minValue = -1;
        _maxValue = 1;
        _initialValue = 0;
        _value = 0;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    UIImage * barImage = [UIImage imageNamed:@"bg_photo_regulate"];
    barSize = CGSizeMake(DXRealValue(barImage.size.width), DXRealValue(barImage.size.height));
    frame.size.width = barSize.width;
    
    self = [super initWithFrame:frame];
    if (self) {
        UILabel * intensityLabel = [[UILabel alloc] init];
        intensityLabel.text = @"0";
        intensityLabel.font = [DXFont dxDefaultFontWithSize:55.0/3];
        intensityLabel.textColor = DXRGBColor(177, 177, 177);
        intensityLabel.textAlignment = NSTextAlignmentCenter;
        [intensityLabel sizeToFit];
        CGRect labelFrame = intensityLabel.frame;
        labelFrame.size.width = barSize.width;
        intensityLabel.frame = labelFrame;
        [self addSubview:intensityLabel];
        _valueLabel = intensityLabel;
        
        
        UIImageView * barImageView = [[UIImageView alloc] initWithImage:barImage];
        CGRect barFrame;
        barFrame.origin.x = self.bounds.size.width/2 - barSize.width/2;
        barFrame.origin.y = labelFrame.size.height + DXRealValue(12);
        barFrame.size = barSize;
        barImageView.frame = barFrame;
        [self addSubview:barImageView];
        _barView = barImageView;
        
        UIImage * buttonImage = [UIImage imageNamed:@"button_photo_regulate"];
        UIImageView * buttonImageView = [[UIImageView alloc] initWithImage:buttonImage];
        CGSize buttonSize = CGSizeMake(DXRealValue(buttonImage.size.width), DXRealValue(buttonImage.size.height));
        CGRect buttonFrame;
        buttonFrame.origin.y = barFrame.origin.y + DXRealValue(10);
        buttonFrame.origin.x = barSize.width/2 - buttonSize.width/2;
        buttonFrame.size = buttonSize;
        buttonImageView.frame = buttonFrame;
        [self addSubview:buttonImageView];
        _buttonView = buttonImageView;
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(DXRealValue(309), _valueLabel.frame.size.height + DXRealValue(12) + _barView.frame.size.height + DXRealValue(10));
}

- (void)revert {
    _buttonView.transform = CGAffineTransformIdentity;
    _valueLabel.text = @"0";
}

- (void)moveButtonToPoint:(CGPoint)point {
    NSInteger valueRange = self.maxValue - self.minValue;
    NSAssert(valueRange != 0, @"最大值与最小值之差不可为0");
    
    const CGFloat length = DXRealValue(242); //图片中可调节范围的尺寸（pt)
    CGFloat valuePerPt = valueRange / length;
    CGFloat initialPt = (self.initialValue - self.minValue) / valuePerPt + (_barView.bounds.size.width - length) * 0.5;
    CGFloat dx = point.x - initialPt;
    CGFloat value = roundf(valuePerPt * dx);
    
    if (value > self.maxValue) {
        value = self.maxValue;
    } else if (value < self.minValue) {
        value = self.minValue;
    }
    
    if (ABS(value - self.value) < FLT_EPSILON) {
        return;
    }
    
    [self setValue:value];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(intensityBar:didChangeValue:)]) {
        [self.delegate intensityBar:self didChangeValue:value];
    }
}

- (CGFloat)value {
    return _value;
}

- (void)setInitialValue:(CGFloat)initialValue {
    if (initialValue > self.maxValue) {
        initialValue = self.maxValue;
    } else if (initialValue < self.minValue) {
        initialValue = self.minValue;
    }
    
    _initialValue = initialValue;
    
    [self setValue:initialValue];
}

- (void)setValue:(CGFloat)value {
    if (value > self.maxValue) {
        value = self.maxValue;
    } else if (value < self.minValue) {
        value = self.minValue;
    }
    
    _value = value;
    
    NSInteger valueRange = self.maxValue - self.minValue;
    const CGFloat length = DXRealValue(242); //图片中可调节范围的尺寸（pt)
    CGFloat valuePerPt = valueRange / length;
    if (ABS(value) < FLT_EPSILON) {
        value = 0;
    }
    CGFloat dx = (value - (self.maxValue + self.minValue)*0.5) / valuePerPt;
    _valueLabel.text = [NSString stringWithFormat:@"%.0f", value];
    _buttonView.transform = CGAffineTransformMakeTranslation(dx, 0);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _startPoint = point;
    
    [self moveButtonToPoint:_startPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self moveButtonToPoint:point];
}

@end
