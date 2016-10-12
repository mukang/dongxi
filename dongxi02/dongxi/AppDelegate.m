//
//  AppDelegate.m
//  dongxi
//
//  Created by 穆康 on 15/8/3.
//  Copyright (c) 2015年 穆康. All rights reserved.
//

#import "AppDelegate.h"

#import "DXTabBarController.h"
#import "DXLoginViewController.h"
#import "DXLaunchViewController.h"
#import "DXRegisterUserInfoViewController.h"
#import "DXTagViewController.h"

#import "DXTagAlertView.h"

#import "DXDongXiApi.h"
#import "DXChatHelper.h"
#import "WeiboManager.h"
#import "WXApiManager.h"
#import "JPUSHService.h"
#import "DXLoginEaseMob.h"
#import "DXCacheFileManager.h"
#import <Bugly/Bugly.h>
#import "TalkingData.h"
#import "DXFunctions.h"
#import "DXMobileConfig.h"

static NSString *const kWeiboAppKey = @"2930553092";
/*
static NSString *const kWeChatAppKey = @"wx2d2724d8b6254932";
 */
static NSString *const kTalkingDataAppId = @"DD4B6E0B9D5B43C6358CFFF3B0941CD6";
static NSString *const kJPushAppKey = @"99a5c82421621bc2e2750ef2";
static NSString *const kJPushChannel = @"Publish channel";

@interface AppDelegate ()

@property (nonatomic, strong) DXUserCheckResult *userCheckResult;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //启动Bugly
    [Bugly startWithAppId:@"900018969"];
    
#ifndef DEBUG
    [TalkingData setExceptionReportEnabled:NO];
    [TalkingData setSignalReportEnabled:NO];
    //启用TalkingData，暂不启用渠道分类
    [TalkingData sessionStarted:kTalkingDataAppId withChannelId:@""];
#endif
    
    //启用DXDongXiApi
    [[DXDongXiApi api] prepareForWorking:^(NSError *error) {
        if (error == nil) {
            if ([[DXDongXiApi api] needLogin]) {
                [TalkingData setGlobalKV:@"isLogin" value:@(0)];
            } else {
                [TalkingData setGlobalKV:@"isLogin" value:@(1)];
                [self setCookies];
            }
        }
    }];
    
    //启用缓存文件管理
    [[DXCacheFileManager sharedManager] applicationDidFinishLaunchingWithOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[DXTabBarController alloc] init];
    
    //设置状态栏颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    //设置搜索栏字体
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[DXFont dxDefaultFontWithSize:15]];
    if (DXSystemVersion >= 8) {
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
         setDefaultTextAttributes:@{
                                    NSFontAttributeName: [DXFont dxDefaultFontWithSize:15],
                                    NSForegroundColorAttributeName : DXRGBColor(72, 72, 72)
                                    }];
    }
    
    // 极光推送相关
    [self setupJPushWithApplication:application launchOptions:launchOptions];
    
    // 环信相关
    [self setupEaseMobWithApplication:application launchOptions:launchOptions];
    
    // 新浪微博相关
#if DEBUG
    [WeiboSDK enableDebugMode:YES];
#endif
    [WeiboSDK registerApp:kWeiboAppKey];
    
    // 微信相关
    [WXApi registerApp:WXAppID];
    
    // 注册通知
    [self registerNotification];
    
    [self.window makeKeyAndVisible];
    [self showLaunchWindow];
    
    return YES;
}

/** 显示启动视窗 */
- (void)showLaunchWindow {
    DXLaunchViewController * launchViewController = [[DXLaunchViewController alloc] init];
    self.launchWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.launchWindow.rootViewController = launchViewController;
    self.launchWindow.windowLevel = UIWindowLevelNormal;
    self.launchWindow.hidden = NO;
    launchViewController.launchWindow = self.launchWindow;
}

/**
 *  检查登陆状态
 */
- (void)checkLoginStatus {
    
    if ([[DXDongXiApi api] needLogin]) {
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
        nav.navigationBar.hidden = YES;
        [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
        
    }
}

#pragma mark - 检查用户设置信息及应用新版本
/**
 *  检查用户设置信息及应用新版本
 */
- (void)checkUserInfoAndAppVersion:(NSNotification *)notification {
    
    __weak typeof(self) weakSelf = self;
    
    BOOL isLogin = ![[DXDongXiApi api] needLogin];
    NSString *currentUid = [[DXDongXiApi api] currentUserSession].uid;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *cacheBuildVersion = [userDefault objectForKey:DX_DEFAULTS_KEY_APP_VERSION_ALERT];
    NSString *cacheUid = nil;
    NSDictionary *cacheDict = [userDefault objectForKey:DX_DEFAULTS_KEY_LIKE_TAG_ALERT];
    if (cacheDict != nil && [cacheDict isKindOfClass:[NSDictionary class]]) {
        cacheUid = [cacheDict objectForKey:currentUid];
    }
    BOOL isRegistered = NO;
    NSNumber *obj = notification.object;
    if (obj && [obj isKindOfClass:[NSNumber class]]) {
        isRegistered = [obj boolValue];
    }
    
    DXUserCheckType type = 0;
    if (isLogin) {
        type = DXUserCheckTypeNotification;
        if (isRegistered == NO) {
            type = type | DXUserCheckTypeSetNick;
            if (![cacheUid isEqualToString:currentUid]) {
                type = type | DXUserCheckTypeSetLike;
            }
        }
    }
    
    type = type | DXUserCheckTypeNewVersion;
    
    [[DXDongXiApi api] checkUserInfoAndAppVersionWithCheckType:type result:^(DXUserCheckResult *userCheckResult, NSError *error) {
        weakSelf.userCheckResult = userCheckResult;
        if (userCheckResult.usernick_isset == 2) {
            [weakSelf showRegisterUserInfoView];
        } else if (userCheckResult.userlike_isset == 2) {
            [weakSelf showSetLikeTagAlert];
        } else if (userCheckResult.version.update) {
            if (cacheBuildVersion) {
                NSUInteger cacheBuild = [cacheBuildVersion integerValue];
                if (cacheBuild < userCheckResult.version.build) {
                    [weakSelf showNewAppVersionAlertWithVersion:userCheckResult.version];
                }
            } else {
                [weakSelf showNewAppVersionAlertWithVersion:userCheckResult.version];
            }
        }
        if (userCheckResult.notification && userCheckResult.notification.status) {
            [weakSelf showNewMessageAlertWithUserCheckResult:userCheckResult];
        }
    }];
}

#pragma mark - 新版本提示

/**
 *  弹出新版本提示框
 */
- (void)showNewAppVersionAlertWithVersion:(DXUserCheckResultVersion *)version {
    
    __weak typeof(self) weakSelf = self;
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
    alert.title = @"检测到新版本，是否升级？";
    alert.message = version.txt;
    DXCompatibleAlertAction *cancelAction = [DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:^(DXCompatibleAlertAction *action) {
        [weakSelf alertActionClickCancel];
    }];
    DXCompatibleAlertAction *confirmAction = [DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:version.url]];
    }];
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    [alert showInController:self.window.rootViewController animated:YES completion:nil];
}

/**
 *  点击了取消
 */
- (void)alertActionClickCancel {
    __weak typeof(self) weakSelf = self;
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
    alert.title = @"是否不再提醒该版本更新？";
    DXCompatibleAlertAction *cancelAction = [DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:nil];
    DXCompatibleAlertAction *confirmAction = [DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
        NSString *cacheBuildVersion = [NSString stringWithFormat:@"%zd", weakSelf.userCheckResult.version.build];
        [[NSUserDefaults standardUserDefaults] setObject:cacheBuildVersion forKey:DX_DEFAULTS_KEY_APP_VERSION_ALERT];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    [alert showInController:self.window.rootViewController animated:YES completion:nil];
}

#pragma mark - 弹出设置用户昵称界面

/**
 *  弹出设置用户昵称界面
 */
- (void)showRegisterUserInfoView {
    
    __weak typeof(self) weakSelf = self;
    DXRegisterUserInfoViewController *vc = [[DXRegisterUserInfoViewController alloc] init];
    vc.registerCompletionBlock = ^() {
        if (weakSelf.userCheckResult.userlike_isset == NO) {
            [weakSelf showSetLikeTagAlert];
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 设置感兴趣标签

/**
 *  弹出设置感兴趣标签提示
 */
- (void)showSetLikeTagAlert {
    
    // 存储不再提醒设置感兴趣标签的标识
    NSString *cacheUid = [[DXDongXiApi api] currentUserSession].uid;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *cacheDict = [userDefaults objectForKey:DX_DEFAULTS_KEY_LIKE_TAG_ALERT];
    if (cacheDict == nil || ![cacheDict isKindOfClass:[NSDictionary class]]) {
        cacheDict = [[NSMutableDictionary alloc] init];
    } else {
        cacheDict = [cacheDict mutableCopy];
    }
    [cacheDict setValue:cacheUid forKey:cacheUid];
    [[NSUserDefaults standardUserDefaults] setObject:cacheDict forKey:DX_DEFAULTS_KEY_LIKE_TAG_ALERT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    DXTagAlertView *alertView = [[DXTagAlertView alloc] initWithController:self.window.rootViewController];
    [alertView show];
    
    /*
    __weak typeof(self) weakSelf = self;
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
    alert.title = @"设置您感兴趣的标签";
    DXCompatibleAlertAction *cancelAction = [DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:nil];
    DXCompatibleAlertAction *confirmAction = [DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
        [weakSelf pushToTagView];
    }];
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    [alert showInController:self.window.rootViewController animated:YES completion:nil];
     */
}

/**
 *  跳转到设置感兴趣标签页
 */
- (void)pushToTagView {
    
    DXTagViewController *vc = [[DXTagViewController alloc] init];
    vc.isFromAlert = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 设置新消息提示

/**
 *  设置新消息提示
 */
- (void)showNewMessageAlertWithUserCheckResult:(DXUserCheckResult *)userCheckResult {
    
    DXTabBarController *tabBarVC = (DXTabBarController *)self.window.rootViewController;
    tabBarVC.notificationDetail = userCheckResult.notification;
    [tabBarVC checkNormalUnreadMessage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DXReloadUnreadMessageNotification object:nil];
}

#pragma mark - 通知相关
/**
 *  注册通知
 */
- (void)registerNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLoginStatus) name:DXNotificationLaunchWindowDidAppear object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUserInfoAndAppVersion:) name:DXNotificationLaunchWindowDidAppear object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:DXDongXiApiNotificationUserDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUserInfoAndAppVersion:) name:DXDongXiApiNotificationUserDidLogin object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSetLikeTagAlert) name:DXShouldShowSetLikeTagAlert object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout:) name:DXDongXiApiNotificationUserDidLogout object:nil];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}

/**
 *  移除通知
 */
- (void)removeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 极光推送相关
/**
 *  极光推送相关   06137adfada
 */
- (void)setupJPushWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
    
#if DEBUG
    [JPUSHService setupWithOption:launchOptions
                           appKey:kJPushAppKey
                          channel:kJPushChannel
                 apsForProduction:NO];
    [JPUSHService setDebugMode];
#else
    [JPUSHService setupWithOption:launchOptions
                           appKey:kJPushAppKey
                          channel:kJPushChannel
                 apsForProduction:YES];
#endif
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    // 检查是否有新消息
    __weak typeof(self) weakSelf = self;
    [[DXDongXiApi api] checkUserInfoAndAppVersionWithCheckType:DXUserCheckTypeNotification result:^(DXUserCheckResult *userCheckResult, NSError *error) {
        if (userCheckResult.notification && userCheckResult.notification.status) {
            [weakSelf showNewMessageAlertWithUserCheckResult:userCheckResult];
        }
    }];
}


#pragma mark - 环信相关
/**
 *  环信相关
 */
- (void)setupEaseMobWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    
#ifdef DEBUG // 处于开发阶段
    NSString *apnsCertName = @"apns_development";
#else
    NSString *apnsCertName = @"apns_distribution";
#endif
    
    [[DXChatHelper sharedHelper] easemobApplication:application didFinishLaunchingWithOptions:launchOptions appkey:@"dongxi#dongxi" apnsCertName:apnsCertName otherConfig:@{kSDKConfigEnableConsoleLogger: [NSNumber numberWithBool:NO]}];
    
    if (![[DXDongXiApi api] needLogin]) {
        
        DXUserSession *userSession = [[DXDongXiApi api] currentUserSession];
        // 登陆环信
        [DXLoginEaseMob loginEaseMobWithUserSession:userSession];
    }
}

#pragma mark -

/**
 *  将得到的deviceToken传给SDK
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    [JPUSHService registerDeviceToken:deviceToken];
}

/**
 *  注册deviceToken失败
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // 检查是否有新消息
    __weak typeof(self) weakSelf = self;
    [[DXDongXiApi api] checkUserInfoAndAppVersionWithCheckType:DXUserCheckTypeNotification result:^(DXUserCheckResult *userCheckResult, NSError *error) {
        if (userCheckResult.notification && userCheckResult.notification.status) {
            [weakSelf showNewMessageAlertWithUserCheckResult:userCheckResult];
        }
    }];
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

/**
 *  进入后台
 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // 设置本地Badge值
    [application setApplicationIconBadgeNumber:0];
    
    [JPUSHService resetBadge];
    
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
    
    [self removeNotification];
}

/**
 *  将要进入前台
 */
- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [application cancelAllLocalNotifications];
    
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
    
    [self registerNotification];
    
    // 检查是否有新消息
    __weak typeof(self) weakSelf = self;
    [[DXDongXiApi api] checkUserInfoAndAppVersionWithCheckType:DXUserCheckTypeNotification result:^(DXUserCheckResult *userCheckResult, NSError *error) {
        weakSelf.userCheckResult = userCheckResult;
        if (userCheckResult.notification && userCheckResult.notification.status) {
            [weakSelf showNewMessageAlertWithUserCheckResult:userCheckResult];
        }
    }];
}

/**
 *  已经激活
 */
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

/**
 *  申请处理时间
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}

/**
 *  从其他应用启动本应用
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([url.absoluteString hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:[WeiboManager sharedManager]];
    }
    
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    }
    
    return NO;
}


#pragma mark - 登陆、注销通知

- (void)userDidLogin:(NSNotification *)noti {
    [DXLoginEaseMob loginEaseMobWithUserSession:[DXDongXiApi api].currentUserSession];
    
    [TalkingData setGlobalKV:@"isLogin" value:@(1)];
    
    [self setCookies];
}

- (void)userDidLogout:(NSNotification *)noti {
    [self checkLoginStatus];
    
    // 注销环信当前登录用户
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        if (error) {
            DXLog(@"用户登出环信失败-->%@", error);
        }
    } onQueue:nil];
    
    [TalkingData setGlobalKV:@"isLogin" value:@(0)];
    
    // 清除微信登录信息
    [[WXApiManager sharedManager] cleanWechatLoginInfo];
    
    [self deleteCookies];
}

- (void)setCookies {
    
    NSURL *hostURL = [NSURL URLWithString:DXWebHost];
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
        [cookieProperties setValue:[hostURL host] forKey:NSHTTPCookieDomain];
        [cookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
        
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        
        NSDictionary *fields = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]] forKey:@"Set-Cookie"];
        NSArray *headeringCookie = [NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:hostURL];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:headeringCookie forURL:hostURL mainDocumentURL:nil];
    }
}

- (void)deleteCookies {
    
    NSURL *url = [NSURL URLWithString:DXWebHost];
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *)[cookies objectAtIndex:i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

@end
