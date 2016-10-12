//
//  DXJavaScriptBridge.h
//  dongxi
//
//  Created by 穆康 on 16/7/4.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXSingleton.h"

@protocol DXJavaScriptBridgeController <NSObject>

@required
- (void)performJSMethod:(NSString *)methodName params:(NSArray *)params;

@end

@interface DXJavaScriptBridge : NSObject
DXSingletonInterface(Bridge)

- (void)performJSMethodWithURL:(NSURL *)URL performViewController:(UIViewController *)viewController;

@end
