//
//  DXCameraCaptureButton.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCameraCaptureButton.h"
#import <pop/POP.h>
#import <QuartzCore/QuartzCore.h>

@implementation DXCameraCaptureButton {
    BOOL isConstraintsSet;
    
    CGFloat buttonScale;
    
    UIImageView * background;
    UIImageView * button;
    UIImageView * buttonBackgound;
    UIImageView * buttonRing;
    
    CGSize originBackgroundSize;
    CGSize originButtonSize;
    CGSize originButtonBackgoundSize;
    CGSize originButtonRingSize;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        isConstraintsSet = NO;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_take_photo_bg"]];
    background.translatesAutoresizingMaskIntoConstraints = NO;
    buttonBackgound = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_take_photo_flash"]];
    buttonBackgound.translatesAutoresizingMaskIntoConstraints = NO;
    button = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_take_photo_center"]];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    buttonRing = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_take_photo_ring"]];
    buttonRing.translatesAutoresizingMaskIntoConstraints = NO;
    
    originBackgroundSize = background.bounds.size;
    originButtonBackgoundSize = buttonBackgound.bounds.size;
    originButtonSize = button.bounds.size;
    originButtonRingSize = buttonRing.bounds.size;

    [self addSubview:background];
    [self addSubview:buttonBackgound];
    [self addSubview:button];
    [self addSubview:buttonRing];
    
    if (CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(DXRealValue(originBackgroundSize.width), DXRealValue(originBackgroundSize.height));
        [self setFrame:frame];
    }
    
    buttonScale = 1;

    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints {
    [self removeConstraints:self.constraints];
    
    CGFloat backgroundWidth = DXRealValue(originBackgroundSize.width) * buttonScale;
    CGFloat backgroundHeight = DXRealValue(originBackgroundSize.height) * buttonScale;
    CGFloat buttonWidth = DXRealValue(originButtonSize.width) * buttonScale;
    CGFloat buttonHeight = DXRealValue(originButtonSize.height) * buttonScale;
    CGFloat buttonRingWidth = DXRealValue(originButtonRingSize.width) * buttonScale;
    CGFloat buttonRingHeight = DXRealValue(originButtonRingSize.height) * buttonScale;
    
    /* background */
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:background
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:background
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:background
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:backgroundWidth]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:background
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:backgroundHeight]];
    
    /* button background */
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonBackgound
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonBackgound
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonBackgound
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:buttonWidth]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonBackgound
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:buttonHeight]];
    
    /* button */
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:buttonWidth]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:buttonHeight]];
    
    /* button ring */
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonRing
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonRing
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonRing
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:buttonRingWidth]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonRing
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:buttonRingHeight]];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    CGFloat imageLength = DXRealValue(originBackgroundSize.width);
    CGFloat viewLength = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGFloat buttonLength = imageLength > viewLength ? viewLength : imageLength;
    buttonScale = buttonLength / imageLength;

    isConstraintsSet = NO;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (!isConstraintsSet) {
        [self setupConstraints];
        isConstraintsSet = YES;
    }
    
    [super updateConstraints];
}

- (void)touchUpAnimation {
    POPBasicAnimation * fadeIn = [button pop_animationForKey:@"DXCameraCaptureButton.capture.fadeIn"];
    
    if (!fadeIn) {
        fadeIn = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fadeIn.duration = 0.4;
        fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        fadeIn.fromValue = @0.0;
        fadeIn.toValue = @1.0;
        [button pop_addAnimation:fadeIn forKey:@"DXCameraCaptureButton.capture.fadeIn"];
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    POPBasicAnimation * fadeOut = [button pop_animationForKey:@"DXCameraCaptureButton.capture.fadeOut"];
    if (!fadeOut) {
        fadeOut = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fadeOut.duration = 0.4;
        fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        fadeOut.fromValue = @1.0;
        fadeOut.toValue = @0.0;
        [button pop_addAnimation:fadeOut forKey:@"DXCameraCaptureButton.capture.fadeOut"];
    }
    
    POPBasicAnimation * rotate = [buttonRing.layer pop_animationForKey:@"DXCameraCaptureButton.capture.rotate"];
    if (!rotate) {
        rotate = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
        rotate.fromValue = @0;
        rotate.toValue = @(M_PI_2);
        rotate.duration = 0.8;
        rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [buttonRing.layer pop_addAnimation:rotate forKey:@"DXCameraCaptureButton.capture.rotate"];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [self touchUpAnimation];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [self touchUpAnimation];
}

@end
