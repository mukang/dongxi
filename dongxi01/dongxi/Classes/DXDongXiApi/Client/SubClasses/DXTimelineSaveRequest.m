//
//  DXTimelineSaveRequest.m
//  dongxi
//
//  Created by 穆康 on 15/10/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineSaveRequest.h"

@implementation DXTimelineSaveRequest

- (void)setFid:(NSString *)fid {
    _fid = fid;
    
    if (fid) {
        [self setValue:fid forParam:@"fid"];
    }
}

@end
