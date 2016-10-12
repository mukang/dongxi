//
//  DXRoute.m
//  dongxi
//
//  Created by 穆康 on 16/7/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRoute.h"

@implementation DXRoute

- (instancetype)init {
    self = [super init];
    if (self) {
        _routeID = [[NSUUID UUID] UUIDString];
        _map = @{
                 @"/discuss/answer/info"    : @"DXWebViewController",               // 回答详情
                 @"/discuss/question/info"  : @"DXWebViewController",               // 问题详情
                 @"/discuss/profile/info"   : @"DXProfileViewController"            // 点击头像
                 };
    }
    return self;
}

- (NSString *)controllerNameAndParams:(NSDictionary **)params withParseURL:(NSURL *)URL {
    
    NSString *urlPath = [URL path];
    NSString *controllerName = [self.map objectForKey:urlPath];
    
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionary];
    if ([controllerName isEqualToString:@"DXWebViewController"]) {
        NSMutableString *urlString = [NSMutableString stringWithString:[URL absoluteString]];
        NSRange replaceRange = [urlString rangeOfString:[URL scheme]];
        [urlString replaceCharactersInRange:replaceRange withString:@"http"];
        NSURL *realURL = [NSURL URLWithString:[urlString copy]];
        [tempParams setObject:realURL forKey:@"url"];
    } else {
        NSString *paramsString = [URL query];
        NSArray *paramsArray = [paramsString componentsSeparatedByString:@"&"];
        for (NSString *param in paramsArray) {
            NSArray *keyAndValue = [param componentsSeparatedByString:@"="];
            [tempParams setObject:[keyAndValue lastObject] forKey:[keyAndValue firstObject]];
        }
    }
    
    *params = tempParams;
    return controllerName;
}

@end
