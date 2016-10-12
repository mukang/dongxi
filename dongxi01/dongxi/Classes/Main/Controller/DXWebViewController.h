//
//  DXWebViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXRouteManager.h"
#import "DXJavaScriptBridge.h"
#import "DXBarButtonItem.h"

@interface DXWebViewController : UIViewController <UIWebViewDelegate, DXRouteControler, DXJavaScriptBridgeController>

@property (nonatomic, readonly) UIWebView * webView;
@property (nonatomic) NSURL * url;
@property (nonatomic, assign) BOOL showControls;

@end
