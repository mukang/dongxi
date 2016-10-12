//
//  DXCommentListsRequest.m
//  dongxi
//
//  Created by 穆康 on 15/9/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCommentListsRequest.h"

@implementation DXCommentListsRequest

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

- (void)setFid:(NSString *)fid {
    _fid = fid;
    
    if (fid) {
        [self setValue:fid forParam:@"fid"];
    }
}

@end
