//
//  DXTableView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTableView.h"

@implementation DXTableView {
    UITapGestureRecognizer * _tapGesture;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    NSSet * touches = [event touchesForView:self];
    if (point.y < 0 && touches.count < 2) {
        if (self.touchEventDelegate && [self.touchEventDelegate respondsToSelector:@selector(shouldTableView:respondToEvent:atPoint:)]) {
            CGPoint pointInDelegateView = [self convertPoint:point toView:self.touchEventDelegate];
            if (![self.touchEventDelegate shouldTableView:self respondToEvent:event atPoint:pointInDelegateView]) {
                return NO;
            }
        }
    }
    BOOL isInside = [super pointInside:point withEvent:event];
    return isInside;
}


- (void)setContentSize:(CGSize)contentSize {
    if (contentSize.height < self.minContentSize.height) {
        contentSize.height = self.minContentSize.height;
    }
    if (contentSize.width < self.minContentSize.width) {
        contentSize.width = self.minContentSize.width;
    }
    [super setContentSize:contentSize];
}

@end
