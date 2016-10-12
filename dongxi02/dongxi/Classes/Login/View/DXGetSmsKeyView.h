//
//  DXGetSmsKeyView.h
//  dongxi
//
//  Created by 穆康 on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXGetSmsKeyView;

@protocol DXGetSmsKeyViewDelegate <NSObject>

@optional

- (void)didClickGetSmsKeyInGetSmsKeyView:(DXGetSmsKeyView *)view;

@end

@interface DXGetSmsKeyView : UIView

@property (nonatomic, weak) id<DXGetSmsKeyViewDelegate> delegate;

// 开始倒计时
- (void)startCountDown;

@end
