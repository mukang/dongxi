//
//  DXApplyVerfiyButton.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXApplyVerfiyButton.h"

@implementation DXApplyVerfiyButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self updateProperButtonSize];
        [self setApplyState:DXApplyVerfiyButtonStateNormal];
    }
    return self;
}

- (void)updateProperButtonSize {
    UIImage * buttonImage = [UIImage imageNamed:@"apply_verify_btn_normal"];
    CGFloat buttonWidth = roundf(DXRealValue(buttonImage.size.width));
    CGFloat buttonHeight = roundf(DXRealValue(buttonImage.size.height));
    self.properButtonSize = CGSizeMake(buttonWidth, buttonHeight);
}

- (void)setApplyState:(DXApplyVerfiyButtonState)applyState {
    self.enabled = NO;
    switch (applyState) {
        case DXApplyVerfiyButtonStateNormal:
            [self setImage:[UIImage imageNamed:@"apply_verify_btn_normal"] forState:UIControlStateNormal];
            self.enabled = YES;
            break;
        case DXApplyVerfiyButtonStatePending:
            [self setImage:[UIImage imageNamed:@"apply_verify_btn_ok"] forState:UIControlStateNormal];
            break;
        case DXApplyVerfiyButtonStatePassed:
            [self setImage:[UIImage imageNamed:@"apply_verify_btn_success"] forState:UIControlStateNormal];
            break;
        case DXApplyVerfiyButtonStateFail:
            self.enabled = YES;
            [self setImage:[UIImage imageNamed:@"apply_verify_btn_lost"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}


@end
