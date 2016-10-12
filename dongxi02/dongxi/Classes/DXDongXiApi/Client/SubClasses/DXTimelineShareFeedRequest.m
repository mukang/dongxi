//
//  DXTimelineShareFeedRequest.m
//  dongxi
//
//  Created by 穆康 on 16/2/23.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineShareFeedRequest.h"

@implementation DXTimelineShareFeedRequest

- (void)setFid:(NSString *)fid {
    _fid = fid;
    
    if (fid) {
        [self setValue:fid forParam:@"fid"];
    }
}

- (void)setShare_to:(NSString *)share_to {
    _share_to = share_to;
    
    if (share_to) {
        [self setValue:share_to forParam:@"share_to"];
    }
}

@end
