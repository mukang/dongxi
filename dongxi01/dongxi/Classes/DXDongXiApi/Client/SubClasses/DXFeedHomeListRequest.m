//
//  DXFeedHomeListRequest.m
//  dongxi
//
//  Created by 穆康 on 16/8/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedHomeListRequest.h"

@implementation DXFeedHomeListRequest

- (void)setCount:(NSUInteger)count {
    _count = count;
    [self setValue:[NSString stringWithFormat:@"%zd", count] forParam:@"count"];
}

- (void)setLast_id:(NSString *)last_id {
    _last_id = last_id;
    if (last_id) {
        [self setValue:last_id forParam:@"last_id"];
    }
}

- (void)setFlag:(NSInteger)flag {
    _flag = flag;
    [self setValue:[NSString stringWithFormat:@"%zd", flag] forParam:@"flag"];
}

- (void)setRecommend_user_timestamp:(NSUInteger)recommend_user_timestamp {
    _recommend_user_timestamp = recommend_user_timestamp;
    [self setValue:[NSString stringWithFormat:@"%zd", recommend_user_timestamp] forParam:@"recommend_user_timestamp"];
}

- (void)setRecommend_topic_timestamp:(NSUInteger)recommend_topic_timestamp {
    _recommend_topic_timestamp = recommend_topic_timestamp;
    [self setValue:[NSString stringWithFormat:@"%zd", recommend_topic_timestamp] forParam:@"recommend_topic_timestamp"];
}

#pragma mark - override

- (NSString *)HTTPMethod {
    return @"GET";
}

- (DXClientRequestVersion)version {
    return DXClientRequestVersion2;
}

@end
