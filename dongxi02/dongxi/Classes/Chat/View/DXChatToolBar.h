//
//  DXChatToolBar.h
//  dongxi
//
//  Created by 穆康 on 15/9/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXChatToolBarDelegate;
/**
 *  推荐使用 initWithFrame: 方法初始化
 */
@interface DXChatToolBar : UIView

@property (nonatomic, weak) id<DXChatToolBarDelegate> delegate;

/** 调出语音和收起语音按钮 */
@property (nonatomic, weak) UIButton *changeRecordBtn;

@end

@protocol DXChatToolBarDelegate <NSObject>

@optional
/**
 *  在普通状态和语音状态之间进行切换时，会触发这个回调函数
 *
 *  @param changedToRecord 是否改为发送语音状态
 */
- (void)didStyleChangeToRecord:(BOOL)changedToRecord;
/**
 *  录音界面的显示与隐藏
 *
 *  @param isShow 是否是显示的
 */
- (void)didRecordBtnStatusChangeToShow:(BOOL)isShow;
/**
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 */
- (void)didSendText:(NSString *)text;

@required
/**
 *  chatToolBar的高度变化
 *
 *  @param toHeight 变化到的高度
 */
- (void)chatToolBarDidChangeFrameToHeight:(CGFloat)toHeight;

@end
