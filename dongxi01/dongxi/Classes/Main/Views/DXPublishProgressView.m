//
//  DXPublishProgressView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishProgressView.h"
#import <pop/POP.h>

@implementation DXPublishProgressView {
    CAShapeLayer * progressLayer;
    CAShapeLayer * checkLeftLayer;
    CAShapeLayer * checkRightLayer;
    UILabel * titleLabel;
}

+ (instancetype)progressView {
    DXPublishProgressView * progressView = [[[self class] alloc] initWithFrame:[UIScreen mainScreen].bounds];
    progressView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    progressView.progress = 0;
    [progressView prepareSubviews];
    [progressView prepareSublayers];
    return progressView;
}

- (void)showFromController:(UIViewController *)controller {
    if (!self.superview) {
        UIView * parentView = nil;
        if (controller) {
            if (controller.navigationController) {
                parentView = controller.navigationController.view;
            } else {
                parentView = controller.view;
            }
        } else {
            parentView = [[UIApplication sharedApplication] keyWindow];
        }
        
        if (parentView) {
            [parentView addSubview:self];
        }
    } else {
        [self.superview bringSubviewToFront:self];
    }
}

- (void)prepareSubviews {
    titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = DXRGBColor(64, 189, 206);
    titleLabel.font = [DXFont dxDefaultFontWithSize:15];
    titleLabel.alpha = 0;
    [self addSubview:titleLabel];
}


- (void)prepareSublayers {
    if (!progressLayer) {
        progressLayer = [CAShapeLayer layer];
        progressLayer.fillColor = nil;
        progressLayer.strokeColor = DXRGBColor(109, 197, 255).CGColor;
        progressLayer.lineWidth = DXRealValue(26.0/3);
        progressLayer.lineCap = kCALineCapRound;
        progressLayer.lineJoin = kCALineJoinRound;
        CGPathRef progressPath = [self newProgressPath];
        progressLayer.path = progressPath;
        progressLayer.strokeEnd = self.progress;

        [self.layer addSublayer:progressLayer];
        CGPathRelease(progressPath);
    }
    
    
    if (!checkLeftLayer) {
        checkLeftLayer = [CAShapeLayer layer];
        checkLeftLayer.fillColor = nil;
        checkLeftLayer.strokeColor = DXRGBColor(64, 189, 206).CGColor;
        checkLeftLayer.lineWidth = DXRealValue(26.0/3);
        checkLeftLayer.lineCap = kCALineCapRound;
        checkLeftLayer.lineJoin = kCALineJoinRound;
        CGPathRef checkLeftPath = [self newCheckLeftPath];
        checkLeftLayer.path = checkLeftPath;
        checkLeftLayer.strokeEnd = 0;

        [self.layer addSublayer:checkLeftLayer];
        CGPathRelease(checkLeftPath);
    }
    
    if (!checkRightLayer) {
        checkRightLayer = [CAShapeLayer layer];
        checkRightLayer.fillColor = nil;
        checkRightLayer.strokeColor = DXRGBColor(64, 189, 206).CGColor;
        checkRightLayer.lineWidth = DXRealValue(26.0/3);
        checkRightLayer.lineCap = kCALineCapRound;
        checkRightLayer.lineJoin = kCALineJoinRound;
        CGPathRef checkRightPath = [self newCheckRightPath];
        checkRightLayer.path = checkRightPath;
        checkRightLayer.strokeEnd = 0;
        
        [self.layer addSublayer:checkRightLayer];
        CGPathRelease(checkRightPath);
    }
}


- (CGPathRef)newProgressPath {
    CGFloat pathLength = DXRealValue(375.0/3);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, &transform, -pathLength/2, 0);
    CGPathAddLineToPoint(path, &transform, pathLength/2, 0);
    CGPathRef progressPath = CGPathCreateCopy(path);
    CGPathRelease(path);
    
    return progressPath;
}

- (CGPathRef)newCheckLeftPath {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat leftX = -DXRealValue(50.0/3)*0.707;
    CGFloat leftY = leftX;
    CGPathMoveToPoint(path, &transform, 0, 0);
    CGPathAddLineToPoint(path, &transform, leftX, leftY);
    CGPathRef checkLeftPath = CGPathCreateCopy(path);
    CGPathRelease(path);
    
    return checkLeftPath;
}


- (CGPathRef)newCheckRightPath {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat rightX = DXRealValue(115.0/3)*0.707;
    CGFloat rightY = -rightX;
    CGPathMoveToPoint(path, &transform, 0, 0);
    CGPathAddLineToPoint(path, &transform, rightX, rightY);
    CGPathRef checkRightPath = CGPathCreateCopy(path);
    CGPathRelease(path);

    return checkRightPath;
}


#pragma mark - Animation

- (void)playSuccessAnimation:(void(^)(void))finishBlock {
    progressLayer.strokeStart = 0;

    CFTimeInterval currentTime = CACurrentMediaTime();

    CGFloat goToEndDuration = (1-progressLayer.strokeEnd)*0.4;
    POPBasicAnimation * goToEnd = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    goToEnd.toValue = @1;
    goToEnd.duration = goToEndDuration;
    
    currentTime += goToEndDuration;
    
    CGFloat changeColorDuration = 0.1;
    POPBasicAnimation * changeColor = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeColor];
    changeColor.fromValue = (__bridge id)DXRGBColor(109, 197, 255).CGColor;
    changeColor.toValue = (__bridge id)DXRGBColor(64, 189, 206).CGColor;
    changeColor.beginTime = currentTime;
    changeColor.duration = changeColorDuration;
    
    currentTime += changeColorDuration;
    currentTime += 0.2;
    
    CGFloat endsToMiddleDuration = 0.15;
    POPBasicAnimation * leftToMiddle = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeStart];
    leftToMiddle.fromValue = @0;
    leftToMiddle.toValue = @0.5;
    leftToMiddle.duration = endsToMiddleDuration;
    leftToMiddle.beginTime = currentTime;
    POPBasicAnimation * rightToMidde = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    rightToMidde.fromValue = @1;
    rightToMidde.toValue = @0.5;
    rightToMidde.duration = endsToMiddleDuration;
    rightToMidde.beginTime = currentTime;
    
    currentTime += endsToMiddleDuration;

    [progressLayer pop_addAnimation:goToEnd forKey:@"goToEnd"];
    [progressLayer pop_addAnimation:changeColor forKey:@"changeColor"];
    [progressLayer pop_addAnimation:leftToMiddle forKey:@"leftToMiddle"];
    [progressLayer pop_addAnimation:rightToMidde forKey:@"rightToMiddle"];
    
    CGFloat checkStrokeDuration = 0.2;
    POPBasicAnimation * checkStrokeLeft = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    checkStrokeLeft.fromValue = @0;
    checkStrokeLeft.toValue = @1;
    checkStrokeLeft.duration = checkStrokeDuration;
    checkStrokeLeft.beginTime = currentTime;
    POPBasicAnimation * checkStrokeRight = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    checkStrokeRight.fromValue = @0;
    checkStrokeRight.toValue = @1;
    checkStrokeRight.duration = checkStrokeDuration;
    checkStrokeRight.beginTime = currentTime;
    [checkLeftLayer pop_addAnimation:checkStrokeLeft forKey:@"checkStrokeLeft"];
    [checkRightLayer pop_addAnimation:checkStrokeRight forKey:@"checkStrokeRight"];
    
    
    POPBasicAnimation * titleAlpha = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    titleAlpha.fromValue = @0;
    titleAlpha.toValue = @1;
    titleAlpha.duration = checkStrokeDuration;
    titleAlpha.beginTime = currentTime;
    
    CGPoint viewCenter = self.center;
    POPBasicAnimation * titleMoveIn = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
    titleMoveIn.fromValue = [NSValue valueWithCGPoint:CGPointMake(viewCenter.x+DXRealValue(5), viewCenter.y)];
    titleMoveIn.toValue = [NSValue valueWithCGPoint:CGPointMake(viewCenter.x+DXRealValue(5), viewCenter.y+DXRealValue(18))];
    titleMoveIn.duration = checkStrokeDuration;
    titleMoveIn.beginTime = currentTime;
    
    [titleLabel pop_addAnimation:titleAlpha forKey:@"titleAlpha"];
    [titleLabel pop_addAnimation:titleMoveIn forKey:@"titleMoveIn"];
    
    [checkStrokeRight setCompletionBlock:^(POPAnimation * anim, BOOL finish) {
        if (finishBlock && finish) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                finishBlock();
            });
        }
    }];
}


#pragma mark - Public

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    progressLayer.strokeEnd = progress;
}


- (void)finish:(BOOL)success title:(NSString *)title otherMessage:(NSString *)otherMessage {
    if (self.superview) {
        titleLabel.text = title;
        [titleLabel sizeToFit];
        __weak DXPublishProgressView * weakSelf = self;
        if (success) {
            [self playSuccessAnimation:^{
                [weakSelf removeFromSuperview];
                if (weakSelf.removeBlock) {
                    weakSelf.removeBlock();
                }
            }];
        } else {
            [weakSelf removeFromSuperview];
            if (weakSelf.removeBlock) {
                weakSelf.removeBlock();
            }
        }
    }
}


@end
