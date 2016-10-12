//
//  DXScreenNotice.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXScreenNotice.h"

NSString * const DXScreenNoticeDidShowNotification      = @"DXScreenNoticeDidShowNotification";
NSString * const DXScreenNoticeDidDismissNotification   = @"DXScreenNoticeDidDismissNotification";

typedef void(^DXScreenNoticeDismissCompletionBlock)(void);

@implementation DXScreenNotice {
    __weak UIViewController * sourceController;
    UIImageView * roundBorderView;
    UILabel * messageLabel;
    BOOL isConstraintsSet;
    NSNotificationCenter * notiCenter;
    UITapGestureRecognizer * tapGesture;
    DXScreenNoticeDismissCompletionBlock tapToDismissCompletion;
}

- (instancetype)initWithMessage:(NSString *)message fromController:(UIViewController *)controller {
    self = [[[self class] alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        sourceController = controller;
        notiCenter = [NSNotificationCenter defaultCenter];
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.enabled = NO;
        [self addGestureRecognizer:tapGesture];

        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        roundBorderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"layer_black_notice"]];
        roundBorderView.translatesAutoresizingMaskIntoConstraints = NO;
        messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        messageLabel.text = message;
        messageLabel.font = [DXFont dxDefaultFontWithSize:15.0];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:roundBorderView];
        [self addSubview:messageLabel];

        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    if (!isConstraintsSet) {
        [self setupConstraints];
        isConstraintsSet = YES;
    }
    
    [super updateConstraints];
}

- (void)setupConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:messageLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:messageLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:messageLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.8
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:roundBorderView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:messageLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:roundBorderView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:messageLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:roundBorderView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                        toItem:messageLabel
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:40]];
    
    
}

- (void)show {
    if (sourceController) {
        UIView * view;
        if (sourceController.navigationController) {
            view = sourceController.navigationController.view;
        } else {
            view = sourceController.view;
        }

        [view addSubview:self];
        [view bringSubviewToFront:self];
        [self setNeedsLayout];

        [notiCenter postNotificationName:DXScreenNoticeDidShowNotification object:self];

        if (!self.disableAutoDismissed) {
            [self dismiss:YES];
        }
    }
}

- (void)dismiss:(BOOL)animated {
    [self dismiss:animated completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DXScreenNoticeDidDismissNotification object:self];
    }];
}

- (void)dismiss:(BOOL)animated completion:(void (^)(void))completion {
    if (animated) {
        [UIView animateWithDuration:0.8 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            self.alpha = 1;
            if (completion) {
                completion();
            }
        }];
    } else {
        [self removeFromSuperview];
        if (completion) {
            completion();
        }
    }
}

- (void)updateMessage:(NSString *)message {
    messageLabel.text = message;
    
    [self setNeedsUpdateConstraints];
}


- (void)setTapToDismissEnabled:(BOOL)enabled completion:(void (^)(void))completion {
    tapGesture.enabled = enabled;
    tapToDismissCompletion = completion;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    [self dismiss:NO completion:tapToDismissCompletion];
}


@end


