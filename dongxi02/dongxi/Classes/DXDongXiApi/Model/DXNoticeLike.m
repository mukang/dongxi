//
//  DXNoticeLike.m
//  dongxi
//
//  Created by 穆康 on 15/10/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNoticeLike.h"

@implementation DXNoticeLike

- (void)setTime:(NSTimeInterval)time {
    
    _time = time;
    
    NSDate *likeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDate *nowDate = [NSDate date];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy";
    NSString *likeYear = [fmt stringFromDate:likeDate];
    NSString *nowYear = [fmt stringFromDate:nowDate];
    
    if ([likeYear isEqualToString:nowYear]) {
        fmt.dateFormat = @"MM-dd HH:mm";
    } else {
        fmt.dateFormat = @"yy-MM-dd HH:mm";
    }
    
    self.likeTime = [fmt stringFromDate:likeDate];
}

@end
