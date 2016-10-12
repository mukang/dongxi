//
//  DXMessageDeleteNoticeRequest.m
//  dongxi
//
//  Created by 穆康 on 15/10/15.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageDeleteNoticeRequest.h"

@implementation DXMessageDeleteNoticeRequest

- (void)setID:(NSString *)ID {
    
    _ID = ID;
    
    if (ID) {
        [self setValue:ID forParam:@"id"];
    }
}

@end
