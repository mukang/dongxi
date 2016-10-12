//
//  DXUserUserCheckRequest.m
//  dongxi
//
//  Created by 穆康 on 16/2/2.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserUserCheckRequest.h"

@implementation DXUserUserCheckRequest

- (void)setType:(DXUserCheckType)type {
    _type = type;
    
    [self setValue:@(type) forParam:@"type"];
}

- (void)setBuild:(NSUInteger)build {
    _build = build;
    
    [self setValue:@(build) forParam:@"build"];
}

@end
