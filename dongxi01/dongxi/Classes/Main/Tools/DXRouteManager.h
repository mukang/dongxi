//
//  DXRouteManager.h
//  dongxi
//
//  Created by 穆康 on 16/6/30.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXSingleton.h"

typedef void(^DXRouteCompletion)(UIViewController * controller);

@protocol DXRouteControler <NSObject>

@required
- (UIViewController *)initWithRouteParams:(NSDictionary *)params;

@end


@interface DXRouteManager : NSObject
DXSingletonInterface(RouteManager)

- (UIViewController *)handleRouteURL:(NSURL *)URL;

@end
