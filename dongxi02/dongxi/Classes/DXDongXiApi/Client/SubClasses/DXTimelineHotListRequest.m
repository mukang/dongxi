//
//  DXTimelineHotListRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineHotListRequest.h"

@implementation DXTimelineHotListRequest

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

- (void)setRecommend_user_timestamp:(NSUInteger)recommend_user_timestamp {
    _recommend_user_timestamp = recommend_user_timestamp;
    [self setValue:@(recommend_user_timestamp) forParam:@"recommend_user_timestamp"];
}

- (void)setRecommend_topic_timestamp:(NSUInteger)recommend_topic_timestamp {
    _recommend_topic_timestamp = recommend_topic_timestamp;
    [self setValue:@(recommend_topic_timestamp) forParam:@"recommend_topic_timestamp"];
}

@end
