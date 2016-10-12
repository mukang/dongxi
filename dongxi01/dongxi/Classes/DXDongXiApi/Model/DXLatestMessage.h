//
//  DXLatestMessage.h
//  dongxi
//
//  Created by 穆康 on 16/4/26.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXChatMessage.h"

@interface DXLatestMessage : NSObject

/** 当前会话的未读条数 */
@property (nonatomic, assign) NSInteger unreadCount;
/** 当前会话的最后一条消息 */
@property (nonatomic, strong) DXChatMessage *chatMessage;

@end
