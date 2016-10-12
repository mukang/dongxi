//
//  DXActivity.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/26.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivity.h"

@implementation DXActivity

+ (NSDictionary *)objectClassInArray{
    return @{@"comment" : [DXActivityComment class], @"want" : [DXActivityWantUserInfo class]};
}

+ (NSDictionary *)objectClassInDictionary{
    return @{@"detail" : [DXActivityDetail class]};
}

- (NSString *)typeText {
    switch (_type) {
        case DXActivityTypeExhibition:
            return @"展览";
        case DXActivityTypeEvent:
            return @"活动";
        case DXActivityTypeSalon:
            return @"沙龙";
        default:
            return @"未知";
            break;
    }
}

@end


@implementation DXActivityDetail

@end


@implementation DXActivityComment

- (NSString *)formattedTime {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-M-d";
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:self.time];
    return [formatter stringFromDate:date];
}

@end


@implementation DXActivityWantUserInfo

@end


