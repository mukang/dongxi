//
//  DXWeiboShareInfo.m
//  dongxi
//
//  Created by 穆康 on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXWeiboShareInfo.h"
#import "NSString+DXConvenient.h"

#define kWeiboShareTextLimit 140

@implementation DXWeiboShareInfo

- (NSString *)shareText {
    NSString * title = self.title;
    NSString * postfix = nil;
    if (self.url) {
        postfix = [NSString stringWithFormat:@"%@ (来自 东西App@东西官方微博)", self.url];
    } else {
        postfix = [NSString stringWithFormat:@" (来自 东西App@东西官方微博)"];
    }
    NSInteger titleCount = [self.title chineseCharacterLength];
    NSInteger postfixCount = [postfix chineseCharacterLength];
    
    if (titleCount + postfixCount > kWeiboShareTextLimit) {
        NSInteger bestTitleCount = kWeiboShareTextLimit - titleCount - postfixCount - 2;
        title = [title stringByLimitedToChineseCharacterLength:bestTitleCount];
        title = [title stringByAppendingString:@"..."];
    }
    
    return [NSString stringWithFormat:@"%@ %@", title, postfix];
}

@end
