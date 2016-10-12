//
//  DXChatBackupChatRequest.m
//  dongxi
//
//  Created by 穆康 on 16/4/11.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatBackupChatRequest.h"

@implementation DXChatBackupChatRequest

- (void)setType:(NSInteger)type {
    _type = type;
    [self setValue:@(type) forParam:@"type"];
}

- (void)setChat_type:(NSInteger)chat_type {
    _chat_type = chat_type;
    [self setValue:@(chat_type) forParam:@"chat_type"];
}

- (void)setTime:(long long)time {
    _time = time;
    [self setValue:@(time) forParam:@"time"];
}

- (void)setFrom:(NSString *)from {
    _from = from;
    if (from) {
        [self setValue:from forParam:@"from"];
    }
}

- (void)setMsg_id:(NSString *)msg_id {
    _msg_id = msg_id;
    if (msg_id) {
        [self setValue:msg_id forParam:@"msg_id"];
    }
}

- (void)setMsg:(NSString *)msg {
    _msg = msg;
    if (msg) {
        [self setValue:msg forParam:@"msg"];
    }
}

- (void)setLength:(NSUInteger)length {
    _length = length;
    [self setValue:@(length) forParam:@"length"];
}

- (void)setUrl:(NSString *)url {
    _url = url;
    if (url) {
        [self setValue:url forParam:@"url"];
    }
}

- (void)setFilename:(NSString *)filename {
    _filename = filename;
    if (filename) {
        [self setValue:filename forParam:@"filename"];
    }
}

@end
