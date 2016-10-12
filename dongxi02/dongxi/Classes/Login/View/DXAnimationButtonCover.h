//
//  DXAnimationButtonCover.h
//  dongxi
//
//  Created by 穆康 on 15/8/14.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DXAnimationButtonCoverStateNomal = 1,
    DXAnimationButtonCoverStateLoading,
    DXAnimationButtonCoverStateWarn,
    DXAnimationButtonCoverStateCorrect
} DXAnimationButtonState;

@interface DXAnimationButtonCover : UIView

@property (nonatomic, assign) DXAnimationButtonState currentState;

- (void)changeAnimationButtonCoverState:(DXAnimationButtonState)coverState;

@end
