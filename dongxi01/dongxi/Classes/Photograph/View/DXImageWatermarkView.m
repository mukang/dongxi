//
//  DXImageWatermarkView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/15.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXImageWatermarkView.h"
#import "DXExtendButton.h"

@interface DXImageWatermarkView ()

@property (nonatomic) UIImageView * imageView;
@property (nonatomic) DXExtendButton * button;
@property (nonatomic) CAShapeLayer * border;

@property (nonatomic) UIPanGestureRecognizer * panGesture;
@property (nonatomic) UIPanGestureRecognizer * rotatePanGesture;

@end


@implementation DXImageWatermarkView

#pragma mark - Methods

- (instancetype)initWithImage:(UIImage *)image {
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self = [self initWithFrame:frame];
    if (self) {
        _image = image;
    }
    return self;
}

- (void)resetRotation {
    CGAffineTransform transform = self.transform;
    CGFloat angle = atan2f(transform.b, transform.a);
    CGFloat invertAngle = -angle;
    CGAffineTransform invertTransform = CGAffineTransformRotate(transform, invertAngle);
    self.transform = invertTransform;
}

- (CGFloat)rotation {
    return [self transformRotationOfView:self];
}

#pragma mark - Property

- (void)setImage:(UIImage *)image {
    _image = image;
    
    self.transform = CGAffineTransformIdentity;
    
    _imageView.image = image;
    CGRect bounds = self.bounds;
    bounds.size = image.size;
    self.bounds = bounds;
}

- (void)setHideBorderAndButton:(BOOL)hideBorderAndButton {
    _hideBorderAndButton = hideBorderAndButton;
    self.border.hidden = hideBorderAndButton;
    self.button.layer.hidden = hideBorderAndButton;
}

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (_image) {
            _imageView = [[UIImageView alloc] initWithImage:_image];
        } else {
            _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        }
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
        
        _border = [CAShapeLayer layer];
        _border.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:1].CGColor;
        _border.fillColor = nil;
        _border.lineDashPattern = @[@2, @2];
        [self.layer addSublayer:_border];
        
        UIImage * buttonImage = [UIImage imageNamed:@"Watermark_Control"];
        CGFloat buttonWidth = roundf(DXRealValue(buttonImage.size.width));
        CGFloat buttonHeight = roundf(DXRealValue(buttonImage.size.height));
        _button = [[DXExtendButton alloc] init];
        _button.bounds = CGRectMake(0, 0, buttonWidth, buttonHeight);
        _button.center = CGPointMake(-2.5, -2.5);
        _button.hitTestSlop = UIEdgeInsetsMake(-5, -5, -5, -5);
        [_button setImage:buttonImage forState:UIControlStateNormal];
        [self addSubview:_button];
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        [self addGestureRecognizer:_panGesture];
        
        _rotatePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePanGestureHandler:)];
        [_button addGestureRecognizer:_rotatePanGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _border.path = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds, -5, -5)].CGPath;
    _border.frame = self.bounds;
}

#pragma mark - Action

- (void)panGestureHandler:(UIPanGestureRecognizer *)gesture {
    static CGPoint startCenter;
    CGPoint translation = [gesture translationInView:self.superview];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            startCenter = self.center;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint center = CGPointMake(translation.x+startCenter.x, translation.y+startCenter.y);
            CGRect movedFrame = [self frameOfView:self afterSetCenter:center];
            if (CGRectContainsRect(self.superview.bounds, movedFrame)) {
                self.center = center;
                break;
            }
            
            center = CGPointMake(self.center.x, translation.y+startCenter.y);
            movedFrame = [self frameOfView:self afterSetCenter:center];
            if (CGRectContainsRect(self.superview.bounds, movedFrame)) {
                self.center = center;
                break;
            }

            center = CGPointMake(translation.x+startCenter.x, self.center.y);
            movedFrame = [self frameOfView:self afterSetCenter:center];
            if (CGRectContainsRect(self.superview.bounds, movedFrame)) {
                self.center = center;
                break;
            }
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            break;
        }
        default:
            break;
    }
}

- (void)rotatePanGestureHandler:(UIPanGestureRecognizer *)gesture {
    static CGFloat startDistance = 0;
    static CGFloat startScale = 1;
    static CGPoint startLocation;
    static CGAffineTransform startTransform;
    static CGFloat minScale = 0.5;
    static CGFloat maxScale = 1;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint location = [gesture locationInView:self.superview];
            CGPoint center = self.center;
            startDistance = sqrtf((location.x-center.x)*(location.x-center.x) + (location.y-center.y)*(location.y-center.y));
            startScale = [self transformScaleXOfView:self];
            startLocation = location;
            startTransform = self.transform;
            minScale = self.minScale / self.initialScale;
            maxScale = self.maxScale / self.initialScale;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [gesture locationInView:self.superview];
            CGPoint center = self.center;
            CGFloat currentDistance = sqrtf((location.x-center.x)*(location.x-center.x) + (location.y-center.y)*(location.y-center.y));
            
            CGFloat deltaScale = currentDistance/startDistance;
            CGFloat scale = deltaScale * startScale;
            scale = roundf(scale * 10) / 10.0;
            if (scale < minScale) {
                deltaScale = minScale/startScale;
            } else if (scale > maxScale) {
                deltaScale = maxScale/startScale;
            }
            
            CGAffineTransform scaleTranform = CGAffineTransformScale(startTransform, deltaScale, deltaScale);            
            CGFloat angle = [self angleStartFromPointA:startLocation toPointB:location joint:center clockwise:YES];
            CGAffineTransform rotateAndScaleTransform = CGAffineTransformRotate(scaleTranform, angle);

            CGRect frame = [self frameOfView:self afterSetAffineTranform:rotateAndScaleTransform];
            if (CGRectContainsRect(self.superview.bounds, frame)) {
                self.transform = rotateAndScaleTransform;
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            break;
        }
        default:
            break;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint pointInButon = [self convertPoint:point toView:self.button];
    UIView * hitView = [self.button hitTest:pointInButon withEvent:event];
    if (hitView) {
        return hitView;
    } else {
        return [super hitTest:point withEvent:event];
    }
}


#pragma mark - frame calculate

//TODO: 以下方法最好整理到独立的类中。暂时放在这里。

- (CGRect)frameOfView:(UIView *)view afterSetCenter:(CGPoint)center {
    CGPoint originCenter = view.center;
    view.center = center;
    CGRect frame = view.frame;
    view.center = originCenter;
    return frame;
}

- (CGRect)frameOfView:(UIView *)view afterSetAffineTranform:(CGAffineTransform)transform {
    CGAffineTransform originTranform = view.transform;
    view.transform = transform;
    CGRect frame = view.frame;
    view.transform = originTranform;
    return frame;
}

- (CGFloat)distanceFromPointA:(CGPoint)pointA toPointB:(CGPoint)pointB {
    return sqrtf((pointA.x-pointB.x)*(pointA.x-pointB.x) + (pointA.y-pointB.y)*(pointA.y-pointB.y));
}

- (CGFloat)angleStartFromPointA:(CGPoint)pointA toPointB:(CGPoint)pointB joint:(CGPoint)joint clockwise:(BOOL)isClockWise {
    CGFloat angleA = atan2f(pointA.y - joint.y, pointA.x - joint.x);
    CGFloat angleB = atan2f(pointB.y - joint.y, pointB.x - joint.x);
    return isClockWise ? (angleB - angleA) : (angleA - angleB);
}

- (CGSize)tranformSizeOfView:(UIView *)view afterSetAffineTranform:(CGAffineTransform)transform {
    CGAffineTransform originTransform = view.transform;
    view.transform = transform;
    CGSize size = [self transformSizeOfView:view];
    view.transform = originTransform;
    return size;
}

- (CGFloat)transformScaleXOfView:(UIView *)view {
    CGAffineTransform transform = view.transform;
    return sqrtf(transform.a * transform.a + transform.c * transform.c);
}

- (CGFloat)transformScaleYOfView:(UIView *)view {
    CGAffineTransform transform = view.transform;
    return sqrtf(transform.b * transform.b + transform.d * transform.d);
}

- (CGFloat)transformRotationOfView:(UIView *)view {
    CGAffineTransform transform = view.transform;
    CGFloat angle = atan2f(transform.b, transform.a);
    return angle;
}

- (CGSize)transformSizeOfView:(UIView *)view {
    CGAffineTransform originTransform = view.transform;
    CGFloat angle = [self transformRotationOfView:view];
    CGFloat invertAngle = -angle;
    CGAffineTransform invertTransform = CGAffineTransformRotate(originTransform, invertAngle);
    view.transform = invertTransform;
    CGSize size = view.frame.size;
    view.transform = originTransform;
    return size;
}

@end
