//
//  DXWebViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXWebViewController.h"
#import "DXRefreshHeader.h"
#import "DXFunctions.h"
#import "NSObject+Extension.h"
#import "NSUserDefaults+DXUnRegisterDefaults.h"
#import "DXLoginViewController.h"

@implementation DXWebViewController {
    DXBarButtonItem * _backItem;
    DXBarButtonItem * _closeItem;
    DXBarButtonItem * _reloadItem;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _showControls = YES;
    }
    return self;
}

- (UIViewController *)initWithRouteParams:(NSDictionary *)params {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _showControls = NO;
        self.url = [params objectForKey:@"url"];
    }
    return self;
}

- (void)loadView {
    NSDictionary * userAgentInfo = @{@"UserAgent": [self getUserAgent]};
    [[NSUserDefaults standardUserDefaults] registerDefaults:userAgentInfo];
    
    [super loadView];
}

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] unregisterDefaultForKey:@"UserAgent"];
    
    [self removeNotification];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_Web;
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.backgroundColor = DXRGBColor(222, 222, 222);
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    _backItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    [_backItem setTarget:self];
    [_backItem setAction:@selector(backItemTapped:)];
    
    _closeItem = [[DXBarButtonItem alloc] init];
    [_closeItem setTitle:@"关闭"];
    [_closeItem setTarget:self];
    [_closeItem setAction:@selector(closeItemTapped:)];
    
    _reloadItem = [[DXBarButtonItem alloc] init];
    _reloadItem.enabled = NO;
    [_reloadItem setImage:[UIImage imageNamed:@"Refresh"]];
    [_reloadItem setTarget:self];
    [_reloadItem setAction:@selector(reloadItemTapped:)];
    
    [self.navigationItem setLeftBarButtonItem:_backItem];
    
    if (self.showControls) {
        [self.navigationItem setRightBarButtonItem:_reloadItem];
    } else {
        _webView.scrollView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:_webView refreshingAction:@selector(reload)];
    }
    
    if (_url) {
        [self loadURL:_url];
    }
    
    [self registerNotification];
}

/*
- (void)printSookies {
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:@"http://m.dongxi365.com:8088"]];
    for (NSHTTPCookie *cookie in cookies) {
        DXLog(@"-->%@", cookie);
    }
}
 */

/*
- (void)setCookies {
    
    NSString *host = [NSString stringWithFormat:@"%@://%@", [self.url scheme], [self.url host]];
    NSURL *hostURL = [NSURL URLWithString:host];
    DXUserSession *session = [[DXDongXiApi api] currentUserSession];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setValue:session.sid forKey:@"sid"];
    [properties setValue:session.uid forKey:@"uid"];
    [properties setValue:DXGetDeviceModel() forKey:@"device_model"];
    [properties setValue:DXGetDeviceUUID() forKey:@"udid"];
    
    for (NSString *key in properties.allKeys) {
        NSDictionary *cookieProperties = [NSMutableDictionary dictionary];
        
        [cookieProperties setValue:key forKey:NSHTTPCookieName];
        [cookieProperties setValue:[properties objectForKey:key] forKey:NSHTTPCookieValue];
        [cookieProperties setValue:[self.url host] forKey:NSHTTPCookieDomain];
        [cookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
        
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        
        NSDictionary *fields = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]] forKey:@"Set-Cookie"];
        NSArray *headeringCookie = [NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:hostURL];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:headeringCookie forURL:hostURL mainDocumentURL:nil];
    }
}
 */

- (void)setUrl:(NSURL *)url {
    _url = url;
    [self loadURL:url];
}

#pragma mark -

- (NSString *)getUserAgent {
    NSString * appVersion = DXGetAppBuildVersion();
    UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString * defaultUserAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString * userAgent = [NSString stringWithFormat:@"%@ dongxi/%@", defaultUserAgent, appVersion];
    return userAgent;
}

- (void)loadURL:(NSURL *)url {
    if (url) {
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
}

- (void)insertJS:(UIWebView *)webView {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ios" ofType:@"js"];
    NSString *node = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    node = [node stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    node = [node stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\\\r\n"];
    NSString *js = [NSString stringWithFormat:@"\
                    var element = document.createElement(\"script\");\
                    element.setAttribute(\"type\", \"text/javascript\");\
                    var node = document.createTextNode(\"%@\");\
                    element.appendChild(node);\
                    document.body.appendChild(element);\
                    ", node];
    
    [webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - <UIWebViewDelegate>

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.navigationItem.title = @"正在加载...";
    [self enableReload:@NO];
    [self performSelector:@selector(enableReload:) withObject:@YES afterDelay:2.0];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSString * title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationItem.title = title;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableReload:) object:@YES];
    [self enableReload:@YES];
    if (self.showControls == NO) {
        [self.webView.scrollView.mj_header endRefreshing];
    }
    
    [self insertJS:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.showControls == NO) {
        [self.webView.scrollView.mj_header endRefreshing];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *URL = request.URL;
    if ([[URL scheme] isEqualToString:@"dongxiapp"]) {
        
        UIViewController *vc = [[DXRouteManager sharedRouteManager] handleRouteURL:URL];
        [self.navigationController pushViewController:vc animated:YES];
        
        return NO;
    }
    
    if ([[URL scheme] isEqualToString:@"dongxibridge"]) {
        
        [[DXJavaScriptBridge sharedBridge] performJSMethodWithURL:URL performViewController:self];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - DXJavaScriptBridgeController

- (void)performJSMethod:(NSString *)methodName params:(NSArray *)params {
    
    [self performSelector:NSSelectorFromString(methodName) withObjects:params];
}

#pragma mark - 

- (IBAction)backItemTapped:(UIBarButtonItem *)sender {
    if (self.showControls) {
        if ([_webView canGoBack]) {
            [_webView goBack];
            [self.navigationItem setLeftBarButtonItems:@[_backItem, _closeItem]];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)closeItemTapped:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)reloadItemTapped:(UIBarButtonItem *)sender {
    [_webView reload];
}

- (void)enableReload:(NSNumber *)enable {
    _reloadItem.enabled = [enable boolValue];
}

#pragma mark - jsMethod

- (void)jsNavigationPop {
    [self backItemTapped:nil];
}

- (void)jsNavigationSetTitle:(NSString *)title {
    self.navigationItem.title = title;
}

- (void)jsUserNeedLogin {
    __weak typeof(self) weakSelf = self;
    DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
    [alert setTitle:@""];
    [alert setMessage:@"登录后才可提问，是否现在就登录/注册？"];
    [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
    [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
        loginNav.navigationBar.hidden = YES;
        [weakSelf presentViewController:loginNav animated:YES completion:nil];
    }]];
    [alert showInController:self animated:YES completion:nil];
}

#pragma mark - notifications

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataList) name:DXDongXiApiNotificationUserDidLogin object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDongXiApiNotificationUserDidLogin object:nil];
}

- (void)refreshDataList {
    [self loadURL:self.url];
}

@end
