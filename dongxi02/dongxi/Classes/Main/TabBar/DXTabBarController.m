//
//  DXTabBarController.m
//  dongxi
//
//  Created by 穆康 on 15/8/4.
//  Copyright (c) 2015年 穆康. All rights reserved.
//

#import "DXTabBarController.h"
#import "DXHomeViewController.h"
#import "DXDiscoverViewController.h"
#import "DXMessageViewController.h"
#import "DXProfileViewController.h"
#import "DXTabBar.h"
#import "DXFeedPublishViewController.h"
#import "DXPhotoTakerController.h"
#import "UIImage+Extension.h"
#import "DXMainNavigationController.h"
#import "DXDongXiApi.h"
#import "AppDelegate.h"
#import "UITabBar+Badge.h"
#import "DXChatMessageManager.h"
#import "DXChatHelper.h"
#import <EaseMob.h>

@interface DXTabBarController ()<DXPhotoTakerControllerDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate, EMChatManagerDelegate>

@property (nonatomic, strong) DXProfileViewController * loginUserProfileController;

@end

@implementation DXTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.delegate = self;
    
    [self addOneChildViewController:[[DXHomeViewController alloc] init] title:@"首页" image:@"tab_home_normal" selectedImage:@"tab_home_click"];
    [self addOneChildViewController:[[DXDiscoverViewController alloc] init] title:@"发现" image:@"tab_discover_normal" selectedImage:@"tab_discover_click"];
    [self addOneChildViewController:[[DXMessageViewController alloc] init] title:@"消息" image:@"tab_news_normal" selectedImage:@"tab_news_click"];
    self.loginUserProfileController = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerLoginUser];
    [self addOneChildViewController:self.loginUserProfileController title:@"我的" image:@"tab_profile_normal" selectedImage:@"tab_profile_click"];
    
    [self setValue:[[DXTabBar alloc] init] forKey:@"tabBar"];
    [self.tabBar setBackgroundImage:[UIImage imageWithColor:DXRGBColor(255, 255, 255)]];
    [self.tabBar setShadowImage:[UIImage shadowImageWithColor:DXRGBColor(195, 195, 195)]];
    
    //默认显示“发现”
//    [self setSelectedIndex:1];
    
    // 注册为EaseMob的监听对象
//    [self registerEaseMobDelegate];
    
    // 注册通知
    [self registerNotification];
    [self checkUnreadMessage];
}

- (void)dealloc {
    
    // 移除EaseMob的监听对象
//    [self removeEaseMobDelegate];
    
    // 注销通知
    [self removeNotification];
}

/**
 *  添加一个子控制器
 *
 *  @param childController 子控制器
 *  @param title           标题
 *  @param image           图片
 *  @param selectedImage   选中的图片
 */
- (void)addOneChildViewController:(UIViewController *)childController title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage {
    
    [childController.tabBarItem setTitleTextAttributes:@{
                                                         NSForegroundColorAttributeName : DXCommonColor
                                                         } forState:UIControlStateSelected];
    
    childController.tabBarItem.title = title;
    childController.tabBarItem.image = [UIImage imageNamed:image];
    childController.tabBarItem.selectedImage = [UIImage imageNamed:selectedImage];
    childController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2);
    DXMainNavigationController *nav = [[DXMainNavigationController alloc] initWithRootViewController:childController];
    [self addChildViewController:nav];
}

#pragma mark - 点击拍照跳转控制器
-(void)photoBtnClick{
    DXPhotoTakerController * photoTaker = [[DXPhotoTakerController alloc] init];
    photoTaker.delegate = self;
    [self presentViewController:photoTaker animated:YES completion:nil];
}

- (void)photoTaker:(DXPhotoTakerController *)photoTaker didFinishPhoto:(UIImage *)photo {
    __weak DXTabBarController * weakSelf = self;
    
    [self dismissViewControllerAnimated:NO completion:^{
        DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"正在处理照片" fromController:self];
        [notice disableAutoDismissed];
        [notice show];
        
        DXFeedPublishViewController *publishVC = [[DXFeedPublishViewController alloc] init];
        publishVC.delegateController = self.loginUserProfileController;
        [publishVC appendPhoto:photo];
        
        UINavigationController * publishNav = [[UINavigationController alloc] initWithRootViewController:publishVC];
        [weakSelf presentViewController:publishNav animated:YES completion:^{
            [notice dismiss:NO];
        }];
    }];
}


#pragma mark - 生命周期方法
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
}


#pragma mark - <UITabBarControllerDelegate>

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return [self validateUserLoginStatusForNextController:viewController];
}


#pragma mark - 登陆判断

/**
 *  判断用户登录状态并检查该状态是否能显示下一个即将显示的视图控制器
 *
 *  @param viewController 下一个即将显示的视图控制器
 *
 *  @return 返回YES表示用户状态对下一个即将显示的视图控制器是有效的，反之返回NO
 */
- (BOOL)validateUserLoginStatusForNextController:(UIViewController *)viewController {
    return YES;
}

/**
 *  据据需要呈现登陆视图
 *
 *  @return 返回YES表示呈现了登陆视图，反之返回NO
 */
- (BOOL)presentLoginViewIfNeeded {
    if ([[DXDongXiApi api] needLogin]) {
        AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate checkLoginStatus];
        return YES;
    } else {
        return NO;
    }
}
/*
#pragma mark - <EMChatManagerDelegate>

// 会话列表信息更新时的回调
- (void)didUpdateConversationList:(NSArray *)conversationList {
    
    [self checkUnreadMessage];
}

- (void)didUnreadMessagesCountChanged {
    
    [self checkUnreadMessage];
}

- (void)didFinishedReceiveOfflineMessages {
    
    // 统计新消息（环信）
    [self checkEaseMobUnreadMessage];
}

- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    
    // 统计新消息（环信）
    [self checkEaseMobUnreadMessage];
}

- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    
    // 统计新消息（环信）
    [self checkEaseMobUnreadMessage];
}
*/
#pragma mark - 统计未读消息包括私聊、评论、赞和通知的消息

- (void)checkNormalUnreadMessage {
    
    if (self.notificationDetail.comment || self.notificationDetail.like || self.notificationDetail.notice) {
        [self.tabBar showBadgeOnItemIndex:3];
    }
}

- (void)checkChatUnreadMessage {
    
    __weak typeof(self) weakSelf = self;
    DXChatMessageManager *chatMessageManager = [DXChatMessageManager sharedManager];
    [chatMessageManager checkHadUnreadMessages:^(BOOL had, NSError *error) {
        if (had) {
            [weakSelf.tabBar showBadgeOnItemIndex:3];
        }
    }];
}

//- (void)checkEaseMobUnreadMessage {
//    
//    NSInteger unreadCount = [[[EaseMob sharedInstance] chatManager] loadTotalUnreadMessagesCountFromDatabase];
//    
//    if (unreadCount) {
//        [self.tabBar showBadgeOnItemIndex:3];
//    }
//}

- (void)checkUnreadMessage {
    
    __weak typeof(self) weakSelf = self;
    DXChatMessageManager *chatMessageManager = [DXChatMessageManager sharedManager];
    [chatMessageManager checkHadUnreadMessages:^(BOOL had, NSError *error) {
        if (had) {
            [weakSelf.tabBar showBadgeOnItemIndex:3];
        } else {
            if (!weakSelf.notificationDetail.comment && !weakSelf.notificationDetail.like && !weakSelf.notificationDetail.notice) {
                [self.tabBar hideBadgeOnItemIndex:3];
            } else {
                [self.tabBar showBadgeOnItemIndex:3];
            }
        }
    }];
}
/*
#pragma mark - 注册或移除EaseMob的监听对象

// 注册
- (void)registerEaseMobDelegate {
    
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

// 移除
- (void)removeEaseMobDelegate {
    
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}
*/
#pragma mark - 通知

- (void)registerNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoBtnClick) name:@"DXPhotoBtnDidClickNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserDidLoginNotification:) name:DXDongXiApiNotificationUserDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserDidLogoutNotification:) name:DXDongXiApiNotificationUserDidLogout object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidReceiveMessageNotification:) name:DXChatDidReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidReceiveOfflineMessagesNotification:) name:DXChatDidReceiveOfflineMessagesNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEaseMobDidLoginNotification:) name:DXChatDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUnreadMessageCountDidChangeNotification:) name:DXChatUnreadMessageCountDidChangeNotification object:nil];
}

- (void)removeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 接收到通知执行的方法

- (void)onUserDidLoginNotification:(NSNotification *)noti {
    // 用户登录后检查是否有新消息
    [self checkUnreadMessage];
}

- (void)onUserDidLogoutNotification:(NSNotification *)noti {
    // 用户登出后需要隐藏tabBar上的小红点
    [self hideTabBarBagde];    
}

- (void)handleDidReceiveMessageNotification:(NSNotification *)notification {
    [self checkChatUnreadMessage];
}

- (void)handleDidReceiveOfflineMessagesNotification:(NSNotification *)notification {
    [self checkChatUnreadMessage];
}

- (void)handleEaseMobDidLoginNotification:(NSNotification *)notification {
    [self checkUnreadMessage];
}

- (void)handleUnreadMessageCountDidChangeNotification:(NSNotification *)notification {
    [self checkUnreadMessage];
}

- (void)hideTabBarBagde {
    
    self.notificationDetail = nil;
    [self.tabBar hideBadgeOnItemIndex:3];
}

@end
