//
//  DXChatChatListRequest.m
//  dongxi
//
//  Created by 穆康 on 16/4/8.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatChatListRequest.h"

@implementation DXChatChatListRequest

- (void)setTo:(NSString *)to {
    _to = to;
    if (to) {
        [self setValue:to forParam:@"to"];
    }
}

- (void)setCount:(NSInteger)count {
    _count = count;
    [self setValue:@(count) forParam:@"count"];
}

- (void)setMsg_id:(NSString *)msg_id {
    _msg_id = msg_id;
    if (msg_id) {
        [self setValue:msg_id forParam:@"msg_id"];
    }
}

@end
