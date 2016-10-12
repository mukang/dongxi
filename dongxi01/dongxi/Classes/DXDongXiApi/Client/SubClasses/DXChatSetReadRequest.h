//
//  DXChatSetReadRequest.h
//  dongxi
//
//  Created by 穆康 on 16/4/11.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXChatSetReadRequest : DXClientRequest

/** 发送消息方的用户ID */
@property (nonatomic, copy) NSString *from;

@end
