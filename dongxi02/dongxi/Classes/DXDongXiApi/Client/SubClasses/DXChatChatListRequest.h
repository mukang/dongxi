//
//  DXChatChatListRequest.h
//  dongxi
//
//  Created by 穆康 on 16/4/8.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXChatChatListRequest : DXClientRequest

/** 对方联系人的ID */
@property (nonatomic, copy) NSString *to;
/** 一次请求拉取的消息数量 */
@property (nonatomic, assign) NSInteger count;
/** 消息ID，由环信提供 */
@property (nonatomic, copy) NSString *msg_id;

@end
