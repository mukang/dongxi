//
//  UIViewController+DXDataMessageLabel.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/23.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "UIViewController+DXDataMessageLabel.h"
#import <objc/runtime.h>

@implementation UIViewController (DXDataMessageLabel)

- (void)setEnableDataMessageLabel:(BOOL)enableDataMessageLabel {
    objc_setAssociatedObject(self, @selector(enableDataMessageLabel), @(enableDataMessageLabel), OBJC_ASSOCIATION_COPY);
    if (enableDataMessageLabel) {
        [self setupDataMessageLabelIfNeeded];
    } else {
        if (self.dataMessageLabel) {
            self.dataMessageLabel.hidden = YES;
        }
    }
}

- (BOOL)enableDataMessageLabel {
    return [objc_getAssociatedObject(self, @selector(enableDataMessageLabel)) boolValue];
}

- (void)setDataMessageLabel:(UILabel *)dataMessageLabel {
    objc_setAssociatedObject(self, @selector(dataMessageLabel), dataMessageLabel, OBJC_ASSOCIATION_ASSIGN);
}

- (UILabel *)dataMessageLabel {
    return objc_getAssociatedObject(self, @selector(dataMessageLabel));
}

- (void)setDataMessageLabelTopMargin:(CGFloat)dataMessageLabelTopMargin {
    objc_setAssociatedObject(self, @selector(dataMessageLabelTopMargin), @(dataMessageLabelTopMargin), OBJC_ASSOCIATION_COPY);
}

- (CGFloat)dataMessageLabelTopMargin {
    NSNumber * topMargin = objc_getAssociatedObject(self, @selector(dataMessageLabelTopMargin));
    if (topMargin) {
        return [topMargin floatValue];
    } else {
        return DXRealValue(100);
    }
}


- (void)setupDataMessageLabelIfNeeded {
    if (![self dataMessageLabel]) {
        DXMutiLineLabel * dataMessageLabel = [[DXMutiLineLabel alloc] init];
        dataMessageLabel.hidden = YES;
        dataMessageLabel.textColor = DXRGBColor(177, 177, 177);
        dataMessageLabel.font = [DXFont dxDefaultFontWithSize:15];
        dataMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:dataMessageLabel];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:dataMessageLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0 constant:self.dataMessageLabelTopMargin]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:dataMessageLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:dataMessageLabel
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.5 constant:0]];
        
        self.dataMessageLabel = dataMessageLabel;
    }
}

- (void)showDataMessageLabel:(BOOL)show message:(NSString *)message {
    if (self.enableDataMessageLabel) {
        self.dataMessageLabel.hidden = !show;
        self.dataMessageLabel.text = message;
    }
}



@end
