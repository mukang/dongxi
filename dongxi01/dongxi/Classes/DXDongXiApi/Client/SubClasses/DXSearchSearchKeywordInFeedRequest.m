//
//  DXSearchSearchKeywordInFeedRequest.m
//  dongxi
//
//  Created by 穆康 on 16/1/27.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchSearchKeywordInFeedRequest.h"

@implementation DXSearchSearchKeywordInFeedRequest

- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    
    if (keyword) {
        [self setValue:keyword forParam:@"keyword"];
    }
}

- (void)setFlag:(NSInteger)flag {
    _flag = flag;
    
    [self setValue:@(flag) forParam:@"flag"];
}

- (void)setCount:(NSInteger)count {
    _count = count;
    
    [self setValue:@(count) forParam:@"count"];
}

- (void)setLast_id:(NSString *)last_id {
    _last_id = last_id;
    
    if (last_id) {
        [self setValue:last_id forParam:@"last_id"];
    }
}

@end
