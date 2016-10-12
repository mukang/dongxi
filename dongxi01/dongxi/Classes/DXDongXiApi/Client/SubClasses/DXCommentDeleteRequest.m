//
//  DXCommentDeleteRequest.m
//  dongxi
//
//  Created by 穆康 on 15/11/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCommentDeleteRequest.h"

@implementation DXCommentDeleteRequest

- (void)setID:(NSString *)ID {
    
    _ID = ID;
    
    if (ID) {
        [self setValue:ID forParam:@"id"];
    }
}

@end
