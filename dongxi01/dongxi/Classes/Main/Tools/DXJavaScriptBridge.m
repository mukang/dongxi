//
//  DXJavaScriptBridge.m
//  dongxi
//
//  Created by 穆康 on 16/7/4.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXJavaScriptBridge.h"

@interface DXJavaScriptBridge ()

@property (nonatomic, strong) NSDictionary *map;

@end

@implementation DXJavaScriptBridge
DXSingletonImplementation(Bridge)

- (instancetype)init {
    self = [super init];
    if (self) {
        _map = @{
                 @"js_navigation_pop"       : @"jsNavigationPop",
                 @"js_navigation_set_title" : @"jsNavigationSetTitle:",
                 @"js_user_need_login"      : @"jsUserNeedLogin"
                 };
    }
    return self;
}

- (void)performJSMethodWithURL:(NSURL *)URL performViewController:(UIViewController <DXJavaScriptBridgeController>*)viewController {
    
    NSString *host = [URL host];
    NSString *methodName = [self.map objectForKey:host];
    
    NSMutableArray *params = [NSMutableArray array];
    if (URL.query) {
        NSString *paramsString = [URL.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSArray *paramsArray = [paramsString componentsSeparatedByString:@"&"];
        for (NSString *param in paramsArray) {
            NSArray *keyAndValue = [param componentsSeparatedByString:@"="];
            [params addObject:[keyAndValue lastObject]];
        }
    }
    
    if (viewController && [viewController conformsToProtocol:@protocol(DXJavaScriptBridgeController)]) {
        [viewController performJSMethod:methodName params:params];
    }
}

@end
