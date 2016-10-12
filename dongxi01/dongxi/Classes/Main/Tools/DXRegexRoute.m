//
//  DXRegexRoute.m
//  dongxi
//
//  Created by 穆康 on 16/7/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRegexRoute.h"

@implementation DXRegexRoute

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

/*

- (NSDictionary *)ruleToRegx:(NSString *)rule {
    NSString * ruleRegx = @"\\{(.*?)\\}";
    NSError * error;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:ruleRegx options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray * matches = [regex matchesInString:rule options:0 range:NSMakeRange(0, rule.length)];
    
    NSMutableString * finalRegex = [rule mutableCopy];
    
    for (NSTextCheckingResult * textResult in matches) {
        NSRange textRange = textResult.range;
        NSString * queryKey = [rule substringWithRange:textRange];
        [finalRegex replaceCharactersInRange:textRange withString:@"(.*?)"];
    }
    return @{
             @"keys" : @[],
             @"regex" : [finalRegex copy]
             };
}
 
 */

@end
