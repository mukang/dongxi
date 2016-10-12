//
//  DXChatRecordView.h
//  dongxi
//
//  Created by 穆康 on 15/9/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXChatRecordViewDelegate;

@interface DXChatRecordView : UIView

@property (nonatomic, weak) id<DXChatRecordViewDelegate> delegate;

@end

@protocol DXChatRecordViewDelegate <NSObject>

@optional

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(DXChatRecordView *)recordView;
/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(DXChatRecordView *)recordView;
/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(DXChatRecordView *)recordView;
/**
 *  当手指离开按钮的范围内时
 */
- (void)didDragOutsideAction:(DXChatRecordView *)recordView;
/**
 *  当手指再次进入按钮的范围内时
 */
- (void)didDragInsideAction:(DXChatRecordView *)recordView;

@end
