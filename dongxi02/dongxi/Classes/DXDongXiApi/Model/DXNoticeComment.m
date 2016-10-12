//
//  DXNoticeComment.m
//  dongxi
//
//  Created by 穆康 on 15/11/4.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNoticeComment.h"

@implementation DXNoticeComment

- (void)setComment_time:(NSTimeInterval)comment_time {
    
    _comment_time = comment_time;
    
    NSDate *commentDate = [NSDate dateWithTimeIntervalSince1970:comment_time];
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
