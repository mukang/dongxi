//
//  DXChatBaseBubbleView.h
//  dongxi
//
//  Created by 穆康 on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXChatMessage.h"

extern NSString *const kRouterEventBaseBubbleTapEventName;

#define BUBBLE_LEFT_LEFT_CAP_WIDTH 30  // 文字在左侧时,bubble用于拉伸点的X坐标
#define BUBBLE_RIGHT_LEFT_CAP_WIDTH 25 // 文字在右侧时,bubble用于拉伸点的X坐标
#define BUBBLE_TOP_CAP_HEIGHT 30       // bubble用于拉伸点的Y坐标

#define BUBBLE_ARROW_WIDTH 13               // bubbleView中，箭头的宽度
#define BUBBLE_VIEW_PADDING DXRealValue(10) // bubbleView 与 在其中的文字内边距

@interface DXChatBaseBubbleView : UIView

@property (nonatomic, strong) DXChatMessage *chatMessage;

/**
 *  视图高度
 */
+ (CGFloat)heightForBubbleWithChatMessage:(DXChatMessage *)chatMessage;

/**
 *  点击了气泡视图
 */
- (void)bubbleViewPressed:(id)sender;

@end
