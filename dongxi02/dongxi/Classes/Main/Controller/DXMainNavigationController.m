//
//  DXMainNavigationController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMainNavigationController.h"
#import "DXDongXiApi.h"
#import "DXProfileViewController.h"
#import "DXTopicViewController.h"
#import "DXShareView.h"
#import "DXLikerListViewController.h"
#import "DXMapViewController.h"
#import "AppDelegate.h"
#import "DXInvitationViewController.h"

NSString *const DXDeleteFeedNotification = @"DXDeleteFeedNotification";

@interface DXMainNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

/** 分享与收藏视图 */
@property (nonatomic, strong) DXShareView *shareView;
/** 分享时透明遮盖  */
@property (nonatomic, weak) UIButton *coverV;

@end

@implementation DXMainNavigationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _enableInteractivePopGesture = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = weakSelf;
}

/*
- (void)setEnableInteractivePopGesture:(BOOL)enableInteractivePopGesture {
    _enableInteractivePopGesture = enableInteractivePopGesture;
    
    self.interactivePopGestureRecognizer.enabled = enableInteractivePopGesture;
}
 */

#pragma mark - 跳转到个人控制器
// 通过昵称跳转到个人控制器
- (void)pushToProfileViewControllerWithNick:(NSString *)nick info:(NSDictionary *)info {
    
    DXProfileViewController *profileVC = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserNick];
    profileVC.nick = nick;
    profileVC.hidesBottomBarWhenPushed = YES;
    [self pushViewController:profileVC animated:YES];
}
// 通过用户ID跳转到个人控制器
- (void)pushToProfileViewControllerWithUserID:(NSString *)userID info:(NSDictionary *)info {
    
    DXProfileViewController *profileVC = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
    profileVC.uid = userID;
    profileVC.hidesBottomBarWhenPushed = YES;
    [self pushViewController:profileVC animated:YES];
}
#pragma mark - 跳转到话题控制器
- (void)pushToTopicViewControllerWithTopicID:(NSString *)topicID info:(NSDictionary *)info {
    if (self.childViewControllers.count > 2) {
        UIViewController * previousViewController = self.childViewControllers[self.childViewControllers.count - 2];
        if ([previousViewController isKindOfClass:[DXTopicViewController class]]) {
            DXTopicViewController * topicViewController = (DXTopicViewController *)previousViewController;
            if ([topicViewController.topicID isEqualToString:topicID]) {
                [self popViewControllerAnimated:YES];
                return;
            }
        }
    }
    
    DXTopicViewController *vc = [[DXTopicViewController alloc] init];
    vc.topicID = topicID;
    vc.hidesBottomBarWhenPushed = YES;
    [self pushViewController:vc animated:YES];
}

#pragma mark - 显示收藏与分享视图
- (void)showCollectionAndShareViewWithFeed:(DXTimelineFeed *)feed info:(NSDictionary *)info {
    
    DXScreenNotice *screenNotice = [[DXScreenNotice alloc] initWithMessage:@"正在加载..." fromController:self];
    screenNotice.disableAutoDismissed = NO;
    [screenNotice show];
    
    [[DXDongXiApi api] getFeedWithID:feed.fid result:^(DXTimelineFeed *feed, NSError *error) {
        
        [screenNotice dismiss:YES];
        
        if (feed) {
            DXShareView *shareView = [[DXShareView alloc] initWithType:DXShareViewTypeCollectionAndShare fromController:self];
            
            NSString * feedNick = feed.nick;
            NSString * feedText = feed.data.text;
            NSString * feedTopic = feed.data.topic.topic;
            
            NSString *title = nil;
            if (feedTopic) {
                title = [NSString stringWithFormat:@"%@: #%@# %@", feedNick, feedTopic, feedText];
            } else {
                title = [NSString stringWithFormat:@"%@: %@", feedNick, feedText];
            }
            
            NSString *desc = @"东西 - 收集一切生活趣味";
            NSString *url = [NSString stringWithFormat:DXMobilePageFeedURLFormat, feed.fid];
            DXTimelineFeedPhoto *photo = [feed.data.photo firstObject];
            
            DXWeChatShareInfo *wechatShareInfo = [[DXWeChatShareInfo alloc] init];
            wechatShareInfo.title = title;
            wechatShareInfo.desc = desc;
            wechatShareInfo.url = url;
            wechatShareInfo.photoUrl = photo.preview;
            
            DXWeiboShareInfo *weiboShareInfo = [[DXWeiboShareInfo alloc] init];
            weiboShareInfo.title = title;
            weiboShareInfo.url = url;
            weiboShareInfo.desc = desc;
            weiboShareInfo.photoUrl = photo.url;
            
            shareView.feed = feed;
            shareView.weChatShareInfo = wechatShareInfo;
            shareView.weiboShareInfo = weiboShareInfo;
            
            [shareView show];
        } else {
            NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后重试";
            NSString * message = [NSString stringWithFormat:@"无法获取收藏状态，%@", reason];
            DXScreenNotice *screenNotice = [[DXScreenNotice alloc] initWithMessage:message fromController:self];
            [screenNotice show];
        }
    }];
}

#pragma mark - 跳转到点赞的人列表控制器
- (void)pushToLikerListViewControllerWithFeedID:(NSString *)feedID info:(NSDictionary *)info {
    
    DXLikerListViewController *vc = [[DXLikerListViewController alloc] init];
    vc.feedID = feedID;
    vc.hidesBottomBarWhenPushed = YES;
    [self pushViewController:vc animated:YES];
}

#pragma mark - 关注某个用户
- (void)followUserWithUserID:(NSString *)userID info:(NSDictionary *)info  completion:(void(^)(BOOL))completion {
    
    [[DXDongXiApi api] followUser:userID result:^(BOOL success, DXUserRelationType relation, NSError *error) {
        if (success) {
            DXLog(@"关注成功");
        } else {
            NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            NSString * message = [NSString stringWithFormat:@"关注失败，%@", reason];
            [MBProgressHUD showHUDWithMessage:message];
        }
        
        if (completion) {
            completion(success);
        }
    }];
}

#pragma mark - 取消关注某个用户
- (void)unfollowUserWithUserID:(NSString *)userID info:(NSDictionary *)info completion:(void(^)(BOOL))completion {
    
    [[DXDongXiApi api] unfollowUser:userID result:^(BOOL success, DXUserRelationType relation, NSError *error) {
        if (success) {
            DXLog(@"取消关注成功");
        } else {
            NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
            NSString * message = [NSString stringWithFormat:@"取消关注失败，%@", reason];
            [MBProgressHUD showHUDWithMessage:message];
        }
        
        if (completion) {
            completion(success);
        }
    }];
}

#pragma mark - 跳转到地图控制器
- (void)pushToMapViewControllerWithFeed:(DXTimelineFeed *)feed info:(NSDictionary *)info {
    
    DXMapViewController *vc = [[DXMapViewController alloc] init];
    vc.feed = feed;
    [self pushViewController:vc animated:YES];
}

#pragma mark - 跳转到邀请码列表控制器
- (void)pushToInvitationViewControllerWithInfo:(NSDictionary *)info {
    
    DXInvitationViewController *vc = [[DXInvitationViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self pushViewController:vc animated:YES];
}

#pragma mark - status bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];;
}

#pragma mark - 登陆相关

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

#pragma mark - Override Super Methods

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (animated) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    [super pushViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    if (animated) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (animated) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return [super popToViewController:viewController animated:animated];
}

#pragma mark - <UINavigationControllerDelegate>

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.interactivePopGestureRecognizer.enabled = self.enableInteractivePopGesture;
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
    }
    return YES;
}


@end
