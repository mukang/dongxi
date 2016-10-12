//
//  DXComment.m
//  dongxi
//
//  Created by 穆康 on 15/9/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXComment.h"
#import "DXDongXiApi.h"

@implementation DXComment

- (void)setUid:(NSString *)uid {
    
    _uid = uid;
    
    NSString *myUid = [[DXDongXiApi api] currentUserSession].uid;
    
    if ([uid isEqualToString:myUid]) {
        _own = YES;
    } else {
        _own = NO;
    }
}


- (void)setTime:(NSTimeInterval)time {
    
    _time = time;
    
    NSDate *commentDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDate *nowDate = [NSDate date];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy";
    NSString *commentYear = [fmt stringFromDate:commentDate];
    NSString *nowYear = [fmt stringFromDate:nowDate];
    
    if ([commentYear isEqualToString:nowYear]) {
        fmt.dateFormat = @"MM-dd HH:mm";
    } else {
        fmt.dateFormat = @"yy-MM-dd HH:mm";
    }
    
    _fmtTime = [fmt stringFromDate:commentDate];
}

+ (NSDictionary *)objectClassInArray{
    return @{@"content_pieces" : [DXContentPiece class]};
}

@end
