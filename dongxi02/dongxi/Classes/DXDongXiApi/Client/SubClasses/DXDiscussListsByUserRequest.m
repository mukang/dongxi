//
//  DXDiscussListsByUserRequest.m
//  dongxi
//
//  Created by 穆康 on 15/9/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDiscussListsByUserRequest.h"

@implementation DXDiscussListsByUserRequest

- (void)setFlag:(NSInteger)flag {
    
    _flag = flag;
    
    [self setValue:@(flag) forParam:@"flag"];
}

- (void)setCount:(NSInteger)count {
    
    _count = count;
    
    [self setValue:@(count) forParam:@"count"];
}

- (void)setTo:(NSString *)to {
    
    _to = to;
    
    if (to) {
        [self setValue:to forParam:@"to"];
    }
}

- (void)setLast_id:(NSString *)last_id {
    
    _last_id = last_id;
    
    if (last_id) {
        [self setValue:last_id forParam:@"last_id"];
    }
}

@end
