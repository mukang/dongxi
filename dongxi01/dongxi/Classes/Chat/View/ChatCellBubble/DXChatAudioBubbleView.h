//
//  DXChatAudioBubbleView.h
//  dongxi
//
//  Created by 穆康 on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatBaseBubbleView.h"

extern NSString *const kRouterEventAudioBubbleTapEventName;

@interface DXChatAudioBubbleView : DXChatBaseBubbleView

/**
 *  开始播放动画
 */
- (void)startAudioAnimation;
/**
 *  停止播放动画
 */
- (void)stopAudioAnimation;

@end
