//
//  DXFeedTapDetectingView.h
//  dongxi
//
//  Created by 穆康 on 16/3/2.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXFeedTapDetectingViewDelegate;

@interface DXFeedTapDetectingView : UIView

@property (nonatomic, weak) id<DXFeedTapDetectingViewDelegate> tapDelegate;

@end

@protocol DXFeedTapDetectingViewDelegate <NSObject>

@optional

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end
