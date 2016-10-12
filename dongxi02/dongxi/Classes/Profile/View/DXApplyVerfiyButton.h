//
//  DXApplyVerfiyButton.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DXApplyVerfiyButtonStateNormal = 0,
    DXApplyVerfiyButtonStatePending,
    DXApplyVerfiyButtonStatePassed,
    DXApplyVerfiyButtonStateFail
} DXApplyVerfiyButtonState;

@interface DXApplyVerfiyButton : UIButton

@property (nonatomic, assign) DXApplyVerfiyButtonState applyState;
@property (nonatomic, assign) CGSize properButtonSize;

@end
