//
//  DXFeedTimelineRequest.m
//  dongxi
//
//  Created by 穆康 on 16/3/8.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedTimelineRequest.h"

@implementation DXFeedTimelineRequest

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

- (void)setFilter:(NSString *)filter {
    _filter = filter;
    if (filter) {
        [self setValue:filter forParam:@"filter"];
    }
}

@end
