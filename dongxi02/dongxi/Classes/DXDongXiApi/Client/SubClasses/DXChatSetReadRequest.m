//
//  DXChatSetReadRequest.m
//  dongxi
//
//  Created by 穆康 on 16/4/11.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatSetReadRequest.h"

@implementation DXChatSetReadRequest

- (void)setFrom:(NSString *)from {
    _from = from;
    if (from) {
        [self setValue:from forParam:@"from"];
    }
}

@end
