//
//  DXStatusBarHUD.m
//  dongxi
//
//  Created by 穆康 on 15/12/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXStatusBarHUD.h"
#import "DXStatusBarWindow.h"

// 窗口高度
static const CGFloat DXWindowHeight = 20.0f;
// 文字和加载圆点的间距
static const CGFloat Margin = 6.0f;
// 窗口
static DXStatusBarWindow *_window;
// 提示信息
static UILabel *_msgLabel;
// 正在加载状态
static BOOL _isLoading;

@implementation DXStatusBarHUD

+ (void)showPublishingWithMsg:(NSString *)msg {
    
    if (_window) return;
    
    [self setupWindowAndMsgLabel];
    
    _window.backgroundColor = DXRGBColor(106, 106, 106);
    _msgLabel.text = msg;
    [_msgLabel sizeToFit];
    _msgLabel.center = CGPointMake(_window.width * 0.5f, _window.height * 0.5f);
    _window.distance = _msgLabel.width + Margin * 2.0f;
    _isLoading = YES;
    
    // 开始动画
    [_window startAnimating];
}

+ (void)showSuccessWithMsg:(NSString *)msg {
    
    if (_window && !_isLoading) return;
    
    if (_window == nil) {
        [self setupWindowAndMsgLabel];
    }
    
    [_window stopAnimating];
    
    _window.backgroundColor = DXRGBColor(153, 201, 239);
    _msgLabel.text = msg;
    [_msgLabel sizeToFit];
    _msgLabel.center = CGPointMake(_window.width * 0.5f, _window.height * 0.5f);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.5f animations:^{
            _window.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _msgLabel = nil;
            _window = nil;
        }];
    });
}

+ (void)showErrorWithMsg:(NSString *)msg {
    
    if (_window && !_isLoading) return;
    
    if (_window == nil) {
        [self setupWindowAndMsgLabel];
    }
    
    [_window stopAnimating];
    
    _window.backgroundColor = DXRGBColor(241, 155, 168);
    _msgLabel.text = msg;
    [_msgLabel sizeToFit];
    _msgLabel.center = CGPointMake(_window.width * 0.5f, _window.height * 0.5f);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.5f animations:^{
            _window.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _msgLabel = nil;
            _window = nil;
        }];
    });
}

/**
 *  创建窗口和显示信息的label
 */
+ (void)setupWindowAndMsgLabel {
    
    // 窗口
    _window = [[DXStatusBarWindow alloc] init];
    _window.windowLevel = UIWindowLevelAlert;
    _window.frame = CGRectMake(0, 0, DXScreenWidth, DXWindowHeight);
    
    // 显示提示信息的label
    _msgLabel = [[UILabel alloc] init];
    _msgLabel.textColor = [UIColor whiteColor];
    _msgLabel.font = [UIFont fontWithName:DXCommonFontName size:12.0f];
    [_window addSubview:_msgLabel];
    
    // 显示窗口
    _window.hidden = NO;
}

@end
