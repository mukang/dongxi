//
//  NSDateFormatter+Extension.m
//  dongxi
//
//  Created by 穆康 on 15/9/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "NSDateFormatter+Extension.h"

@implementation NSDateFormatter (Extension)

+ (id)dateFormatter
{
    return [[self alloc] init];
}

+ (id)dateFormatterWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[self alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

+ (id)defaultDateFormatter
{
    return [self dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

@end
