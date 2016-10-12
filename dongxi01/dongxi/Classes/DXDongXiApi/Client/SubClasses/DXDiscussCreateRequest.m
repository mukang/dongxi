//
//  DXDiscussCreateRequest.m
//  dongxi
//
//  Created by 穆康 on 15/9/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDiscussCreateRequest.h"

@implementation DXDiscussCreateRequest

- (void)setFid:(NSString *)fid {
    
    _fid = fid;
    
    if (fid) {
        [self setValue:fid forParam:@"fid"];
    }
}

- (void)setTo:(NSString *)to {
    
    _to = to;
    
    if (to) {
        [self setValue:to forParam:@"to"];
    }
}

- (void)setTxt:(NSString *)txt {
    
    _txt = txt;
    
    if (txt) {
        [self setValue:txt forParam:@"txt"];
    }
}

- (void)setOnline:(BOOL)online {
    
    _online = online;
    
    if (online) {
        [self setValue:@(1) forParam:@"online"];
    }
}

- (void)setType:(NSInteger)type {
    
    _type = type;
    
    [self setValue:@(type) forParam:@"type"];
}

@end
