//
//  DXMessagePostReadRequest.m
//  dongxi
//
//  Created by 穆康 on 15/11/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessagePostReadRequest.h"

@implementation DXMessagePostReadRequest

- (void)setType:(NSInteger)type {
    
    _type = type;
    
    [self setValue:@(type) forParam:@"type"];
}

@end
