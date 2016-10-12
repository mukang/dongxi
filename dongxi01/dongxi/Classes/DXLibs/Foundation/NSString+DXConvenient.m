//
//  NSString+DXConvenient.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "NSString+DXConvenient.h"

@implementation NSString (DXConvenient)

- (BOOL)isWhiteSpaces {
    NSString * trimmedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [trimmedString isEqualToString:@""];
}

- (BOOL)isWhiteSpacesAndNewLines {
    NSString * trimmedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [trimmedString isEqualToString:@""];
}

- (NSUInteger)chineseCharacterLength {
    float length = 0;
    NSUInteger characterCount = self.length;
    for (NSUInteger i = 0; i < characterCount; i++) {
        unichar character = [self characterAtIndex:i];
        if (character > 0x7F) {
            length += 1;
        } else {
            length += 0.5;
        }
    }
    return roundf(length);
}

- (NSString *)stringByLimitedToChineseCharacterLength:(NSUInteger)cLength {
    if (cLength > 0) {
        float length = 0;
        NSUInteger characterCount = self.length;
        NSMutableString * finalString = [NSMutableString string];
        for (NSUInteger i = 0; i < characterCount; i++) {
            unichar character = [self characterAtIndex:i];
            if (character > 0x7F) {
                length += 1;
            } else {
                length += 0.5;
            }
            if (roundf(length) > cLength) {
                break;
            } else {
                [finalString appendFormat:@"%C", character];
            }
        }
        return [finalString copy];
    } else {
        return @"";
    }
}

@end
