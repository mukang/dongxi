//
//  DXTimelinePrivateListRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelinePrivateListRequest.h"

@implementation DXTimelinePrivateListRequest

- (void)setUid:(NSString *)uid {
    _uid = uid;
    [self setValue:uid forParam:@"uid"];
}

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

- (void)setModel:(NSUInteger)model {
    _model = model;
    
    [self setValue:@(model) forParam:@"modle"];
}

- (void)setTopic_id:(NSString *)topic_id {
    _topic_id = topic_id;
    
    [self setValue:topic_id forParam:@"topic_id"];
}

@end
