//
//  DXRouteManager.m
//  dongxi
//
//  Created by 穆康 on 16/6/30.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRouteManager.h"
#import "DXRoute.h"

@implementation DXRouteManager
DXSingletonImplementation(RouteManager)

- (UIViewController *)handleRouteURL:(NSURL *)URL {
    
    DXRoute *route = [[DXRoute alloc] init];
    NSDictionary *params = nil;
    NSString *controllerName = [route controllerNameAndParams:&params withParseURL:URL];
    Class ControllerClass =  NSClassFromString(controllerName);
    if (ControllerClass && [ControllerClass conformsToProtocol:@protocol(DXRouteControler)]) {
        return [[ControllerClass alloc] initWithRouteParams:params];
    }
    return nil;
}

@end
