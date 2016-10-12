//
//  DXButton.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXExtendButton.h"

@implementation DXExtendButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets slop = self.hitTestSlop;
    if (UIEdgeInsetsEqualToEdgeInsets(slop, UIEdgeInsetsZero)) {
        return [super pointInside:point withEvent:event];
    } else {
        BOOL isInside = CGRectContainsPoint(UIEdgeInsetsInsetRect(self.bounds, slop), point);
        return isInside;
    }
}
@end
