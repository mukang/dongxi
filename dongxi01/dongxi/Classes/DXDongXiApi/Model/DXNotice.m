//
//  DXNotice.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNotice.h"

@implementation DXNotice

- (void)setTime:(NSTimeInterval)time {
    
    _time = time;
    
    NSDate *noticeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDate *nowDate = [NSDate date];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy";
    NSString *noticeYear = [fmt stringFromDate:noticeDate];
    NSString *nowYear = [fmt stringFromDate:nowDate];
    
    if ([noticeYear isEqualToString:nowYear]) {
        fmt.dateFormat = @"MM-dd HH:mm";
    } else {
        fmt.dateFormat = @"yy-MM-dd HH:mm";
    }
    
    _fmtTime = [fmt stringFromDate:noticeDate];
}

@end
