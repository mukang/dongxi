//
//  DXTimelineUnlikeRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineUnlikeRequest.h"

@implementation DXTimelineUnlikeRequest

- (void)setFid:(NSString *)fid {
    _fid = fid;
    
    if (fid) {
        [self setValue:fid forParam:@"fid"];
    }
}

@end
