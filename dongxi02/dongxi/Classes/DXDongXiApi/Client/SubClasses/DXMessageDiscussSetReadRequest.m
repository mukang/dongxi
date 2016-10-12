//
//  DXMessageDiscussSetReadRequest.m
//  dongxi
//
//  Created by 穆康 on 15/9/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageDiscussSetReadRequest.h"

@implementation DXMessageDiscussSetReadRequest

- (void)setUid:(NSString *)uid {
    
    _uid = uid;
    
    if (uid) {
        [self setValue:uid forParam:@"uid"];
    }
}

@end
