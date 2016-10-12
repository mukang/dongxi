//
//  DXMessageDiscuss.m
//  dongxi
//
//  Created by 穆康 on 15/9/15.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageDiscuss.h"
#import "NSDate+Extension.h"

@implementation DXMessageDiscuss

- (NSString *)lastTime {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_time];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    if (date.isThisYear) { // 今年
        if (date.isToday) { // 今天
            fmt.dateFormat = @"HH:mm";
            return [fmt stringFromDate:date];
        } else {
            fmt.dateFormat = @"MM-dd";
            return [fmt stringFromDate:date];
        }
    } else {
        fmt.dateFormat = @"yy-MM-dd";
        return [fmt stringFromDate:date];
    }
}

@end
