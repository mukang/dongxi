//
//  DXTabBar.m
//  dongxi
//
//  Created by 穆康 on 15/8/4.
//  Copyright (c) 2015年 穆康. All rights reserved.
//

#import "DXTabBar.h"


//拍照按钮点击通知名
const NSString *DXPhotoBtnDidClickNotification = @"DXPhotoBtnDidClickNotification";

@interface DXTabBar ()

/** 拍照按钮 */
@property (nonatomic, weak) UIButton *photoBtn;

@end

@implementation DXTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

/** 初始化 */
- (void)setup {
    
    // 设置tabbar不透明
    self.translucent = NO;
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"tab_camera_normal"] forState:UIControlStateNormal];
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"tab_camera_click"] forState:UIControlStateHighlighted];
    
    [photoBtn addTarget:self action:@selector(clickPhotoBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:photoBtn];
    self.photoBtn = photoBtn;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 设置tabBar中按钮的位置
    CGFloat btnW = self.width / 5.0;
    CGFloat btnH = self.height;
    
    int btnIndex = 0;
    
    for (UIView *childView in self.subviews) {
        
        if ([childView isKindOfClass:[UIControl class]] && ![childView isKindOfClass:[UIButton class]]) {
            CGFloat btnX = btnW * btnIndex;
            childView.frame = CGRectMake(btnX, 0, btnW, btnH);
            
            btnIndex ++;
            if (btnIndex == 2) {
                btnIndex ++;
            }
        }
    }
    CGFloat btnWidth = roundf(DXRealValue(self.photoBtn.currentBackgroundImage.size.width));
    CGFloat btnHeight = roundf(DXRealValue(self.photoBtn.currentBackgroundImage.size.height));
    self.photoBtn.size = CGSizeMake(btnWidth, btnHeight);
    self.photoBtn.center = CGPointMake(self.width * 0.5, self.height * 0.5);
}


- (void)clickPhotoBtn {
    
    DXLog(@"++++拍照++++");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DXPhotoBtnDidClickNotification" object:nil];
    
}


@end
