//
//  DXChatBackupChatRequest.h
//  dongxi
//
//  Created by 穆康 on 16/4/11.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXChatBackupChatRequest : DXClientRequest

/** 消息类型(文本/语音/图片/位置) */
@property (nonatomic, assign) NSInteger type;
/** 聊天类型(单聊/群聊) */
@property (nonatomic, assign) NSInteger chat_type;
/** 消息的接收时间，由环信返回 */
@property (nonatomic, assign) long long time;
/** 发送人ID */
@property (nonatomic, copy) NSString *from;
/** 消息ID， 由环信返回 */
@property (nonatomic, copy) NSString *msg_id;
/** 消息正文，如果是语音、图片消息，该字段存放语音、图片在备份服务器上的ID */
@property (nonatomic, copy) NSString *msg;
/** 语音消息的时长, 由环信返回 */
@property (nonatomic, assign) NSUInteger length;
/** 语音、图片的远程地址，由环信返回 */
@property (nonatomic, copy) NSString *url;
/** 语音、图片的名称，由环信返回 */
@property (nonatomic, copy) NSString *filename;

@end
