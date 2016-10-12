//
//  DXTimelineLikeUserListRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/13.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineLikeUserListRequest.h"

@implementation DXTimelineLikeUserListRequest

- (void)setFid:(NSString *)fid {
    _fid = fid;
    [self setValue:fid forParam:@"fid"];
}

- (void)setCount:(NSUInteger)count {
    _count = count;
    [self setValue:@(count) forParam:@"count"];
}

- (void)setLast_id:(NSString *)last_id {
    _last_id = last_id;
    [self setValue:last_id forParam:@"last_id"];
}

- (void)setFlag:(NSInteger)flag {
    _flag = flag;
    [self setValue:@(flag) forParam:@"flag"];
}

@end