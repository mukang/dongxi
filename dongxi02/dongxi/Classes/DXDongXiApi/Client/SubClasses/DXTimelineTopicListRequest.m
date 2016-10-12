//
//  DXTimelineTopicListRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineTopicListRequest.h"

@implementation DXTimelineTopicListRequest

- (void)setCount:(NSUInteger)count {
    _count = count;
    [self setValue:@(count) forParam:@"count"];
}

- (void)setLast_id:(NSString *)last_id {
    _last_id = last_id;
    if (last_id) {
        [self setValue:last_id forParam:@"last_id"];
    }
}

- (void)setFlag:(NSUInteger)flag {
    _flag = flag;
    [self setValue:@(flag) forParam:@"flag"];
}

- (void)setType:(NSString *)type {
    _type = type;
    if (type) {
        [self setValue:type forParam:@"type"];
    }
}

- (void)setTopic_id:(NSString *)topic_id {
    _topic_id = topic_id;
    if (topic_id) {
        [self setValue:topic_id forParam:@"topic_id"];
    }
}

@end
